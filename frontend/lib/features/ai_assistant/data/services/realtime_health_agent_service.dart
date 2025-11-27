import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'realtime_client.dart';

/// Service to manage OpenAI Realtime API connections for health assistant
class RealtimeHealthAgentService {
  RealtimeClient? _client;

  final _messagesController = StreamController<AssistantMessage>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  DateTime? _lastErrorTime;
  String? _lastErrorMessage;

  /// Stream of assistant messages
  Stream<AssistantMessage> get messages => _messagesController.stream;

  /// Stream of connection status updates
  Stream<ConnectionStatus> get status => _statusController.stream;

  /// Get the Supabase function URL from environment
  String get _supabaseFunctionUrl {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    developer.log('SUPABASE_URL from env: $supabaseUrl',
        name: 'RealtimeHealthAgentService');

    if (supabaseUrl.isNotEmpty) {
      final url = '$supabaseUrl/functions/v1/health-agent';
      developer.log('Using URL: $url', name: 'RealtimeHealthAgentService');
      return url;
    }
    // Fallback for local development
    developer.log('Using fallback local URL',
        name: 'RealtimeHealthAgentService');
    return 'http://127.0.0.1:54321/functions/v1/health-agent';
  }

  /// Initialize and start the realtime connection
  Future<void> start(String deviceId) async {
    if (_client != null) {
      developer.log('Already connected', name: 'RealtimeHealthAgentService');
      return;
    }

    developer.log('Starting Realtime client for device: $deviceId',
        name: 'RealtimeHealthAgentService');

    _client = RealtimeClient(
      supabaseFunctionUrl: _supabaseFunctionUrl,
      deviceId: deviceId,
    );

    // Listen to events from the client
    _client!.events.listen(_handleRealtimeEvent);

    try {
      _statusController.add(ConnectionStatus.connecting);
      developer.log('Calling client.start()...',
          name: 'RealtimeHealthAgentService');
      await _client!.start();
      developer.log('Client started successfully',
          name: 'RealtimeHealthAgentService');
    } catch (e, stackTrace) {
      developer.log('Failed to start client: $e',
          name: 'RealtimeHealthAgentService', error: e, stackTrace: stackTrace);
      _statusController.add(ConnectionStatus.error);
      _messagesController.add(AssistantMessage(
        role: MessageRole.system,
        content: 'Connection failed: $e',
        timestamp: DateTime.now(),
        isError: true,
      ));
      rethrow;
    }
  }

  /// Stop the realtime connection
  Future<void> stop() async {
    if (_client != null) {
      await _client!.stop();
      _client = null;
    }
    _statusController.add(ConnectionStatus.disconnected);
  }

  /// Send a message to the assistant
  void sendMessage(String text) {
    if (_client == null || !_client!.isConnected) {
      developer.log('Cannot send: not connected',
          name: 'RealtimeHealthAgentService');
      _statusController.add(ConnectionStatus.error);
      return;
    }

    // Add user message to stream immediately
    _messagesController.add(AssistantMessage(
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    ));

    _client!.sendInputText(text);
  }

  /// Handle events from the RealtimeClient
  void _handleRealtimeEvent(RealtimeEvent event) {
    developer.log('Handling event: ${event.type}',
        name: 'RealtimeHealthAgentService');

    switch (event.type) {
      case RealtimeEventType.connected:
        _statusController.add(ConnectionStatus.connected);
        break;

      case RealtimeEventType.disconnected:
        _statusController.add(ConnectionStatus.disconnected);
        break;

      case RealtimeEventType.error:
        _statusController.add(ConnectionStatus.error);

        // Throttle error messages to prevent spam (max 1 per 3 seconds)
        final now = DateTime.now();
        final errorDetail = event.detail ?? '';
        final errorMsg =
            '${event.message ?? 'An error occurred'}${errorDetail.isNotEmpty ? ': $errorDetail' : ''}';

        if (_lastErrorTime == null ||
            now.difference(_lastErrorTime!).inSeconds > 3 ||
            _lastErrorMessage != errorMsg) {
          _lastErrorTime = now;
          _lastErrorMessage = errorMsg;

          developer.log('Error: $errorMsg', name: 'RealtimeHealthAgentService');

          _messagesController.add(AssistantMessage(
            role: MessageRole.system,
            content: errorMsg,
            timestamp: now,
            isError: true,
          ));
        }
        break;

      case RealtimeEventType.responseDelta:
        // Streaming partial response
        _handleResponseDelta(event.data);
        break;

      case RealtimeEventType.responseComplete:
        // Final complete response
        _handleResponseComplete(event.data);
        break;

      case RealtimeEventType.refreshed:
        developer.log('Session refreshed', name: 'RealtimeHealthAgentService');
        break;

      default:
        developer.log('Unhandled event type: ${event.type}',
            name: 'RealtimeHealthAgentService');
    }
  }

  /// Handle partial streaming response
  void _handleResponseDelta(Map<String, dynamic> data) {
    // The exact structure depends on the OpenAI Realtime API version
    // Adapt this based on actual event structure
    final delta = data['delta'];
    if (delta != null) {
      final text = delta['text']?.toString();
      if (text != null && text.isNotEmpty) {
        _messagesController.add(AssistantMessage(
          role: MessageRole.assistant,
          content: text,
          timestamp: DateTime.now(),
          isPartial: true,
        ));
      }
    }
  }

  /// Handle complete response
  void _handleResponseComplete(Map<String, dynamic> data) {
    // The exact structure depends on the OpenAI Realtime API version
    // Adapt this based on actual event structure
    final response = data['response'];
    if (response != null) {
      final text = response['output']?.toString() ??
          response['text']?.toString() ??
          response['content']?.toString();

      if (text != null && text.isNotEmpty) {
        _messagesController.add(AssistantMessage(
          role: MessageRole.assistant,
          content: text,
          timestamp: DateTime.now(),
          isPartial: false,
        ));
      }
    }
  }

  /// Cleanup resources
  void dispose() {
    stop();
    _messagesController.close();
    _statusController.close();
  }

  /// Get current connection status
  bool get isConnected => _client?.isConnected ?? false;
}

/// Message from the assistant or user
class AssistantMessage {
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isPartial;
  final bool isError;

  AssistantMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isPartial = false,
    this.isError = false,
  });
}

/// Message role
enum MessageRole {
  user,
  assistant,
  system,
}

/// Connection status
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}
