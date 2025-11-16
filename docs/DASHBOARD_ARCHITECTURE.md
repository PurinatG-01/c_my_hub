## Health Dashboard - Component Structure

```
DashboardScreen
├── AppBar
│   ├── Title: "Health Dashboard"
│   ├── Refresh Button
│   └── Settings Button
│
├── RefreshIndicator (Pull to refresh)
│   └── SingleChildScrollView
│       ├── Greeting Section
│       │   ├── Time-based greeting (Good Morning/Afternoon/Evening)
│       │   └── Subtitle message
│       │
│       ├── HealthSummaryCard (Main Card)
│       │   ├── Header: "Today's Summary"
│       │   ├── Steps Progress Section
│       │   │   ├── ProgressRing (Circular progress indicator)
│       │   │   ├── Steps count and goal
│       │   │   └── Progress percentage
│       │   │
│       │   └── Health Metrics Row
│       │       ├── Heart Rate tile
│       │       ├── Calories tile
│       │       └── Sleep tile
│       │
│       ├── Quick Stats Grid
│       │   ├── Row 1
│       │   │   ├── Distance DataCard
│       │   │   └── Active Time DataCard
│       │   └── Row 2
│       │       └── Weekly Average DataCard
│       │
│       ├── ActivityCard (Recent Activities)
│       │   ├── Header with "View All" button
│       │   └── Activity List
│       │       ├── Morning Walk tile
│       │       ├── Gym Workout tile
│       │       └── Cycling tile
│       │
│       └── Quick Actions
│           └── "View All Health Data" button
```

## Data Flow

```
HealthService (Singleton)
├── getSteps() → Today's step count
├── getHeartRate() → Latest heart rate reading
├── getCalories() → Today's calories burned
├── getSleepDuration() → Last night's sleep (hours)
├── getWeeklyStepAverage() → 7-day step average
├── getDistanceToday() → Distance walked/run today
└── getActiveMinutesToday() → Active exercise minutes

    ↓

Riverpod Providers
├── healthDashboardDataProvider (Combined data)
├── distanceTodayProvider
├── activeMinutesProvider
└── weeklyStepAverageProvider

    ↓

Consumer Widgets
├── HealthSummaryCard
├── DataCards (Distance, Active Time, Weekly Average)
└── Error/Loading states
```

## Widget Hierarchy

```
DashboardScreen (ConsumerWidget)
├── HealthSummaryCard
│   ├── ProgressRing (Custom painted widget)
│   └── _MetricTile (Internal widget)
│
├── DataCard (Shared widget)
│   ├── Icon container
│   ├── Label and value text
│   └── Arrow indicator
│
├── ActivityCard
│   ├── _ActivityTile (Internal widget)
│   └── _EmptyState (When no activities)
│
├── _LoadingCard (Loading state)
├── _LoadingDataCard (Loading state for individual cards)
└── _ErrorCard (Error state with retry)
```

## Color Coding System

- **Progress Ring Colors**:

  - 🟢 Green: Goal achieved (100%+ steps)
  - 🟠 Orange: Good progress (70%+ steps)
  - 🔵 Blue: Getting started (0-70% steps)

- **Activity Icons**:
  - 🟢 Green: Walking activities
  - 🟠 Orange: Gym/fitness activities
  - 🔵 Blue: Cycling activities
  - 🔴 Red: Heart rate related
  - 🟣 Purple: Sleep related

## Responsive Design

The dashboard adapts to different screen sizes:

- **Cards**: Use Card.filled with consistent elevation
- **Grid Layout**: Two-column grid for quick stats
- **Padding**: Consistent 16px padding throughout
- **Typography**: Uses theme-based text styles
- **Spacing**: 8px between related items, 16-20px between sections
