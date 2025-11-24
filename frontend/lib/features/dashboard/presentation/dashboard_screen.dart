import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/health_summary_card.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../../shared/widgets/settings_dropdown.dart';
import '../../../features/health/domain/health_providers.dart';
import '../../../core/router/routes.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to health data state changes at widget level for proper registration
    ref.listen<AsyncValue<HealthDashboardData>>(healthDashboardDataProvider,
        (previous, next) {
      next.when(
        data: (data) {
          debugPrint("[------ Data ------]");
          // Dismiss any loading SnackBar when data loads successfully
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        loading: () {
          debugPrint("[------ Loading ------]");
          // Show loading SnackBar with animation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Loading health data...'),
                ],
              ),
              duration: Duration(minutes: 1),
            ),
          );
        },
        error: (error, stack) {
          debugPrint("[------ Error ------]");
          // Show error SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Use the refresh provider to properly trigger loading state
              debugPrint("[REFRESH] Incrementing refresh provider");
              ref.read(healthDataRefreshProvider.notifier).state++;
            },
            tooltip: 'Refresh Data',
          ),
          const QuickThemeSwitcher(),
          const SettingsDropdown(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Use the refresh provider to properly trigger loading state
          debugPrint("[REFRESH] Pull to refresh triggered");
          ref.read(healthDataRefreshProvider.notifier).state++;
          // Wait for the provider to complete
          await ref.read(healthDashboardDataProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting section
              Text(
                'Good ${_getGreeting()}, Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Here\'s your health summary for today',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
              ),
              const SizedBox(height: 20),

              // Main health summary card
              Consumer(
                builder: (context, ref, child) {
                  final healthDataAsync =
                      ref.watch(healthDashboardDataProvider);

                  if (healthDataAsync.hasValue && !healthDataAsync.hasError) {
                    final healthData = healthDataAsync.value!;
                    return HealthSummaryCard(
                      steps: healthData.steps,
                      stepsGoal: 10000, // Default goal
                      heartRate: healthData.heartRate,
                      calories: healthData.calories,
                      sleepHours: healthData.sleepDuration,
                      onTap: () => context.push(Routes.health),
                    );
                  }
                  return const _LoadingCard();
                },
              ),

              const SizedBox(height: 20),

              // Quick stats grid
              Consumer(
                builder: (context, ref, child) {
                  final distanceAsync = ref.watch(distanceTodayProvider);
                  final activeMinutesAsync = ref.watch(activeMinutesProvider);
                  final weeklyAverageAsync =
                      ref.watch(weeklyStepAverageProvider);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: distanceAsync.when(
                                data: (distance) => DataCard(
                                  icon: Icons.directions_run,
                                  label: 'Distance',
                                  value: distance != null
                                      ? '${(distance / 1000).toStringAsFixed(1)} km'
                                      : 'N/A',
                                  onTap: () => context.push(Routes.health),
                                ),
                                loading: () =>
                                    const _LoadingDataCard('Distance'),
                                error: (_, __) => const DataCard(
                                  icon: Icons.directions_run,
                                  label: 'Distance',
                                  value: 'N/A',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: activeMinutesAsync.when(
                                data: (minutes) => DataCard(
                                  icon: Icons.fitness_center,
                                  label: 'Active Time',
                                  value:
                                      minutes != null ? '$minutes min' : 'N/A',
                                  onTap: () => context.push(Routes.health),
                                ),
                                loading: () =>
                                    const _LoadingDataCard('Active Time'),
                                error: (_, __) => const DataCard(
                                  icon: Icons.fitness_center,
                                  label: 'Active Time',
                                  value: 'N/A',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: weeklyAverageAsync.when(
                          data: (average) => DataCard(
                            icon: Icons.trending_up,
                            label: 'Weekly Average Steps',
                            value: '${average.toInt()}',
                            onTap: () => context.push(Routes.health),
                          ),
                          loading: () =>
                              const _LoadingDataCard('Weekly Average'),
                          error: (_, __) => const DataCard(
                            icon: Icons.trending_up,
                            label: 'Weekly Average Steps',
                            value: 'N/A',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Recent activities section
              ActivityCard(
                title: 'Recent Activities',
                activities: ActivityItems.getSampleActivities(),
                onViewAll: () => context.push(Routes.health),
              ),

              const SizedBox(height: 20),

              // Quick action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(Routes.health),
                      icon: const Icon(Icons.health_and_safety),
                      label: const Text('View All Health Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              // Extra space for scrolling
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.aiChat),
        icon: const Icon(Icons.smart_toy),
        label: const Text('AI Assistant'),
        tooltip: 'Chat with AI Health Assistant',
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

/// Loading card widget for health summary
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading health data...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading data card for individual metrics
class _LoadingDataCard extends StatelessWidget {
  const _LoadingDataCard(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      icon: Icons.hourglass_empty,
      label: label,
      value: '...',
    );
  }
}
