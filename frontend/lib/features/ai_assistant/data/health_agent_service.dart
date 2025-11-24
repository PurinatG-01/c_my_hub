import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HealthAgentService {
  final http.Client _client;
  String? _sessionId;

  HealthAgentService({http.Client? client}) : _client = client ?? http.Client();

  // Use the Supabase URL from environment
  String get _baseUrl {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    developer.log('SUPABASE_URL from env: $supabaseUrl',
        name: 'HealthAgentService');

    if (supabaseUrl.isNotEmpty) {
      return '$supabaseUrl/functions/v1';
    }
    // Fallback for local development
    developer.log('Using fallback URL: http://127.0.0.1:54321/functions/v1',
        name: 'HealthAgentService');
    return 'http://127.0.0.1:54321/functions/v1';
  }

  String get _anonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    if (key.isEmpty) {
      developer.log('WARNING: SUPABASE_ANON_KEY is empty!',
          name: 'HealthAgentService');
    }
    return key;
  }

  /// Send a message to the health agent using OpenAI Responses API
  Future<String> sendMessage({
    required String message,
    bool maintainSession = true,
  }) async {
    final url = Uri.parse('$_baseUrl/health-agent');

    developer.log('Sending message to: $url', name: 'HealthAgentService');
    developer.log('Message: $message', name: 'HealthAgentService');

    try {
      final requestBody = {
        'message': message,
        if (maintainSession && _sessionId != null) 'session_id': _sessionId,
      };

      developer.log('Request body: ${jsonEncode(requestBody)}',
          name: 'HealthAgentService');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_anonKey',
          'apikey': _anonKey,
        },
        body: jsonEncode(requestBody),
      );

      developer.log('Response status: ${response.statusCode}',
          name: 'HealthAgentService');
      developer.log('Response body: ${response.body}',
          name: 'HealthAgentService');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to send message: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Update session ID for conversation continuity
      if (maintainSession && data['session_id'] != null) {
        _sessionId = data['session_id'] as String;
        developer.log('Session ID updated: $_sessionId',
            name: 'HealthAgentService');
      }

      return data['output'] as String? ?? '';
    } catch (e) {
      developer.log('Error: $e', name: 'HealthAgentService', error: e);
      throw Exception('Error communicating with health agent: $e');
    }
  }

  /// Clear the current session
  void clearSession() {
    _sessionId = null;
  }

  /// Get the current session ID
  String? get sessionId => _sessionId;

  /// Cleanup resources
  void dispose() {
    _client.close();
  }
}
