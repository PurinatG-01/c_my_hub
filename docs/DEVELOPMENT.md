# Development Guide - C My Hub

This guide provides comprehensive information for developers working on the C My Hub Flutter application.

## 🛠 Development Environment Setup

### Prerequisites

- **Flutter SDK**: Version 3.5.4 or higher
- **Dart SDK**: Included with Flutter
- **IDE**: VS Code (recommended) or Android Studio
- **Git**: For version control
- **OpenAI API Key**: For production AI assistant functionality

### Platform-Specific Requirements

#### iOS Development

- **Xcode**: Latest stable version
- **iOS Simulator**: iOS 12.0 or higher
- **CocoaPods**: For dependency management

#### Android Development

- **Android Studio**: Latest stable version
- **Android SDK**: API level 21 (Android 5.0) or higher
- **Android Emulator**: Or physical device with USB debugging

#### Web Development

- **Chrome**: For web debugging and testing
- **Web Server**: Built-in Flutter web server

#### macOS Development

- **macOS**: 10.14 (Mojave) or higher
- **Xcode Command Line Tools**: For native compilation

## 🚀 Quick Start

### Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd c_my_hub

# Install Flutter dependencies
flutter pub get

# Verify Flutter installation and setup
flutter doctor

# Run the application
flutter run
```

### Environment Configuration

1. **Create environment file:**

   ```bash
   cp .env.example .env
   ```

2. **Configure OpenAI API (Production Mode):**
   ```env
   OPENAI_API_KEY=your_openai_api_key_here
   FLUTTER_DEBUG=true
   ENVIRONMENT=development
   ```

### Important Notes

- **No Custom Schemes**: This project does not use custom build flavors/schemes. All configurations use standard Flutter build modes (debug, profile, release) with environment variables for customization.
- **Environment Variables**: Use `--dart-define` flags to pass environment-specific configurations instead of flavors.

## 🐛 VS Code Debugging

The project includes a comprehensive `.vscode/launch.json` with multiple debugging configurations optimized for different development scenarios.

### Debug Configurations Overview

| Configuration                | Purpose                    | Target Platform   | Mode    |
| ---------------------------- | -------------------------- | ----------------- | ------- |
| Flutter: Debug               | General development        | Auto-detect       | Debug   |
| Flutter: Profile             | Performance testing        | Auto-detect       | Profile |
| Flutter: Release             | Production testing         | Auto-detect       | Release |
| Flutter: Debug (iOS)         | iOS-specific debugging     | iOS Simulator     | Debug   |
| Flutter: Debug (Android)     | Android-specific debugging | Android Emulator  | Debug   |
| Flutter: Debug (Chrome)      | Web debugging              | Chrome Browser    | Debug   |
| Flutter: Debug (macOS)       | Desktop debugging          | macOS Native      | Debug   |
| Flutter: Test (Current File) | Unit test debugging        | Current test file | Debug   |
| Flutter: Integration Tests   | E2E test debugging         | Test driver       | Debug   |
| Dart: Debug (Console)        | Pure Dart debugging        | Terminal          | Debug   |

### Advanced Debug Features

#### Custom Environment Variables

The "Flutter: Debug with Custom Entry Point" configuration includes:

```json
{
  "args": [
    "--dart-define=ENVIRONMENT=debug",
    "--dart-define=API_BASE_URL=https://api.dev.example.com"
  ],
  "env": {
    "FLUTTER_DEBUG": "true"
  }
}
```

#### Environment Configuration

Configurations support different environment variables through dart-define:

- **DEBUG**: `--dart-define=ENVIRONMENT=debug`
- **PRODUCTION**: `--dart-define=ENVIRONMENT=production`

#### Compound Debugging

The "Flutter: Debug All Platforms" configuration allows simultaneous debugging across iOS and Android platforms.

### Debugging Workflow

1. **Set Breakpoints**: Click line numbers in VS Code
2. **Select Configuration**: Choose from debug dropdown
3. **Start Debugging**: Press `F5` or click play button
4. **Debug Controls**:
   - `F10`: Step Over
   - `F11`: Step Into
   - `Shift+F11`: Step Out
   - `F5`: Continue
   - `Shift+F5`: Stop

### Hot Reload and Hot Restart

- **Hot Reload**: `Cmd+S` (macOS) - Preserves app state
- **Hot Restart**: `Cmd+Shift+S` (macOS) - Resets app state
- **Full Restart**: Stop and restart debug session

## 🧪 Testing

### Test Types

#### Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/unit/specific_test.dart

# Run tests with coverage
flutter test --coverage
```

