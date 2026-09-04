# Firebase Setup Guide for FMG Mobile App

This guide covers the steps to run after executing `flutterfire configure` in the `mobile/` directory.

## Prerequisites

1. **Flutter SDK installed** (check with `flutter --version`)
2. **Firebase CLI installed** (`npm install -g firebase-tools`)
3. **Google account** with access to Firebase console

## Step 1: Run FlutterFire Configure

From the `mobile/` directory:

```bash
# Install FlutterFire CLI (one-time)
dart pub global activate flutterfire_cli

# Login to Firebase (opens browser)
firebase login

# Run the configuration wizard (interactive)
flutterfire configure
```

During `flutterfire configure`, you will:
- Select your Firebase project (create one at [console.firebase.google.com](https://console.firebase.google.com) first if needed)
- Select platforms to configure (android, ios, macos, web - choose those you plan to build for)
- The tool will:
  - Generate/update `lib/firebase_options.dart` with real values
  - Download platform config files:
    - Android: `google-services.json` → `android/app/`
    - iOS/macOS: `GoogleService-Info.plist` → `ios/Runner/` and `macos/Runner/`
    - Web: adds Firebase snippet to `web/index.html`

## Step 2: Enable Required Firebase Services

In the [Firebase Console](https://console.firebase.google.com/), for your selected project:

### Authentication
1. Go to **Build → Authentication → Sign-in method**
2. Enable **Email Link (passwordless sign-in)**
   - Under "Email link (passwordless sign-in)" toggle
   - Optionally configure action code settings if needed

### Firestore Database
1. Go to **Build → Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
   - ⚠️ Remember to switch to production rules before launch!
4. Select a location close to your users

### (Optional) Hosting
If you plan to use Firebase Hosting for web builds:
1. Go to **Build → Hosting**
2. Click **Get started**
3. Follow the CLI wizard (you can also run `firebase init hosting` later)

## Step 3: Verify Firestore Security Rules

The app expects data at these paths:
- `/users/{athleteAuthUid}` (AthleteUser documents)
- `/users/{athleteAuthUid}/telemetry/{sessionId}` (telemetry sessions)
- `/users/{athleteAuthUid}/schedules/weekly` (weekly schedule doc)

Update Firestore Rules (under **Build → Firestore Database → Rules**):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Allow signed-in users to read/write their own athlete user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Telemetry subcollection
      match /telemetry/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Schedules subcollection
      match /schedules/{scheduleId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

> 🔒 **Important**: These rules allow users to only access their own data. For production, consider adding additional validation (e.g., checking that athlete UID matches the authenticated user).

## Step 4: Verify Generated Files

After `flutterfire configure` completes, check:

### Android
- ✅ `android/app/google-services.json` exists
- ✅ `android/app/build.gradle` has `apply plugin: 'com.google.gms.google-services'` at the bottom
- ✅ `android/build.gradle` has `classpath 'com.google.gms:google-services:4.4.2'` (or newer) in dependencies

### iOS/macOS
- ✅ `ios/Runner/GoogleService-Info.plist` exists
- ✅ `macos/Runner/GoogleService-Info.plist` exists (if configuring macOS)
- ✅ `ios/Podfile` has Firebase pods added by flutterfire
- ✅ `macos/Runner/DebugProfile.entitlements` and `Release.entitibles` have `com.apple.security.network-client` and `com.apple.security.network-server` (added by Firebase)

### Web
- ✅ Firebase config snippet added to `web/index.html` (if configuring web)
- ✅ `<script type="module">` import for Firebase SDK

### lib/
- ✅ `lib/firebase_options.dart` now has real values instead of `YOUR_*` placeholders

## Step 5: Build and Test

```bash
# From mobile/ directory
flutter pub get        # Ensure dependencies resolved
flutter build apk      # Android release build (or flutter run for debug)
flutter build ios      # iOS release build (requires Mac + Xcode)
flutter build macos    # macOS build (if configured)
flutter build web      # Web build (if configured)
```

### First-run testing
1. Launch the app on device/emulator/simulator
2. You should see the onboarding flow (since no Firestore user doc exists yet)
3. Complete the 5-question survey
4. After tapping "Generate Routine ⚡", the app should:
   - Call `OnboardingService.completeOnboarding()`
   - Write AthleteUser doc to `/users/{uid}`
   - Write WeeklySchedule to `/users/{uid}/schedules/weekly`
   - Clear local onboarding cache
   - Navigate to `/my-gym` screen
5. Verify in Firebase Console:
   - **Authentication** → Users shows new user
   - **Firestore** → Data shows the written documents under `users/`

## Step 6: Troubleshooting

| Issue | Solution |
|-------|----------|
| `[firebase_core/not-initialized]` | Ensure `Firebase.initializeApp()` is called before using Firebase (done in `main.dart`) |
| `Missing or insufficient permissions` | Check Firestore security rules |
| `google-services.json missing` | Re-run `flutterfire configure` or manually download from Firebase console |
| `Pod install failed` on iOS | Run `cd ios && pod install --repo-update` |
| `Minimum version not met` | Update Gradle version in `android/gradle/wrapper/gradle-wrapper.properties` |
| Web build fails | Ensure Firebase SDK is loaded in `web/index.html` (flutterfire should have done this) |

## Step 7: CI/CD Preparation (Optional)

If setting up automated builds:

### GitHub Actions
Add secrets:
- `FIREBASE_SERVICE_ACCOUNT_FMG_APP` (service account JSON)
Then use Firebase CLI actions to deploy.

### Fastlane
For beta distribution via Firebase App Distribution.

## Notes

- **iOS bundle ID**: The app uses `com.fmg.companion` – ensure this matches what's registered in Firebase project settings and your Apple Developer account.
- **Android package name**: Default is `com.example.fmg_companion` – you may want to change this in `android/app/src/main/AndroidManifest.xml` and update `google-services.json` accordingly.
- **Data model**: All Firestore paths match the backend specification from FMG.md – the mobile app is a standalone client that talks directly to Firestore.
- **Offline persistence**: Firestore SDK enables offline caching by default – no additional configuration needed.

## Next Steps After Setup

Once Firebase is working:
1. Implement email link handling from Encharge/backend (dynamic links or custom scheme)
2. Add StreakService to update composure streaks on telemetry completion
3. Implement telemetry foreground tracking via `TelemetryService`
4. Add push notifications for daily reminders (using Firebase Cloud Messaging)
5. Consider implementing Hive-based local cache for telemetry when offline

You're now ready to build and test the FMG companion app with real Firebase backend!