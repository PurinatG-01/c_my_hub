import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_service.dart';

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

// Sleep Duration Provider
final sleepDurationProvider = FutureProvider<Duration?>((ref) async {
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
  ]);

  return HealthDashboardData(
    steps: results[0] as int,
    heartRate: results[1] as double?,
    calories: results[2] as double?,
    sleepDuration: results[3] as Duration?,
  );
});

// Health Dashboard Data Model
class HealthDashboardData {
  final int steps;
  final double? heartRate;
  final double? calories;
  final Duration? sleepDuration;

  HealthDashboardData({
    required this.steps,
    this.heartRate,
    this.calories,
    this.sleepDuration,
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
    final hours = sleepDuration!.inHours;
    final minutes = (sleepDuration!.inMinutes % 60);
    return '${hours}h ${minutes}m';
  }
}
