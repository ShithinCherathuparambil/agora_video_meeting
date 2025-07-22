# Firebase Setup Guide for Video Meeting App

## Current Status ✅❌

### ✅ **Completed Configurations:**
- iOS deployment target updated to 13.0
- Camera and microphone permissions added to iOS Info.plist
- Android permissions for camera, microphone, internet, etc. added
- Firebase dependencies installed in pubspec.yaml
- firebase_options.dart file present (with demo keys)

### ❌ **Missing Configurations:**
- Real Firebase project configuration files
- Firebase project setup in console

## 🔥 Firebase Setup Instructions

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or select existing project
3. Enter project name (e.g., "video-streaming-app")
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Enable Required Services
In your Firebase project, enable these services:
- **Authentication** → Sign-in method → Email/Password & Google
- **Firestore Database** → Create database in production mode
- **Storage** → Get started

### Step 3: Add iOS App
1. In Firebase console, click "Add app" → iOS
2. Enter iOS bundle ID: `com.example.videoStreaming`
3. Enter app nickname: "Video Streaming iOS"
4. Download `GoogleService-Info.plist`
5. Replace `ios/Runner/GoogleService-Info.plist.template` with downloaded file
6. Rename to `GoogleService-Info.plist` (remove .template)

### Step 4: Add Android App
1. In Firebase console, click "Add app" → Android
2. Enter Android package name: `com.example.video_streaming`
3. Enter app nickname: "Video Streaming Android"
4. Download `google-services.json`
5. Replace `android/app/google-services.json.template` with downloaded file
6. Rename to `google-services.json` (remove .template)

### Step 5: Update firebase_options.dart
1. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
2. Run: `flutterfire configure`
3. Select your Firebase project
4. Select platforms: iOS, Android
5. This will update `lib/firebase_options.dart` with real keys

## 📱 Permissions Added

### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera for video calls and meetings.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for audio calls and meetings.</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>
```

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CAMERA" />
```

## 🧪 Testing Setup
After completing Firebase setup:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Test on device: `flutter run`
4. Verify permissions are requested when accessing camera/microphone

## 🔧 Troubleshooting
- If build fails, ensure Firebase config files are properly named and placed
- For iOS: Check that GoogleService-Info.plist is added to Xcode project
- For Android: Ensure google-services.json is in android/app/ directory
- Run `flutter doctor` to check for any issues
