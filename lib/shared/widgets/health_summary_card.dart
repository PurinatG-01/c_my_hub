import 'package:flutter/material.dart';
import 'progress_ring.dart';

/// A comprehensive health summary card that displays multiple health metrics
class HealthSummaryCard extends StatelessWidget {
  const HealthSummaryCard({
    super.key,
    required this.steps,
    required this.stepsGoal,
    this.heartRate,
    this.calories,
    this.sleepHours,
    this.onTap,
  });

  final int steps;
  final int stepsGoal;
  final double? heartRate;
  final double? calories;
  final double? sleepHours;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final stepsProgress = steps / stepsGoal;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Steps progress section
              Row(
                children: [
                  ProgressRing(
                    progress: stepsProgress,
                    size: 80,
                    strokeWidth: 8,
                    progressColor: _getStepsProgressColor(stepsProgress),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_walk,
                          color: _getStepsProgressColor(stepsProgress),
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(stepsProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Steps',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        Text(
                          '$steps',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Goal: $stepsGoal',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Other health metrics
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.favorite,
                      label: 'Heart Rate',
                      value: heartRate != null
                          ? '${heartRate!.toInt()} bpm'
                          : 'N/A',
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.local_fire_department,
                      label: 'Calories',
                      value: calories != null
                          ? '${calories!.toInt()} kcal'
                          : 'N/A',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.bedtime,
                      label: 'Sleep',
                      value: sleepHours != null
                          ? '${sleepHours!.toStringAsFixed(1)}h'
                          : 'N/A',
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStepsProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.orange;
    return Colors.blue;
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
