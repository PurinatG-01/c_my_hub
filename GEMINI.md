# C My Hub - Gemini Context

This document provides context for the C My Hub Flutter project to help the Gemini AI assistant understand the codebase for future interactions.

## Project Overview

C My Hub is a cross-platform health and fitness tracking application built with Flutter. Its primary purpose is to provide users with a comprehensive and intuitive way to monitor their well-being.

The application features:
-   A data-rich **Health Dashboard** that summarizes daily metrics like steps, heart rate, calories, and sleep.
-   An **AI Health Assistant** powered by the OpenAI API for personalized coaching and goal setting.
-   **Customizable Themes** with persistent light and dark modes.
-   Integration with native health services: **Apple Health (HealthKit)** on iOS and **Health Connect** on Android.

## Architecture and Tech Stack

The project follows the principles of **Clean Architecture**, promoting a separation of concerns and a scalable, maintainable codebase.

-   **Framework**: Flutter (`^3.5.4`)
-   **State Management**: `flutter_riverpod` (`^2.6.1`) is used for reactive and predictable state management.
-   **Navigation**: `go_router` (`^14.6.1`) handles declarative routing.
-   **Health Data**: The `health` package (`^13.2.1`) provides integration with native health platforms.
-   **API Communication**: The `http` package is used for making calls to the OpenAI API.

The code is organized into a feature-based structure:
-   `lib/core`: Contains foundational infrastructure like routing, theming, and constants.
-   `lib/features`: Houses self-contained feature modules (e.g., `dashboard`, `ai_assistant`).
-   `lib/service`: Contains global services, notably the `HealthService`.
-   `lib/shared`: Includes reusable widgets and utilities.

For a detailed breakdown, refer to the [Application Architecture](docs/ARCHITECTURE.md) document.

## Building and Running

The project follows standard Flutter conventions for building and running.

1.  **Install Dependencies:**
    Ensure all dependencies are fetched from `pubspec.yaml`.
    ```sh
    flutter pub get
    ```

2.  **Run the Application:**
    Run the app on a connected device or simulator.
    ```sh
    flutter run
    ```

3.  **Run Tests:**
    Execute the unit and widget tests.
    ```sh
    flutter test
    ```

4.  **Code Generation:**
    The project uses code generation for Riverpod providers and JSON serialization. If you modify files that require code generation, run the following command:
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

## Development Conventions

-   **Clean Architecture**: Adhere to the established separation of data, domain, and presentation layers within each feature.
-   **State Management**: Use `flutter_riverpod` for all state management. Prefer creating providers in the `domain` layer of a feature.
-   **Immutability**: Use immutable data models (e.g., with `copyWith` methods) where possible. The `equatable` package is used to simplify value equality checks.
-   **Routing**: All navigation should be handled by `go_router`. Define routes in `lib/core/router/routes.dart`. Use `context.push()` for detail screens and `context.go()` for main navigation tabs.
-   **Linting**: The project uses the `flutter_lints` package. Adhere to the linting rules defined in `analysis_options.yaml`.
-   **AI Assistant**: The AI feature has two modes: `DemoAIAssistantScreen` (for UI/UX testing without an API key) and `AIAssistantScreen` (for production). The switch between them is handled in the router.
-   **Environment Variables**: API keys and other secrets should be stored in a `.env` file and accessed via the `flutter_dotenv` package. Do not commit the `.env` file to version control.

## Gemini Agent Role for this Project

For this project only, my role is to analyze the project code quality, performance, readability, and code patterns. I am a QA/Tester and will not directly update the code unless explicitly requested by the user.