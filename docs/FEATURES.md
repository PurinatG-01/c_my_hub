# C My Hub - Features

This document outlines the key features of the C My Hub application, a comprehensive health and fitness tracker that seamlessly integrates with native health services like Apple Health and Android Health Connect, combining health tracking with an intelligent AI assistant.

## 🩺 Health Dashboard

The dashboard provides a comprehensive, at-a-glance view of your daily health and fitness data.

### Key Dashboard Features:

-   **Health Summary Card**: A central card displaying:
    -   **Visual Progress Ring**: A color-coded ring showing daily step progress.
        -   🟢 **Green**: Goal achieved (100%+)
        -   🟠 **Orange**: Good progress (70%+)
        -   🔵 **Blue**: Getting started (0-70%)
    -   **Core Metrics**: Real-time display of heart rate, calories burned, and sleep duration.
-   **Quick Stats Grid**:
    -   **Distance Tracking**: Daily walking/running distance in kilometers.
    -   **Active Time**: Total active minutes for the day.
    -   **Weekly Average**: Average daily steps over the past 7 days.
-   **Recent Activities Timeline**:
    -   Lists recent workouts like walking, gym sessions, and cycling.
    -   Includes details such as duration, distance, and calories burned.
-   **Smart Greeting**: A personalized greeting that changes based on the time of day (Morning, Afternoon, Evening).
-   **Data Refresh**:
    -   **Pull-to-Refresh**: Swipe down to manually refresh all health data.
    -   **Automatic Refresh**: Data updates automatically when the app is opened or resumed.

## 🤖 AI Health Assistant

An intelligent AI assistant, powered by OpenAI's Assistants API, provides personalized health coaching and insights.

### AI Assistant Capabilities:

-   **Intelligent Health Coaching**: Get personalized advice and motivation.
-   **Real-time Data Analysis**: The assistant can access and analyze your live health data.
-   **Goal Setting & Tracking**: Set, track, and manage your health and fitness goals with the AI's help.
-   **Personalized Recommendations**: Receive tips and recommendations based on your activity patterns.
-   **Natural Conversation**: Engage in a natural, human-like conversation about your health.

### Implementation Modes:

-   **Demo Mode**: A fully functional demo that works without an API key, using smart mock responses to showcase the complete user experience.
-   **Production Mode**: Integrates directly with the OpenAI Assistants API for real AI responses and function calling (requires an API key).

### Example AI Interactions:

-   **Progress Tracking**: "How am I doing this week?"
-   **Goal Setting**: "Help me set a new fitness goal."
-   **Health Insights**: "Give me a health tip based on my recent activity."

## 🎨 Theme & UI

-   **Theme Switcher**:
    -   **Light & Dark Modes**: Choose between a clean light theme and a modern dark theme.
    -   **System Theme**: Automatically syncs with your device's theme settings.
    -   **Persistence**: Your theme preference is saved across app restarts.
-   **Health-Focused Design**: A green color palette is used to create a health-focused and visually appealing interface.
-   **Responsive UI**: The application is designed to adapt to various screen sizes and orientations.

## 🏗️ Architecture & Technical Features

-   **Clean Architecture**: A well-organized and scalable codebase following Clean Architecture principles.
-   **State Management**: Uses `flutter_riverpod` for efficient and reactive state management.
-   **Navigation**: `go_router` for a declarative and robust routing solution.
-   **Health Data Integration**:
    -   Connects to Apple Health (HealthKit) on iOS and Health Connect on Android.
    -   Fetches a wide range of data types, including steps, heart rate, sleep, calories, and more.
-   **Security & Privacy**:
    -   API keys are stored securely.
    -   Health data is handled with privacy in mind, with clear user consent.
