class AppConstants {
  // Demo health data for testing on unsupported platforms
  static const int demoStepCount = 8547;
  static const double demoHeartRate = 72.0;
  static const double demoCalories = 320.5;
  static const Duration demoSleepDuration = Duration(hours: 7, minutes: 30);

  // API endpoints (for future AI integration)
  static const String aiApiBaseUrl = 'https://api.example.com';

  // Health data refresh intervals
  static const Duration healthDataRefreshInterval = Duration(minutes: 5);

  // App information
  static const String appName = 'C My Hub';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Personal Health Tracking & AI Assistant';
}

class HealthDataKeys {
  static const String steps = 'steps';
  static const String heartRate = 'heart_rate';
  static const String calories = 'calories';
  static const String sleep = 'sleep';
  static const String weight = 'weight';
  static const String bloodPressure = 'blood_pressure';
}

class RouteNames {
  static const String dashboard = 'dashboard';
  static const String health = 'health';
  static const String healthDetails = 'health_details';
  static const String aiChat = 'ai_chat';
  static const String settings = 'settings';
  static const String profile = 'profile';
}
