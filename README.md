# IncNote

A Flutter-based productivity and note-taking application for creating and organizing notes, checklists, and reminders in one place.

IncNote is designed to provide a simple, clean, and lightweight way to capture ideas, manage tasks, and keep track of important reminders.

---

## Features

- 📝 **Notes**
  - Create and edit notes
  - Automatically save note changes
  - Search notes
  - Bookmark notes
  - Delete notes
  - Share notes

- ✅ **Checklists**
  - Create checklists
  - Add and manage checklist items
  - Track completed and remaining items
  - Bookmark checklists
  - Share checklists
  - Delete checklists

- ⏰ **Reminders**
  - Create reminders
  - Schedule reminder notifications
  - Mark reminders as completed
  - Manage reminder details

- 🔖 **Bookmarks**
  - View bookmarked notes and checklists in one place

- 🔍 **Search**
  - Search notes, checklists, and reminders

- 📤 **Sharing**
  - Share notes
  - Share checklists

- 🔔 **Local Notifications**
  - Schedule reminder notifications on Android

- 💾 **Local Persistence**
  - Data is stored locally on the device
  - Uses Hive for persistent storage

- 📢 **Advertisements**
  - Google AdMob integration
  - Native advertisements
  - Banner advertisements

- 🎨 **Material Design**
  - Modern Material UI
  - Light and dark theme support
  - Responsive Flutter interface

---

# Prerequisites

Before running the project, ensure you have the following installed:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio
- Android SDK
- Android SDK Platform Tools
- A physical Android device or Android Emulator

For development, a physical Android device is recommended for testing notifications and advertisements.

Verify your Flutter installation:

```bash
flutter doctor
```

# Clone the Repository

Clone the repository:

```bash
git clone https://github.com/ganhuilin015/IncNote.git
```

Navigate into the project:

```bash
cd notepad
```

If the repository uses a different directory name after cloning, navigate into the generated project directory instead.

# Install Dependencies

Fetch all Flutter dependencies:

```bash
flutter pub get
```

If dependencies have changed in pubspec.yaml, run:

```bash
flutter pub get
```

Check for outdated packages:

```bash
flutter pub outdated
```

Upgrade dependencies when appropriate:

```bash
flutter pub upgrade
```

# Running the Application

## Check Available Devices

List all available Flutter devices:

```bash
flutter devices
```

## Run on Android

Connect an Android device with USB Debugging enabled or start an Android Emulator.

Then run:

```bash
flutter run
```

To run on a specific device:

```bash
flutter run -d <device-id>
```

## Running in Release Mode

To run the application using Flutter's release mode:

```bash
flutter run --release
```

Release mode provides performance characteristics closer to the version distributed to users.

# Development

## Hot Reload

While the application is running:

- Press r for Hot Reload
- Press R for Hot Restart
- Press q to quit

Hot Reload is useful for quickly seeing UI changes without restarting the entire application.

## Code Generation

IncNote uses generated Dart files for certain models and persistence-related functionality.

If generated files need to be regenerated:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

# Building for Release

## Android APK

Generate a release APK:

```bash
flutter build apk --release
```

The generated APK will be located at:

```bash
build/app/outputs/flutter-apk/app-release.apk
```

The APK can be installed directly on Android devices for testing.

## Android App Bundle

For Google Play Store distribution, generate an Android App Bundle:

```bash
flutter build appbundle --release
```

The generated bundle will be located at:

```bash
build/app/outputs/bundle/release/app-release.aab
```

The .aab file should be uploaded to the Google Play Console.

## Android Release Deployment

Before creating a production release, remember to update the application version in:

```bash
pubspec.yaml
```

The format is:

```bash
version: <version-name>+<version-code>
```

For every new Google Play release, increase the version code.

# Data Storage

IncNote stores application data locally on the device.

The project uses:

- Hive
- Hive CE
- Generated Hive adapters

Application data includes information such as:

- Notes
- Checklists
- Checklist items
- Reminders
- Bookmarks

Because the data is stored locally, uninstalling the application may remove the stored application data.

# Useful Flutter Commands

Check Flutter Environment:

```bash
flutter doctor
```

List Connected Devices:

```bash
flutter devices
```

Get Dependencies:

```bash
flutter pub get
```

Check Outdated Dependencies:

```bash
flutter pub outdated
```

Upgrade Dependencies:

```bash
flutter pub upgrade
```

Analyze the Project:

```bash
flutter analyze
```

Format Dart Code:

```bash
dart format .
```

Clean the Project:

```bash
flutter clean
```

Reinstall Dependencies After Cleaning:

```bash
flutter clean
flutter pub get
```

Regenerate Generated Files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

# Recommended Clean Build

If you encounter unexpected Android or Flutter build problems, try:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

For a release build:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build appbundle --release
```
