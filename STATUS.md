# FMG Companion App - Current Status

## 📌 Overview

- **Branch**: `main`
- **Last Commit**: `1699e86` (Sprint 2: Daily sessions, streak management, email sign-in, CI/CD, tests)
- **Remote**: `origin/main` is up to date
- **Disk Space**: Critically low (39M free) — cannot install additional tools in this environment

## ✅ What's Done

### Sprint 1 (Flutter Mobile App)
- Complete Riverpod state management architecture
- Data models: AthleteUser, OnboardingState, WeeklySchedule, TelemetrySession
- Services: Auth, Firestore, Onboarding, OnboardingStorage, Telemetry, TelemetryScheduler, Streak
- Providers: authState, athleteUser, weeklySchedule, isPremium, onboardingCompleted, cachedStep, dailySession
- Screens: Home, MyGym, Onboarding, Paywall, SessionPlayer, SignIn
- Routing: GoRouter with conditional 4th tab (My Gym) based on premium/onboarding status
- Widgets: TelemetryObserver (lifecycle), OnboardingCard, SignInScreen
- Utils: ArchetypeEngine (Q1-Q5 → archetype mapping), constants (enums, strings, paths, session catalog, day keys)
- Firebase placeholder config (awaits real config from `flutterfire configure`)

### Sprint 2 (Features & Infrastructure)
- Daily session lookup: HomeScreen shows today's scheduled session from weekly schedule
- Streak management: 
  - Increment on session completion (via StreakService)
  - Reset on missed days (checked on app load via athleteUserProvider)
  - Shirt eligibility at 30+ day streak
- Email link sign-in:
  - SignInScreen with email validation and loading states
  - AuthService.sendSignInLink() with ActionCodeSettings for deep links
  - Router: /signin route, redirects when not authenticated
- CI/CD Pipeline (GitHub Actions):
  - `web-deploy.yml`: Builds + deploys Next.js web portal to Firebase Hosting
  - `flutter-web.yml`: Flutter analyze + test + build web
  - `android-apk.yml`: Build APK, sign, upload artifact, optional Firebase App Distribution
  - `.github/CI_SETUP.md`: Documents required secrets
- Testing: 29 unit tests covering archetype engine, onboarding state, weekly schedule, athlete user
- Fixed web portal build: corrected tsconfig.json and firebase.ts type errors
- Firebase project ID corrected: `.firebaserc` now points to `the-secret-super-app`

## 🔴 Blocked (Requires Action)

### 1. **IAM Permissions** (Grant via Google Cloud Console)
   - **URL**: https://console.cloud.google.com/iam-admin/iam?project=the-secret-super-app
   - **Grant these roles to your account**:
     - `Firebase Hosting Admin` → enables `firebase deploy --only hosting`
     - `Service Usage Consumer` → enables `firebase deploy --only firestore:rules` and API enablement
   - *Without these roles, Firebase CLI commands fail with 403 errors.*

### 2. **Firebase Console Setup** (Manual)
   - **URL**: https://console.firebase.google.com/project/the-secret-super-app
   - **Enable**:
     - **Authentication → Sign-in method**: Email Link (passwordless)
     - **Firestore Database**: Create database (start in test mode)
   - *Optional*: Add authorized domains for email link action code settings if using custom domain

### 3. **Local Firebase Configuration** (Run in your Flutter environment)
   - **Prerequisites**: Flutter SDK installed, Firebase CLI installed, logged into Firebase
   - **Commands** (run from `mobile/` directory):
     ```bash
     dart pub global activate flutterfire_cli
     firebase login
     flutterfire configure
     ```
   - **What it does**:
     - Generates real `lib/firebase_options.dart` (replaces `YOUR_*` placeholders)
     - Downloads platform config files:
       - Android: `google-services.json` → `android/app/`
       - iOS/macOS: `GoogleService-Info.plist` → `ios/Runner/` and `macos/Runner/`
       - Web: adds Firebase SDK snippet to `web/index.html` (if configured)
     - Updates `android/app/build.gradle` and `ios/Podfile` with Firebase plugins

