import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

/// Session information returned by the server
class RealtimeSession {
  String? clientSecret;
  DateTime? expiresAt;
  String? sessionId;
  int? ttlSeconds;

  bool get isExpired {
    if (expiresAt == null) return true;
    return DateTime.now().toUtc().isAfter(expiresAt!);
  }

  bool get shouldRefresh {
    if (expiresAt == null) return true;
    final now = DateTime.now().toUtc();
    final timeLeft = expiresAt!.difference(now);
    // Refresh at 80% of TTL
    final ttl = ttlSeconds ?? 3600;
    final refreshThreshold = Duration(seconds: (ttl * 0.8).round());
    return timeLeft <= refreshThreshold;
  }
}

/// Event types from OpenAI Realtime API
enum RealtimeEventType {
  connected,
  disconnected,
  error,
  sent,
  refreshed,
  // OpenAI Realtime specific events
  sessionUpdate,
  inputCreate,
  responseDelta,
  responseComplete,
  toolInvoke,
  toolResponse,
  unknown,
}

/// Parsed event from the Realtime API
class RealtimeEvent {
  final RealtimeEventType type;
  final Map<String, dynamic> data;
  final String? message;
  final String? detail;

  RealtimeEvent({
    required this.type,
    required this.data,
    this.message,
    this.detail,
  });

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString() ?? 'unknown';
    RealtimeEventType eventType;

    switch (typeStr) {
      case 'connected':
        eventType = RealtimeEventType.connected;
        break;
      case 'disconnected':
        eventType = RealtimeEventType.disconnected;
        break;
      case 'error':
        eventType = RealtimeEventType.error;
        break;
      case 'sent':
        eventType = RealtimeEventType.sent;
        break;
      case 'refreshed':
        eventType = RealtimeEventType.refreshed;
        break;
      case 'session.update':
        eventType = RealtimeEventType.sessionUpdate;
        break;
      case 'input.create':
        eventType = RealtimeEventType.inputCreate;
        break;
      case 'response.delta':
        eventType = RealtimeEventType.responseDelta;
        break;
      case 'response.complete':
        eventType = RealtimeEventType.responseComplete;
        break;
      case 'tool.invoke':
        eventType = RealtimeEventType.toolInvoke;
        break;
      case 'tool.response':
        eventType = RealtimeEventType.toolResponse;
        break;
      default:
        eventType = RealtimeEventType.unknown;
    }

    return RealtimeEvent(
      type: eventType,
      data: json,
      message: json['message']?.toString(),
      detail: json['detail']?.toString(),
    );
  }
}

/// Native Flutter WebSocket client for OpenAI Realtime API
/// Uses ephemeral client_secret minted by your Supabase Edge function
class RealtimeClient {
  final String supabaseFunctionUrl;
  final String deviceId;

  RealtimeSession _session = RealtimeSession();
  IOWebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  Timer? _refreshTimer;
  bool _closing = false;
  int _reconnectAttempts = 0;

  static const Duration reconnectBackoffBase = Duration(seconds: 1);
  static const Duration reconnectBackoffMax = Duration(seconds: 10);
  static const int maxReconnectAttempts = 5;

  // Expose a stream of parsed events to the UI
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _eventController.stream;

  RealtimeClient({
    required this.supabaseFunctionUrl,
    required this.deviceId,
  });

  /// Start a session (fetch secret + connect)
  Future<void> start() async {
    _closing = false;
    _reconnectAttempts = 0;
    await _fetchSecretAndConnect();
  }

  /// Stop gracefully
  Future<void> stop() async {
    _closing = true;
    _cancelRefresh();
    await _disconnect();
    await _eventController.close();
  }

