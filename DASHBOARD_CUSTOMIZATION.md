# Health Dashboard - Customization Guide

## Adding New Health Metrics

### 1. Add to HealthService

```dart
// In lib/features/health/data/health_service.dart
Future<double?> getBloodPressure() async {
  try {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
      types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
      startTime: startOfDay,
      endTime: now,
    );

    if (healthData.isNotEmpty) {
      final latest = healthData.last.value;
      if (latest is NumericHealthValue) {
        return latest.numericValue.toDouble();
      }
    }
    return null;
  } catch (e) {
    print('Error getting blood pressure: $e');
    return 120.0; // Demo value
  }
}
```

### 2. Add Provider

```dart
// In lib/features/health/domain/health_providers.dart
final bloodPressureProvider = FutureProvider<double?>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getBloodPressure();
});
```

### 3. Add to Dashboard

```dart
// In dashboard_screen.dart, add to the grid
Consumer(
  builder: (context, ref, child) {
    final bpAsync = ref.watch(bloodPressureProvider);
    return bpAsync.when(
      data: (bp) => DataCard(
        icon: Icons.monitor_heart,
        label: 'Blood Pressure',
        value: bp != null ? '${bp.toInt()} mmHg' : 'N/A',
      ),
      loading: () => const _LoadingDataCard('Blood Pressure'),
      error: (_, __) => const DataCard(
        icon: Icons.monitor_heart,
        label: 'Blood Pressure',
        value: 'N/A',
      ),
    );
  },
),
```

## Customizing Visual Appearance

### 1. Changing Colors

```dart
// Modify progress ring colors in HealthSummaryCard
Color _getStepsProgressColor(double progress) {
  if (progress >= 1.0) return Colors.purple;  // Custom goal color
  if (progress >= 0.7) return Colors.amber;   // Custom warning color
  return Colors.teal;                         // Custom start color
}
```

### 2. Custom Step Goals

```dart
// Add goal provider
final stepGoalProvider = StateProvider<int>((ref) => 10000);

// Use in dashboard
Consumer(
  builder: (context, ref, child) {
    final goal = ref.watch(stepGoalProvider);
    final healthData = ref.watch(healthDashboardDataProvider);

    return healthData.when(
      data: (data) => HealthSummaryCard(
        steps: data.steps,
        stepsGoal: goal,  // Use custom goal
        // ... other params
      ),
      // ... other states
    );
  },
),
```

### 3. Custom Activity Types

```dart
// Add new activity types to ActivityItems
static List<ActivityItem> getCustomActivities() {
  return [
    const ActivityItem(
      name: 'Swimming',
      subtitle: '6:00 AM - 45 min',
      value: '2000',
      unit: 'meters',
      icon: Icons.pool,
      color: Colors.cyan,
    ),
    const ActivityItem(
      name: 'Yoga',
      subtitle: '7:30 PM - 30 min',
      value: '150',
      unit: 'kcal',
      icon: Icons.self_improvement,
      color: Colors.purple,
    ),
  ];
}
```

## Adding Real-Time Updates

### 1. Periodic Data Refresh

```dart
// Add to main.dart or app initialization
Timer.periodic(const Duration(minutes: 5), (timer) {
  // Refresh health data every 5 minutes
  ref.invalidate(healthDashboardDataProvider);
});
```

### 2. Background Refresh

```dart
// Add background app lifecycle listener
class _HealthDataRefreshListener extends WidgetsBindingObserver {
  final WidgetRef ref;

  _HealthDataRefreshListener(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      ref.invalidate(healthDashboardDataProvider);
    }
  }
}
```

## Performance Optimization

### 1. Caching Health Data

```dart
// Add caching to health service
class HealthService {
  final Map<String, CachedData> _cache = {};

  Future<int> getSteps() async {
    final cacheKey = 'steps_${DateTime.now().day}';

    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < Duration(minutes: 5)) {
        return cached.data as int;
      }
    }

    final steps = await _fetchSteps(); // Your existing logic
    _cache[cacheKey] = CachedData(steps, DateTime.now());
    return steps;
  }
}

class CachedData {
  final dynamic data;
  final DateTime timestamp;

  CachedData(this.data, this.timestamp);
}
```

### 2. Lazy Loading

```dart
// Load data only when needed
final lazyHealthDataProvider = FutureProvider.autoDispose<HealthDashboardData>((ref) async {
  // Auto-dispose when not needed
  final healthService = ref.read(healthServiceProvider);
  return await healthService.getComprehensiveHealthData();
});
```

## Adding Charts and Visualizations

### 1. Add fl_chart dependency

```yaml
# In pubspec.yaml
dependencies:
  fl_chart: ^0.68.0
```

### 2. Create Weekly Steps Chart

```dart
import 'package:fl_chart/fl_chart.dart';

class WeeklyStepsChart extends StatelessWidget {
  final List<double> weeklyData;

  const WeeklyStepsChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: weeklyData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
```

## Adding Notifications

### 1. Goal Achievement Notifications

```dart
// Add to health providers
class HealthNotificationService {
  static void checkGoalAchievement(int steps, int goal) {
    if (steps >= goal) {
      _showNotification('🎉 Goal Achieved!', 'You reached your daily step goal of $goal steps!');
    } else if (steps >= goal * 0.8) {
      _showNotification('📈 Almost There!', 'You\'re at 80% of your daily goal. Keep going!');
    }
  }

  static void _showNotification(String title, String body) {
    // Implement notification logic
  }
}
```

This customization guide helps you extend the dashboard with additional features, metrics, and visual enhancements based on your specific needs.
