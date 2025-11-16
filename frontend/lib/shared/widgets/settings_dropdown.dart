import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';

/// Settings dropdown widget that provides theme switching and other configuration options
class SettingsDropdown extends ConsumerWidget {
  const SettingsDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      tooltip: 'Settings',
      onSelected: (String value) {
        // Handle menu item selection
        switch (value) {
          case 'theme':
            _showThemeDialog(context, ref);
            break;
          case 'about':
            _showAboutDialog(context);
            break;
          case 'feedback':
            _showFeedbackSnackbar(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'theme',
          child: ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme Settings'),
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'about',
          child: ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            dense: true,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'feedback',
          child: ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Send Feedback'),
            dense: true,
          ),
        ),
      ],
    );
  }

  /// Show theme selection dialog
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemeMode.values.map((themeMode) {
              return RadioListTile<AppThemeMode>(
                title: Row(
                  children: [
                    Icon(themeMode.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(themeMode.displayName),
                  ],
                ),
                value: themeMode,
                groupValue: currentTheme,
                onChanged: (AppThemeMode? value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'C My Hub',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.health_and_safety,
          color: Colors.white,
          size: 24,
        ),
      ),
      children: [
        const Text(
            'A comprehensive health tracking application built with Flutter.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Health data tracking and visualization'),
        const Text('• Activity monitoring'),
        const Text('• Customizable themes'),
        const Text('• Cross-platform support'),
      ],
    );
  }

  /// Show feedback snackbar
  void _showFeedbackSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.feedback, color: Colors.white),
            SizedBox(width: 12),
            Text('Feedback feature coming soon!'),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Quick theme switcher widget for easy access
class QuickThemeSwitcher extends ConsumerWidget {
  const QuickThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return IconButton(
      icon: Icon(currentTheme.icon),
      tooltip: 'Switch Theme (${currentTheme.displayName})',
      onPressed: () {
        final nextTheme = _getNextTheme(currentTheme);
        ref.read(themeProvider.notifier).setThemeMode(nextTheme);

        // Show a brief feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${nextTheme.displayName} theme'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  /// Get the next theme in the cycle (Light -> Dark -> System -> Light)
  AppThemeMode _getNextTheme(AppThemeMode current) {
    switch (current) {
      case AppThemeMode.light:
        return AppThemeMode.dark;
      case AppThemeMode.dark:
        return AppThemeMode.system;
      case AppThemeMode.system:
        return AppThemeMode.light;
    }
  }
}
