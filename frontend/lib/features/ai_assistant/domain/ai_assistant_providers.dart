import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/openai_assistant_service.dart';
import '../../health/domain/health_providers.dart';

// Provider for the OpenAI Assistant Service
final openAIAssistantServiceProvider = Provider<OpenAIAssistantService>((ref) {
  return OpenAIAssistantService();
});

// Provider for the current thread ID
final currentThreadProvider = StateProvider<String?>((ref) => null);

// Provider for chat messages
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier(ref);
});

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isTyping = false,
  });

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;

  ChatMessagesNotifier(this.ref) : super([]);

  Future<void> sendMessage(String message) async {
    final service = ref.read(openAIAssistantServiceProvider);
    final timestamp = DateTime.now();

    // Add user message to the list
    final userMessage = ChatMessage(
      id: '${timestamp.millisecondsSinceEpoch}',
      role: 'user',
      content: message,
      timestamp: timestamp,
    );

    state = [...state, userMessage];

    try {
      // Get or create thread
      String? threadId = ref.read(currentThreadProvider);
      if (threadId == null) {
        final thread = await service.createThread();
        threadId = thread.id;
        ref.read(currentThreadProvider.notifier).state = threadId;
      }

      // Add message to thread
      await service.addMessageToThread(
        threadId: threadId,
        content: message,
      );

      // Run the assistant
      final run = await service.runAssistant(threadId: threadId);

      // Show typing indicator
      _addTypingIndicator();

      // Poll for completion
      await _pollRunCompletion(service, threadId, run.id);
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: 'Sorry, I encountered an error: $e',
        timestamp: DateTime.now(),
      );

      _removeTypingIndicator();
      state = [...state, errorMessage];
    }
  }

  void _addTypingIndicator() {
    final typingMessage = ChatMessage(
      id: 'typing',
      role: 'assistant',
      content: '...',
      timestamp: DateTime.now(),
      isTyping: true,
    );
    state = [...state, typingMessage];
  }

  void _removeTypingIndicator() {
    state = state.where((message) => !message.isTyping).toList();
  }

  Future<void> _pollRunCompletion(
    OpenAIAssistantService service,
    String threadId,
    String runId,
  ) async {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));

      final run = await service.getRunStatus(threadId: threadId, runId: runId);

      if (run.status == 'completed') {
        // Get the latest messages
        final messages =
            await service.getThreadMessages(threadId: threadId, limit: 1);

        if (messages.isNotEmpty) {
          final latestMessage = messages.first;
          final content = _extractMessageContent(latestMessage);

          final assistantMessage = ChatMessage(
            id: latestMessage['id'] as String,
            role: 'assistant',
            content: content,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              (latestMessage['created_at'] as int) * 1000,
            ),
          );

          _removeTypingIndicator();
          state = [...state, assistantMessage];
        }
        break;
      } else if (run.status == 'requires_action') {
        await _handleRequiredAction(service, threadId, runId, run);
      } else if (run.status == 'failed' ||
          run.status == 'cancelled' ||
          run.status == 'expired') {
        _removeTypingIndicator();
        final errorMessage = ChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          role: 'assistant',
          content: 'Sorry, the request ${run.status}. Please try again.',
          timestamp: DateTime.now(),
        );
        state = [...state, errorMessage];
        break;
      }
    }
  }

  Future<void> _handleRequiredAction(
    OpenAIAssistantService service,
    String threadId,
    String runId,
    dynamic run,
  ) async {
    final requiredAction = run.requiredAction;
    if (requiredAction?.type == 'submit_tool_outputs') {
      final toolCalls = requiredAction!.submitToolOutputs.toolCalls;
      final toolOutputs = <Map<String, dynamic>>[];

      for (final toolCall in toolCalls) {
        final functionName = toolCall.function.name;
        final arguments = toolCall.function.arguments;

        // Get current health data
        final healthData = await _getCurrentHealthData();

        // Handle the function call
        final output = service.handleHealthFunction(
          functionName: functionName,
          arguments: arguments as Map<String, dynamic>,
          healthData: healthData,
        );

        toolOutputs.add({
          'tool_call_id': toolCall.id,
          'output': output.toString(),
        });
      }

      // Submit tool outputs
      await service.submitToolOutputs(
        threadId: threadId,
        runId: runId,
        toolOutputs: toolOutputs,
      );
    }
  }

  Future<Map<String, dynamic>> _getCurrentHealthData() async {
    try {
      // Get current health data from your existing providers
      final steps = await ref.read(todaysStepsProvider.future);
      // Add other health metrics as available

      return {
        'steps': steps,
        'heart_rate': 0, // Add when available
        'sleep_hours': 0, // Add when available
        'calories': 0, // Add when available
      };
    } catch (e) {
      return {
        'steps': 0,
        'heart_rate': 0,
        'sleep_hours': 0,
        'calories': 0,
      };
    }
  }

  String _extractMessageContent(Map<String, dynamic> message) {
    final content = message['content'] as List<dynamic>?;
    if (content != null && content.isNotEmpty) {
      final firstContent = content.first as Map<String, dynamic>;
      if (firstContent['type'] == 'text') {
        final text = firstContent['text'] as Map<String, dynamic>;
        return text['value'] as String;
      }
    }
    return 'No content available';
  }

  void clearMessages() {
    state = [];
    ref.read(currentThreadProvider.notifier).state = null;
  }
}
