import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../service/health_service.dart';

// Health Service Provider
final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

// Today's Steps Provider
final todaysStepsProvider = FutureProvider<int>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getSteps();
});

// Heart Rate Provider
final heartRateProvider = FutureProvider<double?>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getHeartRate();
});

// Calories Provider
final caloriesProvider = FutureProvider<double?>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getCalories();
});

// Sleep Duration Provider (returns hours as double)
final sleepDurationProvider = FutureProvider<double?>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getSleepDuration();
});

// Health Data Refresh Provider - for manual refresh
final healthDataRefreshProvider = StateProvider<int>((ref) => 0);

// Combined Health Dashboard Data Provider
final healthDashboardDataProvider =
    FutureProvider<HealthDashboardData>((ref) async {
  // Watch the refresh provider to trigger refresh
  ref.watch(healthDataRefreshProvider);
  final healthService = ref.read(healthServiceProvider);

  final results = await Future.wait([
    healthService.getSteps(),
    healthService.getHeartRate(),
    healthService.getCalories(),
    healthService.getSleepDuration(),
    healthService.getWeeklyStepAverage(),
    healthService.getDistanceToday(),
    healthService.getActiveMinutesToday(),
  ]);
  await Future.delayed(const Duration(seconds: 5)); // Simulate delay
  return HealthDashboardData(
    steps: results[0] as int,
    heartRate: results[1] as double?,
    calories: results[2] as double?,
    sleepDuration: results[3] as double?,
    weeklyStepAverage: results[4] as double?,
    distance: results[5] as double?,
    activeMinutes: results[6] as int?,
  );
});

// Additional Health Data Providers
final weeklyStepAverageProvider = FutureProvider<double>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getWeeklyStepAverage();
});

final distanceTodayProvider = FutureProvider<double?>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getDistanceToday();
});

final activeMinutesProvider = FutureProvider<int?>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getActiveMinutesToday();
});

// Health Dashboard Data Model
class HealthDashboardData {
  final int steps;
  final double? heartRate;
  final double? calories;
  final double? sleepDuration; // Changed to double (hours)
  final double? weeklyStepAverage;
  final double? distance;
  final int? activeMinutes;

  HealthDashboardData({
    required this.steps,
    this.heartRate,
    this.calories,
    this.sleepDuration,
    this.weeklyStepAverage,
    this.distance,
    this.activeMinutes,
  });

  // Helper methods
  String get formattedCalories {
    if (calories == null) return 'N/A';
    return '${calories!.toStringAsFixed(0)} kcal';
  }

  String get formattedHeartRate {
    if (heartRate == null) return 'N/A';
    return '${heartRate!.toStringAsFixed(0)} bpm';
  }

  String get formattedSleepDuration {
    if (sleepDuration == null) return 'N/A';
    return '${sleepDuration!.toStringAsFixed(1)}h';
  }

  String get formattedDistance {
    if (distance == null) return 'N/A';
    final km = distance! / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  String get formattedActiveMinutes {
    if (activeMinutes == null) return 'N/A';
    return '${activeMinutes!} min';
  }
}
