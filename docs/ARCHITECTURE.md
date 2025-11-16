# C My Hub - Application Architecture

## Overview

C My Hub is a Flutter-based health tracking application built using a modern and scalable architecture. This document outlines the project's structure, data flow, and key design patterns.

## 🏗️ Clean Architecture

The application follows the principles of **Clean Architecture**, ensuring a clear separation of concerns between the UI, business logic, and data layers. This makes the codebase easier to maintain, test, and scale.

The project is organized into the following top-level directories:

```
lib/
├── core/           # Core application infrastructure (routing, theme, constants)
├── features/       # Individual, self-contained feature modules
├── service/        # Global services (e.g., HealthService)
├── shared/         # Widgets and utilities shared across features
└── main.dart       # Application entry point
```

### Directory Structure Breakdown

-   **`core/`**: Contains the application's foundational code.
    -   `router/`: `go_router` configuration and route definitions.
    -   `theme/`: Application themes (light/dark) and the theme provider.
    -   `constants/`: App-wide constants.
-   **`features/`**: Each feature is a self-contained module with its own data, domain, and presentation layers.
    -   `dashboard/`: The main dashboard screen.
    -   `health/`: Detailed health data views.
    -   `ai_assistant/`: The AI health coach feature.
-   **`service/`**: Houses global services that can be accessed from anywhere in the app. The `HealthService` is a key example.
-   **`shared/`**: Contains reusable components, such as custom widgets (`DataCard`, `ProgressRing`) and utility functions.

## 📊 Data Flow and State Management

The application uses **`flutter_riverpod`** for state management, which allows for a reactive and predictable data flow.

### Health Data Flow Example:

1.  **`HealthService`**: A singleton service that interfaces directly with the `health` package to fetch data from Apple Health (HealthKit) and Android's Health Connect. It includes logic for requesting permissions, fetching data types, and handling errors with demo data fallbacks.

2.  **Riverpod Providers**: Providers expose the data from the `HealthService` to the UI. They also handle caching and automatically refetching data when needed.
    ```dart
    // Example: Provider for today's step count
    final todaysStepsProvider = FutureProvider<int>((ref) async {
      final healthService = ref.read(healthServiceProvider);
      return await healthService.getTodaysSteps();
    });
    ```

3.  **Consumer Widgets**: Widgets listen to these providers and automatically rebuild when the data changes, ensuring the UI is always up-to-date.
    ```dart
    // Example: A widget displaying the step count
    class StepsDisplay extends ConsumerWidget {
      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final stepsAsync = ref.watch(todaysStepsProvider);
        return stepsAsync.when(
          data: (steps) => Text('Steps: $steps'),
          loading: () => CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        );
      }
    }
    ```

## 📱 Dashboard Component Structure

The dashboard is the main screen of the application and is composed of several reusable widgets.

```
DashboardScreen (ConsumerWidget)
├── AppBar (with Theme Switcher and Settings)
└── RefreshIndicator
    └── SingleChildScrollView
        ├── _GreetingSection (e.g., "Good Morning")
        ├── HealthSummaryCard (The main card with the progress ring)
        │   ├── ProgressRing (Custom-painted widget for steps)
        │   └── _MetricTile (For Heart Rate, Calories, Sleep)
        ├── Quick Stats Grid (2-column grid)
        │   ├── DataCard (for Distance)
        │   ├── DataCard (for Active Time)
        │   └── DataCard (for Weekly Average)
        └── ActivityCard (Timeline of recent activities)
```

-   **`HealthSummaryCard`**: The primary component, showing the most important information at a glance.
-   **`DataCard`**: A reusable widget for displaying a single metric with an icon and label.
-   **`ActivityCard`**: A timeline-style card for showing recent workouts.

## 🎨 UI and Theming

-   **Material Design 3**: The app uses the latest Material Design system.
-   **Custom Themes**: The `core/theme/` directory contains definitions for both a light and a dark theme, with a consistent green, health-focused color palette.
-   **Theme Provider**: A `StateNotifierProvider` (`themeProvider`) manages the current theme and persists the user's choice using `shared_preferences`.

## 🧭 Navigation

-   **`go_router`**: A declarative routing package that simplifies navigation.
-   **Route Definitions**: All routes are defined in `core/router/routes.dart`.
-   **Navigation Methods**:
    -   `context.push('/path')`: Used for navigating to a detail screen (pushing it onto the stack).
    -   `context.go('/path')`: Used for navigating to a main screen (replacing the stack).
    -   `context.pop()`: Used to return to the previous screen.

This architecture provides a solid foundation for building a robust and maintainable health and fitness application.