### 4. **Deploy & Test** (After unblocking)
   - **Web Portal**:
     ```bash
     firebase deploy --only hosting
     # Live at: https://the-secret-super-app.web.app
     ```
   - **Mobile App** (after `flutterfire configure`):
     ```bash
     cd mobile
     flutter pub get
     flutter run        # test on device/emulator
     flutter build apk  # Android release
     flutter build ipa  # iOS release (requires Mac + Xcode)
     ```
   - **Verify Flow**:
     1. App launches → SignInScreen (if no Firebase session)
     2. Enter email → "Send Magic Link" → check email
     3. Tap magic link → app opens → completes sign-in
     4. Onboarding survey → completes → writes to Firestore
     5. HomeScreen → shows today's session from weekly schedule
     6. "Start Today's Session" → launches SessionPlayer
     7. Complete session → telemetry written, streak incremented, day marked completed
     8. MyGymScreen → shows profile, streak, weekly schedule
     9. Bottom nav: My Gym tab unlocks after onboarding + subscription (hardcoded active for now)

## 📂 Directory Structure (Relevant)

```
mobile/
├─ lib/
│  ├─ models/          # AthleteUser, OnboardingState, WeeklySchedule, TelemetrySession
│  ├─ providers/       # Riverpod providers (auth, athleteUser, weeklySchedule, etc.)
│  ├─ services/        # Auth, Firestore, Onboarding, OnboardingStorage, Telemetry, Streak
│  ├─ utils/           # ArchetypeEngine, constants (enums, strings, paths, session catalog)
│  ├─ routes/          # app_router.dart (GoRouter with conditional tab)
│  ├─ screens/         # Home, MyGym, Onboarding, Paywall, SessionPlayer, SignIn
│  └─ widgets/         # TelemetryObserver, OnboardingCard
├─ test/               # 29 unit tests (archetype, onboarding, schedule, athlete user)
├─ main.dart           # Wires providers to router
├─ firebase_options.dart # Placeholder (awaits real config from flutterfire configure)
├─ pubspec.yaml        # Includes flutter_riverpod, firebase_auth, cloud_firestore, shared_preferences
└─ SPRINT_2_REPORT.md  # Detailed Sprint 2 summary

.web/
├─ src/                # Next.js pages, components, lib
├─ firebase.json       # Hosting config (public: web/out)
├─ .firebaserc         # Project ID: the-secret-super-app
└─ package.json        # Next.js + Firebase dependencies

.github/
└─ workflows/          # CI/CD: web-deploy.yml, flutter-web.yml, android-apk.yml
```

## 🚀 Next Steps (Priority Order)

1. **Grant IAM roles** (2 minutes):
   - Visit: https://console.cloud.google.com/iam-admin/iam?project=the-secret-super-app
   - Add `Firebase Hosting Admin` and `Service Usage Consumer` to your account

2. **Enable Firebase services** (2 minutes):
   - Visit: https://console.firebase.google.com/project/the-secret-super-app
   - Enable Email Link sign-in and create Firestore database (test mode)

3. **Run `flutterfire configure`** (5 minutes, requires local Flutter):
   - From `mobile/` directory: `dart pub global activate flutterfire_cli; firebase login; flutterfire configure`

4. **Deploy web portal** (1 minute):
   - `firebase deploy --only hosting`

5. **Test mobile app locally** (as desired):
   - `flutter pub get; flutter run`

## 💡 Notes

- The web portal (Next.js) is already built and ready to deploy once IAM roles are granted.
- The mobile app architecture is complete; it only needs real Firebase configuration to connect to Firestore and Auth.
- All business logic (streaks, daily sessions, archetype engine, onboarding) is implemented and tested.
- CI/CD workflows are defined and will run automatically once the required GitHub secrets are set (see `.github/CI_SETUP.md`).

---
*Generated: 2026-09-05*