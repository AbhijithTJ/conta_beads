# iOS Build & Firebase Crash Fix Checklist

## Changes Made
✅ Removed `FirebaseApp.configure()` from `ios/Runner/AppDelegate.swift`
✅ Created `lib/firebase_options.dart` with iOS configuration
✅ Updated `lib/main.dart` to use `DefaultFirebaseOptions.currentPlatform`

## Steps to Build & Test

### 1. Clean Everything
```bash
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
flutter pub get
```

### 2. Update iOS Pod Dependencies
```bash
cd ios
pod install --repo-update
cd ..
```

### 3. Verify GoogleService-Info.plist in Xcode
- Open `ios/Runner.xcworkspace` (NOT .xcodeproj)
- Select **Runner** project
- Select **Runner** target (not the project)
- Go to **Build Phases**
- Expand **Copy Bundle Resources**
- Verify `GoogleService-Info.plist` is listed
- If not, click **+** and add it

### 4. Verify Bundle ID Matches
- In Xcode: Runner target → General tab → Identity → Bundle Identifier
- Compare with `GoogleService-Info.plist` → `BUNDLE_ID` key
- Current: `in.co.upperroom.contabeads`
- They MUST match

### 5. Build iOS App
```bash
flutter build ios -v
```

### 6. Run on Simulator or Device
```bash
flutter run -d ios
```

## Expected Behavior
- App launches without crashing
- Splash screen appears (6 second animation)
- Firebase initializes in Dart (check console for `[App]` logs)
- Navigation to ThemeSelectScreen or OnboardingWrapper works

## Troubleshooting

### If still crashes after Firebase.initializeApp():
1. Check Xcode console for detailed error messages
2. Run: `flutter run -d ios -v` for verbose logs
3. Check `NotificationService.instance.initialize()` doesn't crash

### If GoogleService-Info.plist not found:
1. Verify file exists at: `ios/Runner/GoogleService-Info.plist`
2. In Xcode, right-click GoogleService-Info.plist
3. File Inspector → Target Membership → Check "Runner"

### If Bundle ID mismatch:
1. Regenerate GoogleService-Info.plist from Firebase Console
2. Or update Bundle ID in Xcode to match plist

## Important Notes
- Always open **Runner.xcworkspace** in Xcode, never .xcodeproj
- Use `-v` flag for verbose logs when debugging
- Check iOS device logs in Xcode Console
- Pod dependencies must be up to date after any change
