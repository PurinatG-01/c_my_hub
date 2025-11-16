import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock service for testing without OpenAI API key
class MockOpenAIService {
  static const List<String> healthResponses = [
    "Based on your recent health data, I can see you're making great progress! Your step count has been consistently above average this week. Keep up the excellent work! 🏃‍♂️",
    "I notice your activity levels tend to drop on weekends. Consider planning some fun outdoor activities like hiking or cycling with friends to stay active during leisure time! 🚴‍♀️",
    "Your current step trend shows steady improvement. I recommend setting a new goal of 8,500 daily steps to continue challenging yourself. Would you like me to help you create a plan to reach this goal? 📈",
    "Let me analyze your health metrics:\n\n📊 Steps: Trending upward (+15% this week)\n💓 Heart Rate: Within healthy range\n😴 Sleep: Could use improvement\n\nRecommendation: Focus on establishing a consistent sleep schedule for better recovery! 💤",
    "Great question about your fitness progress! Looking at your data patterns, I can see significant improvement in your daily activity. Your consistency has increased by 40% over the past month. That's fantastic dedication! 🎉",
  ];

  static const List<String> motivationalTips = [
    "Remember: Every step counts! Small consistent actions lead to big results over time. 💪",
    "Tip of the day: Try taking a 5-minute walk after each meal. It's great for digestion and adds extra steps to your daily count! 🚶‍♀️",
    "Did you know? People who track their health data are 40% more likely to reach their fitness goals. You're already on the right path! 📱",
    "Health insight: The best workout is the one you actually do consistently. Find activities you enjoy, and fitness won't feel like work! 🎯",
    "Quick tip: Set a daily reminder to check your health stats. Regular monitoring helps you stay aware and motivated! ⏰",
  ];

  Future<String> sendMessage(String message) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    final lowerMessage = message.toLowerCase();

    // Smart response based on message content
    if (lowerMessage.contains('progress') ||
        lowerMessage.contains('how am i doing')) {
      return healthResponses[
          DateTime.now().millisecond % healthResponses.length];
    } else if (lowerMessage.contains('goal') ||
        lowerMessage.contains('target')) {
      return "I'd love to help you set a new health goal! Based on your current activity level, I can suggest realistic targets that will challenge you without being overwhelming. What type of goal interests you most - steps, exercise frequency, or sleep improvement? 🎯";
    } else if (lowerMessage.contains('tip') ||
        lowerMessage.contains('advice')) {
      return motivationalTips[
          DateTime.now().millisecond % motivationalTips.length];
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! I'm your AI Health Assistant. I'm here to help you understand your health data, set goals, and stay motivated on your wellness journey. What would you like to know about your health today? 😊";
    } else if (lowerMessage.contains('data') ||
        lowerMessage.contains('stats')) {
      return "Here's what I can tell you about your health data:\n\n📱 I have access to your step count, heart rate, and activity patterns\n📊 I can analyze trends over days, weeks, and months\n💡 I provide personalized insights based on your unique patterns\n🎯 I can help you set and track meaningful health goals\n\nWhat specific aspect would you like me to analyze?";
    } else {
      return "That's an interesting question! As your health assistant, I'm designed to help with fitness tracking, goal setting, and wellness insights. I can analyze your activity patterns, suggest improvements, and provide motivation to keep you on track with your health journey. How can I specifically help you today? 🤖💚";
    }
  }
}

// Simplified provider for the demo
final mockAIServiceProvider = Provider<MockOpenAIService>((ref) {
  return MockOpenAIService();
});

final demoMessagesProvider =
    StateNotifierProvider<DemoMessagesNotifier, List<DemoMessage>>((ref) {
  return DemoMessagesNotifier(ref);
});

class DemoMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  DemoMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });
}

class DemoMessagesNotifier extends StateNotifier<List<DemoMessage>> {
  final Ref ref;

  DemoMessagesNotifier(this.ref)
      : super([
          DemoMessage(
            id: 'welcome',
            content: '''Hello! I'm your AI Health Assistant 🤖💚

I can help you with:
• 📊 Analyzing your health data
• 🎯 Setting realistic fitness goals  
• 💡 Providing personalized insights
• 🏃‍♂️ Tracking your progress
• 💪 Staying motivated

Try asking me:
- "How is my progress this week?"
- "Help me set a new goal"
- "Give me a health tip"
- "Show me my data insights"

What would you like to know about your health today?''',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
          ),
        ]);

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = DemoMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add user message
    state = [...state, userMessage];

    // Add typing indicator
    final typingMessage = DemoMessage(
      id: 'typing',
      content: '...',
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
    );
    state = [...state, typingMessage];

    try {
      // Get AI response
      final aiService = ref.read(mockAIServiceProvider);
      final response = await aiService.sendMessage(message);

      // Remove typing indicator
      state = state.where((msg) => msg.id != 'typing').toList();

      // Add AI response
      final aiMessage = DemoMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, aiMessage];
    } catch (e) {
      // Remove typing indicator
      state = state.where((msg) => msg.id != 'typing').toList();

      // Add error message
      final errorMessage = DemoMessage(
        id: 'error',
        content: 'Sorry, I encountered an error. Please try again! 😅',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    }
  }

  void clearMessages() {
    state = [state.first]; // Keep welcome message
  }
}
