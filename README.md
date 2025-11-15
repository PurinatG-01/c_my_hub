# C My Hub - Health Tracking App

[![PR Checks](https://github.com/PurinatG-01/c_my_hub/actions/workflows/pr_checks.yml/badge.svg)](https://github.com/PurinatG-01/c_my_hub/actions/workflows/pr_checks.yml)
[![Advanced Analysis](https://github.com/PurinatG-01/c_my_hub/actions/workflows/advanced_analysis.yml/badge.svg)](https://github.com/PurinatG-01/c_my_hub/actions/workflows/advanced_analysis.yml)

C My Hub is a modern, Flutter-based health and fitness application designed to provide a comprehensive and intuitive way to track your well-being. It seamlessly integrates with native health services like Apple Health and Android Health Connect to gather and present your health data. The app features a beautiful, data-rich dashboard and an intelligent AI health assistant to help you stay on top of your goals.

<p align="center">
  <img src="https://placehold.co/600x300/2E7D32/FFFFFF/png?text=C+My+Hub" alt="C My Hub Banner">
</p>

## ✨ Key Features

- **🩺 Comprehensive Health Dashboard**: An elegant dashboard that provides an at-a-glance summary of your daily health metrics, including steps, heart rate, calories, and sleep.
- **🤖 AI Health Assistant**: An intelligent assistant powered by the OpenAI API that provides personalized health coaching, goal setting, and data analysis.
- **🎨 Customizable Themes**: Switch between a clean light theme and a sleek dark theme, with your preference saved across sessions.
- **📱 Mobile-First**: Built with Flutter specifically for iOS and Android, providing native mobile performance and seamless integration with device health services.
- **🔒 Privacy-Focused**: Your health data is sensitive. The app integrates with Apple Health and Android's Health Connect, keeping your data secure on your device.

## 📚 Documentation

This project is organized with comprehensive documentation to make it easy to understand, maintain, and extend.

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

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.5.4 or higher)
- An IDE like VS Code or Android Studio
- For the AI Assistant's production mode, an OpenAI API key.

### Installation

1.  **Clone the repository:**

    ```sh
    git clone <repository-url>
    cd c_my_hub
    ```

2.  **Install dependencies:**

    ```sh
    flutter pub get
    ```

3.  **Run the app:**
    ```sh
    flutter run
    ```

### Development and Debugging

For comprehensive debugging setup and VS Code integration, see the [Application Architecture](docs/APPLICATION_STRUCTURE.md#development-setup) documentation. The project includes:

- **VS Code Debug Configurations**: Pre-configured launch settings for all platforms
- **Multiple Debug Modes**: Debug, Profile, and Release mode configurations
- **Platform-Specific Debugging**: iOS and Android mobile targets
- **Testing Support**: Dedicated configurations for unit and integration tests
- **Hot Reload Integration**: Full development workflow optimization

Quick debug start: Press `Cmd+Shift+D` in VS Code and select your target platform.

### Using the AI Assistant

- **Demo Mode**: The AI assistant works out-of-the-box in demo mode, providing smart, simulated responses.
- **Production Mode**: To use the live AI, you need to:
  1.  Create a `.env` file in the root of the project (you can copy `.env.example`).
  2.  Add your OpenAI API key to the `.env` file:
      ```
      OPENAI_API_KEY=your_openai_api_key_here
      ```
  3.  Follow the instructions in the source code to switch from the demo service to the production service.

## 🤝 Contributing

Contributions are welcome! If you have ideas for new features, bug fixes, or improvements, please feel free to open an issue or submit a pull request.
