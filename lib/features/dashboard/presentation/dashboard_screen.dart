import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/data_card.dart';
import '../../../features/health/domain/health_providers.dart';
import '../../../core/router/routes.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings when created
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Your Health Hub',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your health data and get personalized insights',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick stats
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final stepsAsync = ref.watch(todaysStepsProvider);

                  return stepsAsync.when(
                    data: (steps) => SingleChildScrollView(
                      child: Column(
                        children: [
                          DataCard(
                            icon: Icons.directions_walk,
                            label: 'Today\'s Steps',
                            value: steps.toString(),
                            onTap: () => context.go(Routes.health),
                          ),
                          const SizedBox(height: 8),
                          // Placeholder cards for future health metrics
                          DataCard(
                            icon: Icons.favorite,
                            label: 'Heart Rate',
                            value: 'Coming Soon',
                            onTap: () => context.go(Routes.health),
                          ),
                          const SizedBox(height: 8),
                          DataCard(
                            icon: Icons.local_fire_department,
                            label: 'Calories',
                            value: 'Coming Soon',
                            onTap: () => context.go(Routes.health),
                          ),
                          const SizedBox(height: 8),
                          DataCard(
                            icon: Icons.bedtime,
                            label: 'Sleep',
                            value: 'Coming Soon',
                            onTap: () => context.go(Routes.health),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.refresh(todaysStepsProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Routes.health),
        icon: const Icon(Icons.health_and_safety),
        label: const Text('View Health Data'),
      ),
    );
  }
}
