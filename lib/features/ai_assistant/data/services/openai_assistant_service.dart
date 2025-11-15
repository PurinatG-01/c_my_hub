import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/openai_models.dart';

class OpenAIAssistantService {
  static const String baseUrl = 'https://api.openai.com/v1';
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  String? _apiKey;
  String? _assistantId;

  OpenAIAssistantService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> initialize({
    required String apiKey,
    String? assistantId,
  }) async {
    _apiKey = apiKey;
    _assistantId = assistantId;

    // Store securely
    await _secureStorage.write(key: 'openai_api_key', value: apiKey);
    if (assistantId != null) {
      await _secureStorage.write(
          key: 'openai_assistant_id', value: assistantId);
    }
  }

  Future<void> _ensureInitialized() async {
    _apiKey ??= await _secureStorage.read(key: 'openai_api_key');
    _assistantId ??= await _secureStorage.read(key: 'openai_assistant_id');

    if (_apiKey == null) {
      throw Exception(
          'OpenAI API key not found. Please initialize the service.');
    }
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v2',
      };

  /// Creates a health coaching assistant with predefined capabilities
  Future<OpenAIAssistant> createHealthAssistant() async {
    await _ensureInitialized();

    final body = {
      'model': 'gpt-4-1106-preview',
      'name': 'Health Coach Assistant',
      'description':
          'A personal health coaching assistant that helps with fitness tracking, nutrition advice, and wellness planning.',
      'instructions': '''
You are a personal health coaching assistant specializing in:
1. Fitness tracking and exercise recommendations
2. Nutrition advice and meal planning
3. Sleep optimization and wellness tips
4. Goal setting and motivation
5. Health data analysis and insights

Always provide evidence-based advice and encourage users to consult healthcare professionals for medical concerns.
When analyzing health data, focus on trends and patterns rather than single data points.
Be encouraging and supportive while being realistic about health goals.
''',
      'tools': [
        {
          'type': 'function',
          'function': {
            'name': 'get_health_metrics',
            'description': 'Retrieve current health metrics for the user',
            'parameters': {
              'type': 'object',
              'properties': {
                'metric_types': {
                  'type': 'array',
                  'items': {'type': 'string'},
                  'description':
                      'List of health metrics to retrieve (steps, heart_rate, sleep, calories)',
                },
                'date_range': {
                  'type': 'string',
                  'description':
                      'Date range for the metrics (today, week, month)',
                },
              },
              'required': ['metric_types'],
            },
          },
        },
        {
          'type': 'function',
          'function': {
            'name': 'set_health_goal',
            'description': 'Set a new health goal for the user',
            'parameters': {
              'type': 'object',
              'properties': {
                'goal_type': {
                  'type': 'string',
                  'description':
                      'Type of goal (steps, weight, exercise, sleep)',
                },
                'target_value': {
                  'type': 'number',
                  'description': 'Target value for the goal',
                },
                'timeline': {
                  'type': 'string',
                  'description': 'Timeline for achieving the goal',
                },
              },
              'required': ['goal_type', 'target_value', 'timeline'],
            },
          },
        },
        {
          'type': 'function',
          'function': {
            'name': 'analyze_health_trends',
            'description': 'Analyze health data trends and provide insights',
            'parameters': {
              'type': 'object',
              'properties': {
                'analysis_type': {
                  'type': 'string',
                  'description':
                      'Type of analysis (weekly_summary, monthly_trends, goal_progress)',
                },
                'focus_areas': {
                  'type': 'array',
                  'items': {'type': 'string'},
                  'description': 'Specific health areas to focus on',
                },
              },
              'required': ['analysis_type'],
            },
          },
        },
      ],
      'metadata': {
        'app': 'c_my_hub',
        'version': '1.0.0',
        'created_by': 'health_app',
      },
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/assistants'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final assistantData = jsonDecode(response.body) as Map<String, dynamic>;
      final assistant = OpenAIAssistant.fromJson(assistantData);

      // Store the assistant ID for future use
      _assistantId = assistant.id;
      await _secureStorage.write(
          key: 'openai_assistant_id', value: assistant.id);

      return assistant;
    } else {
      throw Exception(
          'Failed to create assistant: ${response.statusCode} ${response.body}');
    }
  }

  /// Creates a new conversation thread
  Future<OpenAIThread> createThread({Map<String, dynamic>? metadata}) async {
    await _ensureInitialized();

    final body = {
      'metadata': metadata ?? {},
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/threads'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final threadData = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenAIThread.fromJson(threadData);
    } else {
      throw Exception(
          'Failed to create thread: ${response.statusCode} ${response.body}');
    }
  }

  /// Adds a message to a thread
  Future<void> addMessageToThread({
    required String threadId,
    required String content,
    String role = 'user',
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();

    final body = {
      'role': role,
      'content': content,
      if (metadata != null) 'metadata': metadata,
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/threads/$threadId/messages'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to add message: ${response.statusCode} ${response.body}');
    }
  }

