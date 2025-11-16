# C My Hub - Application Structure

## Overview

C My Hub is a Flutter-based health tracking application that provides comprehensive health data visualization and management. The app follows a clean architecture pattern with feature-based organization and uses modern Flutter development practices.

## Project Information

- **Name**: c_my_hub
- **Description**: A new Flutter project focused on health tracking
- **Version**: 1.0.0+1
- **Flutter SDK**: ^3.5.4

## Architecture Pattern

### Clean Architecture Implementation

The application follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/           # Core application infrastructure
├── features/       # Feature-based modules
├── shared/         # Shared components and utilities
├── service/        # Global services
└── main.dart       # Application entry point
```

## Directory Structure

### 1. Core (`lib/core/`)

Contains fundamental application infrastructure:

```
core/
├── constants/      # Application constants
├── router/        # Navigation and routing
│   ├── app_router.dart     # GoRouter configuration
│   └── routes.dart         # Route definitions
└── theme/         # UI theming
    └── app_theme.dart      # Material theme configuration
```

### 2. Features (`lib/features/`)

Feature-based modules implementing business logic:

```
features/
├── dashboard/
│   └── presentation/
│       └── dashboard_screen.dart    # Main dashboard UI
└── health/
    ├── data/
    │   └── health_service.dart      # Health data service layer
    ├── domain/
    │   └── health_providers.dart    # Riverpod state providers
    └── presentation/
        └── health_screen.dart       # Health data display UI
```

### 3. Shared (`lib/shared/`)

Reusable components across features:

```
shared/
├── utils/          # Utility functions and helpers
└── widgets/        # Reusable UI components
    ├── activity_card.dart          # Activity display card
    ├── data_card.dart             # Generic data display card
    ├── health_summary_card.dart    # Comprehensive health overview
    ├── main_navigation.dart        # Navigation components
    └── progress_ring.dart          # Circular progress indicator
```

### 4. Service (`lib/service/`)

Global application services:

```
service/
└── health_service.dart    # Singleton health data service
```

## Key Dependencies

### Core Framework

- **Flutter**: Core framework for mobile-first development
- **Dart**: Programming language (SDK ^3.5.4)

### State Management

- **flutter_riverpod**: ^2.6.1 - Reactive state management solution
- **Provider pattern**: Used for dependency injection and state sharing

### Navigation

- **go_router**: ^14.6.1 - Declarative routing solution
- **Navigation 2.0**: Modern Flutter navigation API

### Health Integration

- **health**: ^13.2.1 - Native health data integration
- **Platform support**: iOS HealthKit, Android Health Connect

### UI/UX

- **cupertino_icons**: ^1.0.8 - iOS-style icons
- **Material Design 3**: Modern Material Design system

### Utilities

- **equatable**: ^2.0.5 - Value equality comparisons
- **json_annotation**: ^4.9.0 - JSON serialization support

## Application Flow

### 1. App Initialization (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize health service with error handling
  await HealthService().init();

  // Launch app with Riverpod state management
  runApp(ProviderScope(child: MyApp()));
}
```

### 2. Navigation Structure

```
Dashboard (/)
    ↓ [push navigation]
Health Data (/health)
    ↓ [pop navigation]
Dashboard (/)
```

### 3. State Management Flow

```
HealthService (Singleton)
    ↓ [data fetching]
Riverpod Providers
    ↓ [state management]
Consumer Widgets
    ↓ [UI updates]
User Interface
```

## Feature Breakdown

### Dashboard Feature

- **Location**: `lib/features/dashboard/`
- **Purpose**: Main application entry point with health overview
- **Key Components**:
  - Time-based greetings (Morning/Afternoon/Evening)
  - Health summary card with progress rings
  - Quick stats grid (steps, distance, active time)
  - Recent activities timeline
  - Navigation to detailed health views

### Health Feature

- **Location**: `lib/features/health/`
- **Purpose**: Detailed health data management and display
- **Architecture Layers**:
  - **Data Layer**: Health service integration with native platforms
  - **Domain Layer**: Business logic and state providers
  - **Presentation Layer**: UI components and screens
- **Health Metrics**:
  - Daily steps with goal tracking
  - Heart rate monitoring
  - Calories burned tracking
  - Sleep duration analysis
  - Weekly averages and trends
  - Distance and active time

## UI Components

### Custom Widgets

1. **HealthSummaryCard**: Comprehensive health overview with progress ring
2. **ActivityCard**: Timeline display for recent activities
3. **DataCard**: Generic metric display with navigation
4. **ProgressRing**: Custom circular progress indicator
5. **Loading/Error States**: Graceful state handling

