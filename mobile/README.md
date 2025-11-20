# LiLead (לי-ליד) - CRM Mobile Application

A modern, beautiful Flutter-based CRM mobile application for lead management with Hebrew localization and iOS-style design.

## Features

### 🎯 Lead Management
- **Lead Tracking**: Organize leads by status (New, In Process, Closed, Not Relevant)
- **Quick Actions**: Call, WhatsApp, or Email leads directly from the app
- **Notes System**: Add timestamped notes to track interactions
- **Search & Filter**: Quickly find leads with real-time search
- **Source Tracking**: Track lead sources (Facebook, Instagram, WhatsApp, TikTok, Manual)

### 📊 Dashboard & Analytics
- **Real-time Statistics**: View lead counts by status and source
- **Animated Charts**: Beautiful pie and bar charts with smooth animations
- **Conversion Tracking**: Monitor your lead conversion rates

### 🎨 UI/UX
- **iOS-Style Design**: Clean, minimal interface inspired by iOS Contacts
- **Smooth Animations**: Staggered list animations, breathing FAB, animated charts
- **Dark/Light Mode**: Full theme support with system preference detection
- **RTL Support**: Complete right-to-left layout for Hebrew

### 🌍 Localization
- **Hebrew (עברית)**: Default language with full RTL support
- **English**: Complete English translations
- **Easy Switching**: Change language from settings

### 👤 User Management
- **Profile Management**: Edit name, email, avatar, and password
- **Secure Authentication**: JWT-based authentication with token refresh
- **Avatar System**: Google-style initial avatars

## Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Riverpod 2.5
- **Navigation**: GoRouter 14.2
- **HTTP Client**: Dio 5.7 + Retrofit 4.4
- **Charts**: FL Chart 0.69
- **Animations**: Flutter Animate 4.5
- **Storage**: Flutter Secure Storage 9.2
- **Localization**: Flutter Intl 0.20

## Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.10.0 or higher
- Android Studio / Xcode (for mobile development)
- Backend server running (see backend README)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd lilead/mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure backend URL**
   
   Update the API base URL in `lib/core/api/api_client.dart`:
   ```dart
   static const String baseUrl = 'http://your-backend-url:3000';
   ```

5. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # Or use the convenience script
   ./run.sh
   ```

## Project Structure

```
lib/
├── config/           # App configuration (routes, theme)
├── core/            # Core functionality
│   ├── api/         # API client and services
│   ├── models/      # Data models
│   ├── services/    # Business logic services
│   └── utils/       # Utility functions
├── l10n/            # Localization files
├── providers/       # Riverpod state providers
├── screens/         # UI screens
│   ├── auth/        # Authentication screens
│   ├── dashboard/   # Dashboard screen
│   ├── leads/       # Lead management screens
│   ├── profile/     # Profile screen
│   └── settings/    # Settings screen
└── widgets/         # Reusable widgets
```

## Configuration

### API Endpoints

The app expects the following backend endpoints:

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user
- `GET /api/leads` - Get leads (with optional status filter)
- `POST /api/leads` - Create lead
- `PATCH /api/leads/:id` - Update lead
- `DELETE /api/leads/:id` - Delete lead
- `GET /api/leads/:id/notes` - Get lead notes
- `POST /api/leads/:id/notes` - Add note
- `GET /api/stats` - Get statistics
- `PATCH /api/profile` - Update profile

### Environment Variables

No environment variables needed for the mobile app. All configuration is in code.

## Development

### Running in Development Mode

```bash
# Hot reload enabled
flutter run

# With specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

### Code Generation

When you modify models or API services:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Adding Translations

1. Update `lib/l10n/app_en.arb` and `lib/l10n/app_he.arb`
2. Run `flutter gen-l10n` (or restart the app)
3. Use translations: `AppLocalizations.of(context)!.keyName`

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS
flutter build ios --release
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Troubleshooting

### Build Errors

If you encounter build errors after pulling changes:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### API Connection Issues

1. Ensure backend is running
2. Check the base URL in `api_client.dart`
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. For iOS simulator, use `localhost` or your machine's IP

### RTL Layout Issues

The app automatically detects Hebrew and switches to RTL. If you see layout issues:
1. Ensure you're using `Directionality` widget where needed
2. Check that text alignment uses `TextAlign.start` instead of `TextAlign.left`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure code quality
5. Submit a pull request

## License

[Your License Here]

## Support

For issues and questions, please open an issue on GitHub.
