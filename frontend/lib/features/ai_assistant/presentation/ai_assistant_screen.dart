import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:c_my_hub/features/ai_assistant/data/health_agent_service.dart';

// Providers
final healthAgentServiceProvider = Provider<HealthAgentService>((ref) {
  return HealthAgentService();
});

final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);
final isTypingProvider = StateProvider<bool>((ref) => false);

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // Note: Provider-managed services are disposed automatically by Riverpod
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    _textController.clear();

    // Add user message
    ref.read(chatMessagesProvider.notifier).update((state) => [
          ...state,
          ChatMessage(
            text: message,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        ]);

    ref.read(isTypingProvider.notifier).state = true;

    // Wait a bit for UI update then scroll
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    try {
      final service = ref.read(healthAgentServiceProvider);
      final response = await service.sendMessage(message: message);

      if (!mounted) return;

      ref.read(chatMessagesProvider.notifier).update((state) => [
            ...state,
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ]);

      ref.read(isTypingProvider.notifier).state = false;
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ref.read(chatMessagesProvider.notifier).update((state) => [
            ...state,
            ChatMessage(
              text: 'Error: $e',
              isUser: false,
              timestamp: DateTime.now(),
              isError: true,
            ),
          ]);
      ref.read(isTypingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isTyping = ref.watch(isTypingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(msg, theme);
              },
            ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, ThemeData theme) {
    final isUser = msg.isUser;
    final bubbleColor = isUser
        ? theme.colorScheme.primary
        : msg.isError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerHighest;

    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : msg.isError
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onSurfaceVariant;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: MarkdownBody(
          data: msg.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            strong: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            em: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontStyle: FontStyle.italic,
            ),
            code: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              backgroundColor: isUser
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.surfaceContainer.withOpacity(0.5),
              fontFamily: 'monospace',
            ),
            codeblockDecoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.surfaceContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            blockquote: theme.textTheme.bodyMedium?.copyWith(
              color: textColor.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
            h1: theme.textTheme.headlineSmall?.copyWith(color: textColor),
            h2: theme.textTheme.titleLarge?.copyWith(color: textColor),
            h3: theme.textTheme.titleMedium?.copyWith(color: textColor),
            h4: theme.textTheme.titleSmall?.copyWith(color: textColor),
            h5: theme.textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            h6: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            listBullet: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            listIndent: 16,
            a: theme.textTheme.bodyMedium?.copyWith(
              color: isUser
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          onTapLink: (text, href, title) {
            if (href != null) {
              // Handle link taps - could open in browser
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Link: $href')),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Ask about your health...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _sendMessage,
              mini: true,
              elevation: 0,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