### Design System

- **Material Design 3**: Modern design language
- **Consistent Spacing**: 8px/16px/20px spacing system
- **Color Coding**:
  - 🟢 Green: Goals achieved
  - 🟠 Orange: In progress
  - 🔵 Blue: Getting started
- **Typography**: Theme-based text styles
- **Elevation**: Consistent card elevation system

## Data Management

### Health Service Architecture

```dart
HealthService (Singleton)
├── Platform Integration (iOS HealthKit / Android Health Connect)
├── Data Caching (In-memory caching for performance)
├── Error Handling (Demo data fallbacks)
└── Multiple Health Metrics:
    ├── Steps and goals
    ├── Heart rate
    ├── Calories burned
    ├── Sleep duration
    ├── Distance tracking
    └── Active minutes
```

### State Providers

- **healthDashboardDataProvider**: Combined health metrics
- **todaysStepsProvider**: Daily step count
- **heartRateProvider**: Latest heart rate
- **caloriesProvider**: Daily calories burned
- **sleepDurationProvider**: Sleep tracking
- **weeklyStepAverageProvider**: Weekly trends
- **distanceTodayProvider**: Daily distance
- **activeMinutesProvider**: Exercise time

## Platform Support

### Supported Platforms

- ✅ **iOS**: Full HealthKit integration with native health data access
- ✅ **Android**: Health Connect support for comprehensive health tracking

### Platform-Specific Features

- **iOS**: Native HealthKit data access, background health monitoring
- **Android**: Health Connect API integration, fitness tracking permissions
- **Mobile-Optimized**: Designed specifically for smartphone health sensors and APIs

## Development Setup

### Prerequisites

- Flutter SDK ^3.5.4
- Dart SDK (included with Flutter)
- iOS: Xcode and iOS Simulator
- Android: Android Studio and Android SDK

### Key Commands

```bash
# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run on connected device
flutter run

# Build for production
flutter build ios
flutter build apk
```

### VS Code Debugging Setup

The project includes a comprehensive `.vscode/launch.json` configuration for efficient debugging across all platforms. Access these configurations through the VS Code Debug panel (`Cmd+Shift+D` on macOS).

#### Available Debug Configurations:

**Basic Flutter Modes:**

- **Flutter: Debug** - Standard debug mode for active development
- **Flutter: Profile** - Performance profiling mode for optimization
- **Flutter: Release** - Production release mode testing

**Platform-Specific Debugging:**

- **Flutter: Debug (iOS Simulator)** - Target iOS simulator specifically
- **Flutter: Debug (Android Emulator)** - Target Android emulator

- **Flutter: Debug (macOS)** - Native macOS desktop app debugging

**Testing Configurations:**

- **Flutter: Test (Current File)** - Debug the currently open test file
- **Flutter: Integration Tests** - Run integration tests with special flags
- **Dart: Debug (Console)** - Debug pure Dart files in terminal

**Advanced Configuration:**

- **Flutter: Debug with Custom Entry Point** - Includes custom environment variables and API endpoints for different environments

**Compound Configuration:**

- **Flutter: Debug All Platforms** - Simultaneously debug on iOS and Android

#### Debug Features:

- **Breakpoint Support**: Full breakpoint functionality across all platforms
- **Hot Reload**: Instant code changes during debug sessions
- **Variable Inspection**: Real-time variable watching and evaluation
- **Call Stack Navigation**: Step through code execution paths
- **Console Output**: Integrated debug console with Flutter logs
- **Environment Variables**: Custom dart-define variables for different build environments
- **Mobile-First Support**: Optimized debugging for iOS and Android development

#### Quick Start Debugging:

1. Open VS Code Debug panel (`Cmd+Shift+D`)
2. Select desired configuration from dropdown
3. Set breakpoints by clicking line numbers
4. Press `F5` or click the green play button
5. Use debug controls for step-over, step-into, continue, etc.

## Documentation Files

- `DASHBOARD_FEATURES.md`: Detailed dashboard functionality
- `DASHBOARD_ARCHITECTURE.md`: Technical architecture diagrams
- `DASHBOARD_CUSTOMIZATION.md`: Customization and extension guide
- `NAVIGATION_FIX.md`: Navigation implementation details

## Future Roadmap

- AI-powered health insights
- Social features and sharing
- Wearable device integration
- Advanced analytics and trends
- Goal setting and achievements
- Notification system
- Data export capabilities
