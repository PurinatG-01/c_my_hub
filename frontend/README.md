# C My Hub Frontend

Flutter mobile application for the C My Hub health tracking platform.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.5.4 or higher)
- An IDE like VS Code or Android Studio
- For the AI Assistant's production mode, an OpenAI API key

### Installation

1. **Navigate to the frontend directory:**

   ```sh
   cd frontend
   ```

2. **Install dependencies:**

   ```sh
   flutter pub get
   ```

3. **Run the app:**

   ```sh
   flutter run
   ```

## 📚 Documentation

This project includes comprehensive documentation:

- **[Development Guide](docs/DEVELOPMENT.md)**: Complete development environment setup, debugging, and workflow guide.
- **[Features Overview](docs/FEATURES.md)**: A detailed list of all application features.
- **[Application Architecture](docs/ARCHITECTURE.md)**: An in-depth explanation of the project's architecture, state management, and data flow.
- **[To-Do List](docs/TODO.md)**: A list of planned features and enhancements for future development.

### Legacy Documentation

The following documents were part of the initial development and have been consolidated into the files above. They are kept for historical reference.

- `docs/AI_ASSISTANT_COMPLETE_GUIDE.md`
- `docs/APPLICATION_STRUCTURE.md`
- `docs/DASHBOARD_ARCHITECTURE.md`
- `docs/DASHBOARD_CUSTOMIZATION.md`
- `docs/DASHBOARD_FEATURES.md`
- `docs/NAVIGATION_FIX.md`
- `docs/OPENAI_AGENT_INTEGRATION.md`
- `docs/THEME_SWITCHER.md`

## 🛠️ Development

### Debugging

For comprehensive debugging setup and VS Code integration, see the [Application Architecture](docs/APPLICATION_STRUCTURE.md#development-setup) documentation. The project includes:

- **VS Code Debug Configurations**: Pre-configured launch settings for all platforms
- **Multiple Debug Modes**: Debug, Profile, and Release mode configurations
- **Platform-Specific Debugging**: iOS and Android mobile targets
- **Testing Support**: Dedicated configurations for unit and integration tests
- **Hot Reload Integration**: Full development workflow optimization

Quick debug start: Press `Cmd+Shift+D` in VS Code and select your target platform.

### Using the AI Assistant

- **Demo Mode**: The AI assistant works out-of-the-box in demo mode, providing smart, simulated responses.
- **Production Mode**: To use the live AI, configure the backend server with your OpenAI API key.

## 📱 Features

- **🩺 Comprehensive Health Dashboard**: An elegant dashboard that provides an at-a-glance summary of your daily health metrics
- **🤖 AI Health Assistant**: An intelligent assistant powered by OpenAI API
- **🎨 Customizable Themes**: Switch between light and dark themes
- **📱 Mobile-First**: Built with Flutter for iOS and Android
- **🔒 Privacy-Focused**: Integrates with Apple Health and Android Health Connect

## 🏗️ Project Structure

```
frontend/
├── lib/
│   ├── core/           # Core functionality (constants, router, theme)
│   ├── features/       # Feature modules (ai_assistant, dashboard, health)
│   ├── service/        # Services (health_service)
│   ├── shared/         # Shared widgets and utilities
│   └── main.dart       # Application entry point
├── android/            # Android platform files
├── ios/                # iOS platform files
├── web/                # Web platform files
├── test/               # Test files
└── pubspec.yaml        # Flutter dependencies
```

