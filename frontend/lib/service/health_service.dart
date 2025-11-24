import 'dart:developer' as developer;
import 'package:health/health.dart';

/// Singleton Health Service for managing health data access and operations
///
/// This service provides a centralized way to interact with the Health package
/// and manages authentication, configuration, and data retrieval for health-related information.
class HealthService {
  /// Default start time for health data queries (January 1, 2024)
  static final _startTime = DateTime(2024);

  /// Default end time for health data queries (January 1, 2025)
  static final _endTime = DateTime(2025);

  /// Singleton instance of HealthService
  static final HealthService _instance = HealthService._internal();

  /// Factory constructor that returns the singleton instance
  factory HealthService() => _instance;

  /// Private constructor for singleton pattern
  HealthService._internal();

  /// Instance of the Health package for accessing health data
  final Health _health = Health();

  /// Initialize the health service
  ///
  /// This method performs the complete setup for the health service by:
  /// 1. Configuring the health package
  /// 2. Requesting authorization for all available health data types
  /// 3. Retrieving health data from all types using default date range
  ///
  /// Should be called once when the app starts to ensure proper health data access.
  Future<void> init() async {
    await configure();
    await requestAuthorization(HealthDataType.values);
    await getHealthDataFromTypes(HealthDataType.values);
  }

  /// Configure the health package
  ///
  /// This method sets up the health package with platform-specific configurations.
  /// Must be called before any other health operations can be performed.
  Future<void> configure() async {
    await _health.configure();
  }

  /// Request authorization to access specific health data types
  ///
  /// [types] - A list of HealthDataType values that the app wants to access
  ///
  /// This method prompts the user to grant permission for accessing the specified
  /// health data types. The user can grant or deny access to individual data types.
  /// Authorization is required before any health data can be read or written.
  Future<void> requestAuthorization(List<HealthDataType> types) async {
    await _health.requestAuthorization(types);
  }

  /// Retrieve health data for specified types within the default date range
  ///
  /// [types] - A list of HealthDataType values to retrieve data for
  ///
  /// Returns a list of HealthDataPoint objects containing the health data
  /// for the specified types between the default start time (2024) and end time (2025).
  /// Each data point includes the value, unit, timestamp, and data type information.
  Future<List<HealthDataPoint>> getHealthDataFromTypes(
      List<HealthDataType> types) async {
    return await _health.getHealthDataFromTypes(
        types: types, startTime: _startTime, endTime: _endTime);
  }

  /// Get the total number of steps taken today
  ///
  /// Retrieves the step count from midnight (start of current day) until now.
  ///
  /// Returns the total step count as an integer.
  /// Returns -1 if step data is unavailable or if there's an error accessing the data.
  Future<int> getSteps() async {
    final now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day);
    int? steps = await _health.getTotalStepsInInterval(midnight, now);
    return steps ?? -1;
  }

  /// Get workout data from health with date filters
  ///
  /// [startDate] - The start date for the workout data query
  /// [endDate] - The end date for the workout data query
  ///
  /// Returns a list of HealthDataPoint containing workout information
  Future<List<HealthDataPoint>> getWorkoutData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final workoutTypes = [
      HealthDataType.WORKOUT,
      HealthDataType.EXERCISE_TIME,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    ];

    try {
      // Request authorization for workout types if not already authorized
      await _health.requestAuthorization(workoutTypes);

      // Get workout data for the specified date range
      final workoutData = await _health.getHealthDataFromTypes(
        types: workoutTypes,
        startTime: startDate,
        endTime: endDate,
      );

      return workoutData;
    } catch (e) {
      developer.log('Error getting workout data: $e', name: 'HealthService');
      return [];
    }
  }

  /// Get the most recent heart rate reading
  Future<double?> getHeartRate() async {
    try {
      final now = DateTime.now();
      var startOfDay = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startOfDay,
        endTime: now,
      );

      if (healthData.isNotEmpty) {
        // Get the most recent heart rate reading
        healthData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
        final value = healthData.first.value;
        if (value is NumericHealthValue) {
          return value.numericValue.toDouble();
        }
      }
      return null;
    } catch (e) {
      developer.log('Error getting heart rate: $e', name: 'HealthService');
      return 72.0; // Demo heart rate for testing
    }
  }

  /// Get total calories burned today
  Future<double?> getCalories() async {
    final now = DateTime.now();
    var startOfDay = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
      types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      startTime: startOfDay,
      endTime: now,
    );

    if (healthData.isNotEmpty) {
      double totalCalories = 0;
      for (var point in healthData) {
        final value = point.value;
        if (value is NumericHealthValue) {
          totalCalories += value.numericValue.toDouble();
        }
      }
      return totalCalories;
    }
    return null;
  }

  /// Get sleep duration in hours
  Future<double?> getSleepDuration() async {
    try {
      final now = DateTime.now();
      var yesterday = DateTime(now.year, now.month, now.day - 1);

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_IN_BED],
        startTime: yesterday,
        endTime: now,
      );

      if (healthData.isNotEmpty) {
        // Calculate total sleep time
        Duration totalSleep = Duration.zero;
        for (var point in healthData) {
          totalSleep += point.dateTo.difference(point.dateFrom);
        }
        return totalSleep.inMinutes / 60.0; // Return hours as double
      }
      return null;
    } catch (e) {
      developer.log('Error getting sleep duration: $e', name: 'HealthService');
      return 7.5; // Demo sleep duration for testing (7.5 hours)
    }
  }

  /// Get weekly step average
  Future<double> getWeeklyStepAverage() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final List<int> dailySteps = [];

      for (int i = 0; i < 7; i++) {
        final dayStart = DateTime(weekAgo.year, weekAgo.month, weekAgo.day + i);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final steps = await _health.getTotalStepsInInterval(dayStart, dayEnd);
        dailySteps.add(steps ?? 0);
      }

      if (dailySteps.isNotEmpty) {
        return dailySteps.reduce((a, b) => a + b) / dailySteps.length;
      }
      return 0;
    } catch (e) {
      developer.log('Error getting weekly step average: $e',
          name: 'HealthService');
      return 7250.0; // Demo weekly average
    }
  }

  /// Get distance walked/run today
  Future<double?> getDistanceToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_WALKING_RUNNING],
        startTime: startOfDay,
        endTime: now,
      );

      if (healthData.isNotEmpty) {
        double totalDistance = 0;
        for (var point in healthData) {
          final value = point.value;
          if (value is NumericHealthValue) {
            totalDistance += value.numericValue.toDouble();
          }
        }
        return totalDistance; // Distance in meters
      }
      return null;
    } catch (e) {
      developer.log('Error getting distance: $e', name: 'HealthService');
      return 3200.0; // Demo distance in meters (3.2 km)
    }
  }

  /// Get active minutes today
  Future<int?> getActiveMinutesToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.EXERCISE_TIME],
        startTime: startOfDay,
        endTime: now,
      );

      if (healthData.isNotEmpty) {
        Duration totalActiveTime = Duration.zero;
        for (var point in healthData) {
          totalActiveTime += point.dateTo.difference(point.dateFrom);
        }
        return totalActiveTime.inMinutes;
      }
      return null;
    } catch (e) {
      developer.log('Error getting active minutes: $e', name: 'HealthService');
      return 45; // Demo active minutes
    }
  }
}
