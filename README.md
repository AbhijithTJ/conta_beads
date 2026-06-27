# Upper Room (Conta Beads)

A Flutter application designed to facilitate daily prayers, spiritual intentions, and community engagement. The app provides a rich, interactive experience for users to maintain their daily prayer routines, read prayer documents, and participate in spiritual activities.

## Features

- **Daily Prayers & Documents:** Access to daily prayers, structured prayer documents, and historical prayer tracking.
- **Adopt a Priest:** A dedicated feature for users to spiritually adopt and pray for priests.
- **Intentions:** Share and pray for community and personal intentions.
- **Biometric Authentication:** Secure login using local device biometrics (fingerprint/FaceID) via `local_auth` and `flutter_secure_storage`.
- **Real-time Updates:** WebSocket and Pusher integration for real-time community engagement and notifications.
- **Push Notifications:** Firebase Cloud Messaging (FCM) integration for timely alerts and daily reminders.
- **Multilingual Support:** Built-in localization support for multiple languages.
- **Theming:** Full support for Light and Dark modes.
- **Rich Media:** Includes audio playback for guided prayers and interactive page-flip animations for reading.

## Tech Stack & Architecture

- **Framework:** Flutter (SDK ^3.11.0)
- **State Management:** Provider (`provider` package)
- **Networking:** HTTP & WebSockets (`http`, `web_socket_channel`, `pusher_channels_flutter`)
- **Storage:** `shared_preferences` for session state, `flutter_secure_storage` for sensitive credentials.
- **UI/UX:** `google_fonts`, `curved_navigation_bar`, `page_flip`, `flutter_svg`.

## Getting Started

### Prerequisites
- Flutter SDK (version ^3.11.0 or higher)
- Android Studio / Xcode for platform-specific builds
- Firebase project setup (for FCM notifications)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd conta_beads
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/main.dart` - Application entry point and Provider setup.
- `lib/providers/` - State management providers (Auth, User, Home, Prayers, etc.).
- `lib/screens/` - UI screens categorized by feature (Splash, Login, Home, etc.).
- `lib/services/` - Core services (API Client, Session Management, Notifications).
- `lib/models/` - Data models for API responses and application state.
- `assets/` - Static resources, images, sounds, and localization files.

## Note on Data Persistence

The app manages sessions securely. On Android, Auto Backup is explicitly disabled to ensure user tokens do not persist after the app is uninstalled. On iOS, Keychain storage is cleared on fresh installs to prevent old biometric credentials from surfacing.
