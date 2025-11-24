import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HealthAgentService {
  final http.Client _client;
  String? _sessionId;

  HealthAgentService({http.Client? client}) : _client = client ?? http.Client();

  // Use the Supabase URL from environment
  String get _baseUrl {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    if (supabaseUrl.isNotEmpty) {
      return '$supabaseUrl/functions/v1';
    }
    // Fallback for local development
    return 'http://127.0.0.1:54321/functions/v1';
  }

  String get _anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Send a message to the health agent using OpenAI Responses API
  Future<String> sendMessage({
    required String message,
    bool maintainSession = true,
  }) async {
    final url = Uri.parse('$_baseUrl/health-agent');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_anonKey',
          'apikey': _anonKey,
        },
        body: jsonEncode({
          'message': message,
          if (maintainSession && _sessionId != null) 'session_id': _sessionId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to send message: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Update session ID for conversation continuity
      if (maintainSession && data['session_id'] != null) {
        _sessionId = data['session_id'] as String;
      }

      return data['output'] as String? ?? '';
    } catch (e) {
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
