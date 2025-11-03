import 'package:flutter/material.dart';

/// A card widget for displaying activity data and insights
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.title,
    required this.activities,
    this.onViewAll,
  });

  final String title;
  final List<ActivityItem> activities;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
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
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Activities list
            if (activities.isEmpty)
              _EmptyState()
            else
              Column(
                children: activities.take(3).map((activity) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _ActivityTile(activity: activity),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  activity.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: activity.color,
                ),
              ),
              if (activity.unit != null)
                Text(
                  activity.unit!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No recent activities',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            'Start tracking your workouts!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for activity items
class ActivityItem {
  const ActivityItem({
    required this.name,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    this.unit,
  });

  final String name;
  final String subtitle;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;
}

/// Predefined activity items for demonstration
class ActivityItems {
  static List<ActivityItem> getSampleActivities() {
    return [
      const ActivityItem(
        name: 'Morning Walk',
        subtitle: '7:30 AM - 30 min',
        value: '2.1',
        unit: 'km',
        icon: Icons.directions_walk,
        color: Colors.green,
      ),
      const ActivityItem(
        name: 'Gym Workout',
        subtitle: '6:00 PM - 45 min',
        value: '320',
        unit: 'kcal',
        icon: Icons.fitness_center,
        color: Colors.orange,
      ),
      const ActivityItem(
        name: 'Cycling',
        subtitle: '12:00 PM - 20 min',
        value: '5.3',
        unit: 'km',
        icon: Icons.directions_bike,
        color: Colors.blue,
      ),
    ];
  }
}