  /// Fetch ephemeral secret from your edge function
  Future<void> _fetchSecretAndConnect() async {
    try {
      developer.log('Fetching client_secret for device: $deviceId',
          name: 'RealtimeClient');
      developer.log('URL: $supabaseFunctionUrl', name: 'RealtimeClient');

      final requestBody = jsonEncode({'device_id': deviceId});
      developer.log('Request body: $requestBody', name: 'RealtimeClient');

      final resp = await http.post(
        Uri.parse(supabaseFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      developer.log('Response status: ${resp.statusCode}',
          name: 'RealtimeClient');
      developer.log('Response body: ${resp.body}', name: 'RealtimeClient');

      if (resp.statusCode != 200) {
        throw Exception(
            'Failed to fetch client_secret: ${resp.statusCode} ${resp.body}');
      }

      final map = jsonDecode(resp.body) as Map<String, dynamic>;

      // Handle different response structures
      var clientSecret = map['client_secret'];
      if (clientSecret is Map) {
        // New format: {"client_secret": {"value": "...", "expires_at": 123}}
        _session.clientSecret = clientSecret['value']?.toString();
        final expiresAt = clientSecret['expires_at'];
        if (expiresAt is int && expiresAt > 0) {
          _session.expiresAt = DateTime.fromMillisecondsSinceEpoch(
              expiresAt * 1000,
              isUtc: true);
        }
      } else if (clientSecret is String) {
        // Old format: {"client_secret": "..."}
        _session.clientSecret = clientSecret;
      }

      final session = map['session'] as Map<String, dynamic>?;

      if (_session.clientSecret == null || _session.clientSecret!.isEmpty) {
        throw Exception('No client_secret in response');
      }

      _session.sessionId = session?['id']?.toString();

      // Parse session expires_at if not already set from client_secret
      if (_session.expiresAt == null &&
          session != null &&
          session['expires_at'] != null) {
        final expiresAt = session['expires_at'];
        if (expiresAt is int && expiresAt > 0) {
          // Unix timestamp in seconds
          _session.expiresAt = DateTime.fromMillisecondsSinceEpoch(
              expiresAt * 1000,
              isUtc: true);
        } else if (expiresAt is String) {
          // ISO 8601 string
          _session.expiresAt = DateTime.parse(expiresAt).toUtc();
        }
      }

      // If still no expiry, use client_secret structure or default
      if (_session.expiresAt == null) {
        // Default TTL: 1 hour
        _session.ttlSeconds = 3600;
        _session.expiresAt =
            DateTime.now().toUtc().add(Duration(seconds: 3600));
      }

      developer.log(
          'Session created: ${_session.sessionId}, expires: ${_session.expiresAt}',
          name: 'RealtimeClient');

      await _connectWithSecret(clientSecret);
      _scheduleRefresh();
    } catch (e) {
      developer.log('Error fetching secret: $e',
          name: 'RealtimeClient', error: e);
      _eventController.add(RealtimeEvent(
        type: RealtimeEventType.error,
        data: {'type': 'error'},
        message: 'Failed to fetch client_secret',
        detail: e.toString(),
      ));
      rethrow;
    }
  }

  /// Connect to OpenAI Realtime WebSocket with the client_secret
  Future<void> _connectWithSecret(String secret) async {
    await _disconnect(); // ensure no previous socket left dangling

    // The ChatKit client_secret is used with the Realtime API
    final uri = Uri.parse('wss://api.openai.com/v1/realtime');
    final headers = {
      'Authorization': 'Bearer $secret',
      // Required headers for Realtime API
      'OpenAI-Beta': 'realtime=v1',
    };

    developer.log('Attempting WebSocket connection to: $uri',
        name: 'RealtimeClient');
    developer.log('Using client_secret: ${secret.substring(0, 20)}...',
        name: 'RealtimeClient');

    Duration backoff = reconnectBackoffBase;

    while (!_closing && _reconnectAttempts < maxReconnectAttempts) {
      try {
        developer.log(
            'Connecting to WebSocket... (attempt ${_reconnectAttempts + 1})',
            name: 'RealtimeClient');

        _channel = IOWebSocketChannel.connect(
          uri,
          headers: headers,
        );

        _wsSub = _channel!.stream.listen(
          _onWsMessage,
          onError: _onWsError,
          onDone: _onWsDone,
          cancelOnError: false, // Keep listening even after errors
        );

        _reconnectAttempts = 0; // Reset on successful connection
        _eventController.add(RealtimeEvent(
          type: RealtimeEventType.connected,
          data: {'type': 'connected'},
        ));

        developer.log('WebSocket connected successfully',
            name: 'RealtimeClient');
        return;
      } catch (e) {
        _reconnectAttempts++;
        developer.log(
            'WebSocket connection failed (attempt $_reconnectAttempts): $e',
            name: 'RealtimeClient',
            error: e);

        _eventController.add(RealtimeEvent(
          type: RealtimeEventType.error,
          data: {'type': 'error'},
          message:
              'WebSocket connection failed, retrying in ${backoff.inSeconds}s',
          detail: e.toString(),
        ));

        if (_reconnectAttempts < maxReconnectAttempts) {
          await Future.delayed(backoff);
          backoff = backoff * 2;
          if (backoff > reconnectBackoffMax) backoff = reconnectBackoffMax;
        }
      }
    }

    if (_reconnectAttempts >= maxReconnectAttempts) {
      throw Exception('Failed to connect after $maxReconnectAttempts attempts');
    }
  }

  /// Close and cleanup existing socket
  Future<void> _disconnect() async {
    try {
      await _wsSub?.cancel();
    } catch (_) {}
    _wsSub = null;

    try {
      await _channel?.sink.close(status.goingAway);
    } catch (_) {}
    _channel = null;
  }

  /// WebSocket message handler (raw JSON events from Realtime runtime)
  void _onWsMessage(dynamic raw) {
    try {
      final json = raw is String
          ? jsonDecode(raw) as Map<String, dynamic>
          : jsonDecode(String.fromCharCodes(raw)) as Map<String, dynamic>;

      developer.log('WS message: ${jsonEncode(json)}', name: 'RealtimeClient');

      final event = RealtimeEvent.fromJson(json);
      _eventController.add(event);
    } catch (e) {
      developer.log('Invalid JSON from WS: $e',
          name: 'RealtimeClient', error: e);
      _eventController.add(RealtimeEvent(
        type: RealtimeEventType.error,
        data: {'type': 'error'},
        message: 'Invalid JSON from WS',
        detail: e.toString(),
      ));
    }
  }

  void _onWsError(Object err, [StackTrace? stackTrace]) {
    developer.log('WebSocket error: $err',
        name: 'RealtimeClient', error: err, stackTrace: stackTrace);
    _eventController.add(RealtimeEvent(
      type: RealtimeEventType.error,
      data: {'type': 'error'},
      message: 'WebSocket error',
      detail: err.toString(),
    ));
  }

  void _onWsDone() {
    developer.log('WebSocket closed', name: 'RealtimeClient');
    _eventController.add(RealtimeEvent(
      type: RealtimeEventType.disconnected,
      data: {'type': 'disconnected'},
    ));

    // Stop reconnecting - let user manually retry instead of infinite loop
    developer.log('Connection closed, not attempting automatic reconnect',
        name: 'RealtimeClient');
  }

  /// Send a text input to the runtime
  /// The exact event payload depends on the Realtime API version
  void sendInputText(String text) {
    if (_channel == null) {
      developer.log('Cannot send: WebSocket not connected',
          name: 'RealtimeClient');
      _eventController.add(RealtimeEvent(
        type: RealtimeEventType.error,
        data: {'type': 'error'},
        message: 'WebSocket not connected',
      ));
      return;
    }

    final payload = {
      "type": "input.create",
      "payload": {
        "input": {
          "type": "text",
          "text": text,
        },
        "session": _session.sessionId,
      }
    };

    final msg = jsonEncode(payload);
    developer.log('Sending: $msg', name: 'RealtimeClient');

    _channel!.sink.add(msg);
    _eventController.add(RealtimeEvent(
      type: RealtimeEventType.sent,
      data: {'type': 'sent', 'payload': payload},
    ));
  }

  /// Schedule secret refresh before expiry (at 80% of TTL)
  void _scheduleRefresh() {
    _cancelRefresh();

    final expires =
        _session.expiresAt ?? DateTime.now().toUtc().add(Duration(hours: 1));
    final now = DateTime.now().toUtc();
    final timeLeft = expires.difference(now);

    if (timeLeft <= Duration(seconds: 10)) {
      // Refresh immediately
      developer.log('Token expiring soon, refreshing immediately',
          name: 'RealtimeClient');
      _refreshTimer = Timer(Duration.zero, () => _fetchSecretAndConnect());
      return;
    }

    final refreshAfter =
        Duration(milliseconds: (timeLeft.inMilliseconds * 0.8).round());

    developer.log('Scheduling refresh in ${refreshAfter.inMinutes} minutes',
        name: 'RealtimeClient');

    _refreshTimer = Timer(refreshAfter, () async {
      if (_closing) return;
      try {
        developer.log('Refreshing session...', name: 'RealtimeClient');
        await _fetchSecretAndConnect();
        _eventController.add(RealtimeEvent(
          type: RealtimeEventType.refreshed,
          data: {'type': 'refreshed'},
        ));
      } catch (e) {
        developer.log('Refresh failed: $e', name: 'RealtimeClient', error: e);
        _eventController.add(RealtimeEvent(
          type: RealtimeEventType.error,
          data: {'type': 'error'},
          message: 'Session refresh failed',
          detail: e.toString(),
        ));
      }
    });
  }

  void _cancelRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Get current session info
  RealtimeSession get session => _session;

  /// Check if connected
  bool get isConnected => _channel != null && _wsSub != null;
}