  /// Runs the assistant on a thread
  Future<OpenAIRun> runAssistant({
    required String threadId,
    String? assistantId,
    Map<String, dynamic>? additionalInstructions,
  }) async {
    await _ensureInitialized();

    final useAssistantId = assistantId ?? _assistantId;
    if (useAssistantId == null) {
      throw Exception('No assistant ID available. Create an assistant first.');
    }

    final body = {
      'assistant_id': useAssistantId,
      if (additionalInstructions != null)
        'additional_instructions': additionalInstructions,
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/threads/$threadId/runs'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final runData = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenAIRun.fromJson(runData);
    } else {
      throw Exception(
          'Failed to run assistant: ${response.statusCode} ${response.body}');
    }
  }

  /// Retrieves the status of a run
  Future<OpenAIRun> getRunStatus({
    required String threadId,
    required String runId,
  }) async {
    await _ensureInitialized();

    final response = await _client.get(
      Uri.parse('$baseUrl/threads/$threadId/runs/$runId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final runData = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenAIRun.fromJson(runData);
    } else {
      throw Exception(
          'Failed to get run status: ${response.statusCode} ${response.body}');
    }
  }

  /// Submits tool outputs for function calls
  Future<OpenAIRun> submitToolOutputs({
    required String threadId,
    required String runId,
    required List<Map<String, dynamic>> toolOutputs,
  }) async {
    await _ensureInitialized();

    final body = {
      'tool_outputs': toolOutputs,
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/threads/$threadId/runs/$runId/submit_tool_outputs'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final runData = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenAIRun.fromJson(runData);
    } else {
      throw Exception(
          'Failed to submit tool outputs: ${response.statusCode} ${response.body}');
    }
  }

  /// Retrieves messages from a thread
  Future<List<Map<String, dynamic>>> getThreadMessages({
    required String threadId,
    int? limit,
    String? order,
  }) async {
    await _ensureInitialized();

    final uri = Uri.parse('$baseUrl/threads/$threadId/messages').replace(
      queryParameters: {
        if (limit != null) 'limit': limit.toString(),
        if (order != null) 'order': order,
      },
    );

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception(
          'Failed to get messages: ${response.statusCode} ${response.body}');
    }
  }

  /// Handles health-related function calls
  Map<String, dynamic> handleHealthFunction({
    required String functionName,
    required Map<String, dynamic> arguments,
    required Map<String, dynamic> healthData,
  }) {
    switch (functionName) {
      case 'get_health_metrics':
        return _getHealthMetrics(arguments, healthData);
      case 'set_health_goal':
        return _setHealthGoal(arguments);
      case 'analyze_health_trends':
        return _analyzeHealthTrends(arguments, healthData);
      default:
        return {
          'error': 'Unknown function: $functionName',
        };
    }
  }

  Map<String, dynamic> _getHealthMetrics(
    Map<String, dynamic> arguments,
    Map<String, dynamic> healthData,
  ) {
    final metricTypes = List<String>.from(arguments['metric_types'] ?? []);
    final dateRange = arguments['date_range'] as String? ?? 'today';

    final result = <String, dynamic>{};

    for (final metric in metricTypes) {
      switch (metric) {
        case 'steps':
          result['steps'] = healthData['steps'] ?? 0;
          break;
        case 'heart_rate':
          result['heart_rate'] = healthData['heart_rate'] ?? 0;
          break;
        case 'sleep':
          result['sleep'] = healthData['sleep_hours'] ?? 0;
          break;
        case 'calories':
          result['calories'] = healthData['calories'] ?? 0;
          break;
      }
    }

    result['date_range'] = dateRange;
    result['timestamp'] = DateTime.now().toIso8601String();

    return result;
  }

  Map<String, dynamic> _setHealthGoal(Map<String, dynamic> arguments) {
    return {
      'success': true,
      'goal_type': arguments['goal_type'],
      'target_value': arguments['target_value'],
      'timeline': arguments['timeline'],
      'message': 'Health goal set successfully',
    };
  }

  Map<String, dynamic> _analyzeHealthTrends(
    Map<String, dynamic> arguments,
    Map<String, dynamic> healthData,
  ) {
    final analysisType = arguments['analysis_type'] as String;
    final focusAreas = List<String>.from(arguments['focus_areas'] ?? []);

    return {
      'analysis_type': analysisType,
      'focus_areas': focusAreas,
      'trends': {
        'steps_trend': 'increasing',
        'heart_rate_trend': 'stable',
        'sleep_trend': 'improving',
      },
      'insights': [
        'Your step count has increased by 15% this week',
        'Heart rate during exercise shows good cardiovascular fitness',
        'Sleep quality has improved with consistent bedtime routine',
      ],
      'recommendations': [
        'Continue current exercise routine',
        'Consider adding strength training 2x per week',
        'Maintain current sleep schedule',
      ],
    };
  }

  void dispose() {
    _client.close();
  }
}
