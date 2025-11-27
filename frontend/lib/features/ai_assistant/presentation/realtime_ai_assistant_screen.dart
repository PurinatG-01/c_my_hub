import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/services/realtime_health_agent_service.dart';

/// Provider for the realtime health agent service
final realtimeHealthAgentServiceProvider =
    Provider<RealtimeHealthAgentService>((ref) {
  final service = RealtimeHealthAgentService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Screen to chat with the AI health assistant using realtime WebSocket connection
class RealtimeAIAssistantScreen extends ConsumerStatefulWidget {
  const RealtimeAIAssistantScreen({super.key});

  @override
  ConsumerState<RealtimeAIAssistantScreen> createState() =>
      _RealtimeAIAssistantScreenState();
}

class _RealtimeAIAssistantScreenState
    extends ConsumerState<RealtimeAIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AssistantMessage> _messages = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    final service = ref.read(realtimeHealthAgentServiceProvider);

    // Listen to messages
    service.messages.listen((message) {
      setState(() {
        // If it's a partial message, update the last assistant message
        if (message.isPartial &&
            _messages.isNotEmpty &&
            _messages.last.role == MessageRole.assistant) {
          _messages.last = AssistantMessage(
            role: message.role,
            content: _messages.last.content + message.content,
            timestamp: message.timestamp,
            isPartial: true,
          );
        } else {
          _messages.add(message);
        }
      });
      _scrollToBottom();
    });

    // Listen to status changes
    service.status.listen((status) {
      setState(() {
        _connectionStatus = status;
      });
    });

    // Start the connection with a unique device ID
    final deviceId = const Uuid().v4();
    debugPrint('Generated device ID: $deviceId');

    try {
      await service.start(deviceId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final service = ref.read(realtimeHealthAgentServiceProvider);
    service.sendMessage(text);

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant (Realtime)'),
        actions: [
          _buildConnectionIndicator(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (_connectionStatus != ConnectionStatus.connected)
            _buildStatusBanner(),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    Color color;
    IconData icon;

    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        color = Colors.green;
        icon = Icons.circle;
        break;
      case ConnectionStatus.connecting:
        color = Colors.orange;
        icon = Icons.circle;
        break;
      case ConnectionStatus.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case ConnectionStatus.disconnected:
        color = Colors.grey;
        icon = Icons.circle;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          _connectionStatus.name,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    String message;
    Color backgroundColor;

    switch (_connectionStatus) {
      case ConnectionStatus.connecting:
        message = 'Connecting to assistant...';
        backgroundColor = Colors.orange.shade100;
        break;
      case ConnectionStatus.error:
        message = 'Connection error. Please try again.';
        backgroundColor = Colors.red.shade100;
        break;
      case ConnectionStatus.disconnected:
        message = 'Disconnected from assistant';
        backgroundColor = Colors.grey.shade200;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: backgroundColor,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Start a conversation with your AI health assistant',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_connectionStatus == ConnectionStatus.connected)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Ask me about:\n• Health metrics and insights\n• Wellness tips\n• Exercise recommendations\n• Nutrition advice',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final canSend = _connectionStatus == ConnectionStatus.connected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: canSend,
              decoration: InputDecoration(
                hintText: canSend
                    ? 'Ask me anything about your health...'
                    : 'Connecting...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: canSend ? (_) => _sendMessage() : null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: canSend ? _sendMessage : null,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AssistantMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isError = message.isError;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.shade100
              : isUser
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser ? Colors.white70 : Colors.black45,
                  ),
                ),
                if (message.isPartial) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUser ? Colors.white70 : Colors.black45,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