#### Integration Tests

```bash
# Run integration tests
flutter drive --target=test_driver/app.dart

# Run with specific device
flutter drive --target=test_driver/app.dart -d chrome
```

#### Widget Tests

```bash
# Run widget tests
flutter test test/widget_test.dart
```

### Test Debug Configurations

Use the following VS Code configurations for test debugging:

- **Flutter: Test (Current File)**: Debug currently open test file
- **Flutter: Integration Tests**: Debug end-to-end tests with special environment

## 📦 Build and Deployment

### Development Builds

```bash
# Debug build (default)
flutter run

# Profile build (performance testing)
flutter run --profile

# Release build (production testing)
flutter run --release
```

### Production Builds

#### iOS

```bash
# Build iOS app
flutter build ios

# Build iOS app with environment variables
flutter build ios --dart-define=ENVIRONMENT=production
```

#### Android

```bash
# Build APK
flutter build apk

# Build App Bundle (recommended for Play Store)
flutter build appbundle

# Build with environment variables
flutter build apk --dart-define=ENVIRONMENT=production
```

#### Web

```bash
# Build for web
flutter build web

# Build with specific renderer
flutter build web --web-renderer html
```

#### macOS

```bash
# Build macOS app
flutter build macos
```

## 🔧 Development Tools

### Code Quality

#### Linting

```bash
# Run dart analyzer
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

#### Formatting

```bash
# Format all Dart files
dart format .

# Check formatting without applying
dart format --set-exit-if-changed .
```

### Performance Profiling

```bash
# Run with performance overlay
flutter run --profile --trace-startup

# Generate performance report
flutter run --profile --trace-startup --dump-skp-on-shader-compilation
```

### Dependency Management

```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Add new package
flutter pub add package_name

# Remove package
flutter pub remove package_name
```

## 🏗 Project Structure

```
lib/
├── core/                   # Core functionality and utilities
│   ├── router/            # App routing configuration
│   ├── theme/             # App theming and styling
│   └── utils/             # Utility functions and helpers
├── features/              # Feature-based organization
│   ├── dashboard/         # Health dashboard feature
│   ├── ai_assistant/      # AI assistant feature
│   └── settings/          # App settings feature
├── service/               # External services and APIs
└── shared/                # Shared widgets and components
```

### Architecture Patterns

- **Clean Architecture**: Separation of concerns with clear layers
- **Feature-First**: Organization by feature rather than file type
- **Riverpod**: State management and dependency injection
- **Repository Pattern**: Data access abstraction

## 🐛 Troubleshooting

### Common Issues

#### Flutter Doctor Issues

```bash
# Check Flutter installation
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses
```

#### iOS Simulator Issues

```bash
# List available simulators
xcrun simctl list devices

# Boot specific simulator
xcrun simctl boot "iPhone 14 Pro"
```

#### Android Emulator Issues

```bash
# List available emulators
emulator -list-avds

# Start specific emulator
emulator -avd Pixel_4_API_30
```

#### Dependency Conflicts

```bash
# Clean build cache
flutter clean

# Remove pub cache and reinstall
flutter pub cache repair
flutter pub get
```

### Debug Console Commands

While debugging, use these console commands:

- `r`: Hot reload
- `R`: Hot restart
- `q`: Quit debug session
- `d`: Detach debugger
- `h`: Help

## 📋 Development Checklist

### Before Committing

- [ ] Run `flutter analyze` with no issues
- [ ] Run `dart format .` to ensure consistent formatting
- [ ] Run unit tests with `flutter test`
- [ ] Test on target platforms (iOS/Android/Web)
- [ ] Update documentation if needed
- [ ] Check VS Code debug configurations work
- [ ] Verify environment variables are properly configured

### Before Release

- [ ] Test all debug configurations
- [ ] Run integration tests
- [ ] Performance profile with `--profile` mode
- [ ] Test on physical devices
- [ ] Verify production API connections
- [ ] Update version numbers
- [ ] Generate release builds
- [ ] Test release builds on devices

## 📞 Support

For development questions or issues:

1. Check this documentation first
2. Review the [Application Architecture](APPLICATION_STRUCTURE.md) guide
3. Check existing issues in the repository
4. Create a new issue with detailed reproduction steps

## 🔄 Continuous Integration

The project supports various CI/CD pipelines. Ensure your development environment matches the CI configuration for consistent builds and tests.

---

Happy coding! 🚀
