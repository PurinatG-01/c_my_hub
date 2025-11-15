import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/data_card.dart';
import '../domain/health_providers.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to steps provider state changes at widget level for proper registration
    ref.listen<AsyncValue<int>>(todaysStepsProvider, (previous, next) {
      next.when(
        data: (data) {
          // Dismiss loading SnackBar when data loads successfully
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        loading: () {
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
                  Text('Loading steps data...'),
                ],
              ),
              duration: Duration(seconds: 30),
            ),
          );
        },
        error: (error, stack) {
          // Show error SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading steps: $error')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Fallback to dashboard
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final stepsAsync = ref.watch(todaysStepsProvider);

                  return stepsAsync.when(
                    data: (steps) => ListView(
                      children: [
                        DataCard(
                          icon: Icons.directions_walk,
                          label: 'Steps Today',
                          value: steps.toString(),
                        ),
                        const SizedBox(height: 8),
                        const DataCard(
                          icon: Icons.favorite,
                          label: 'Heart Rate',
                          value: 'Not Available',
                        ),
                        const SizedBox(height: 8),
                        const DataCard(
                          icon: Icons.local_fire_department,
                          label: 'Calories Burned',
                          value: 'Not Available',
                        ),
                        const SizedBox(height: 8),
                        const DataCard(
                          icon: Icons.bedtime,
                          label: 'Sleep Hours',
                          value: 'Not Available',
                        ),
                        const SizedBox(height: 16),

                        // Placeholder for future features
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Insights',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Personalized health recommendations will appear here based on your data patterns.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement AI chat feature
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('AI Chat coming soon!'),
                                      ),
                                    );
                                  },
                                  child: const Text('Chat with AI Assistant'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                          Text('Error loading health data: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final _ = ref.refresh(todaysStepsProvider);
                            },
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
    );
  }
}
