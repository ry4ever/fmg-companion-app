# GitHub Actions CI/CD Setup

This directory contains automated deployment workflows for the FMG app.

## Workflows

### `web-deploy.yml` — Deploy Next.js web portal to Firebase Hosting
- **Trigger:** Push to `main` when `web/` files change
- **What it does:**
  1. Checks out code
  2. Installs Node dependencies
  3. Builds Next.js app (with Firebase env vars)
  4. Deploys to Firebase Hosting live channel

### `flutter-web.yml` — Build Flutter web app
- **Trigger:** Push to `main` when `mobile/` files change
- **What it does:**
  1. Checks out code
  2. Sets up Flutter 3.27.3
  3. Runs `flutter pub get`, `flutter analyze`, `flutter test`
  4. Builds Flutter web (outputs to `mobile/build/web/`)
  5. Uploads artifact for 7 days

### `android-apk.yml` — Build Android APK
- **Trigger:** Push to `main` when `mobile/` files change, or on version tags (`v*`)
- **What it does:**
  1. Checks out code
  2. Sets up Java 17 + Flutter
  3. Builds release APK
  4. Signs APK (if keystore secrets are set)
  5. Uploads artifact for 30 days
  6. Optionally deploys to Firebase App Distribution

## Required GitHub Secrets

Add these under **Settings → Secrets and variables → Actions**:

### Firebase (for `web-deploy.yml`)
| Secret Name | Description | How to get |
|------------|-------------|-------------|
| `FIREBASE_SERVICE_ACCOUNT` | Firebase service account JSON | Firebase Console → IAM → Service Accounts → Create New Key → JSON. Paste entire JSON as secret value. |

### Next.js Web App (for `web-deploy.yml` — build-time env vars)
| Secret Name | Description |
|------------|-------------|
| `NEXT_PUBLIC_FIREBASE_API_KEY` | Firebase Web API key |
| `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN` | e.g. `the-secret-super-app.firebaseapp.com` |
| `NEXT_PUBLIC_FIREBASE_PROJECT_ID` | `the-secret-super-app` |
| `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET` | e.g. `the-secret-super-app.appspot.com` |
| `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID` | Firebase project messaging sender ID |
| `NEXT_PUBLIC_FIREBASE_APP_ID` | Firebase Web app ID |

### Firebase App Distribution (for `android-apk.yml`)
| Secret Name | Description |
|------------|-------------|
| `FIREBASE_TOKEN` | CLI refresh token for Firebase auth. Get with: `firebase login:ci` |
| `FIREBASE_APP_ID` | Firebase Android app ID (e.g. `1:xxx:android:yyy`) |
| `FIREBASE_TESTER_GROUPS` | Comma-separated tester group names in Firebase console |

### Android Signing (optional — for `android-apk.yml`)
Required only if you want to publish to Google Play.
| Secret Name | Description |
|------------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded `.jks` keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias |

## How to Get Firebase Secrets

### Service Account Key
1. Go to [Firebase Console](https://console.firebase.google.com/) → your project
2. **IAM → Service Accounts → Create Service Account**
3. Grant **Firebase Admin** role
4. Generate new **JSON key** → download
5. Paste the entire JSON as the `FIREBASE_SERVICE_ACCOUNT` secret

### Firebase CLI Token (for App Distribution)
```bash
firebase login:ci
# Opens browser → authorize → copies token to clipboard
```

### Firebase Env Vars (Next.js web app)
1. Firebase Console → **Project Settings → Your apps → Web app**
2. Copy the `firebaseConfig` object values

## Adding Secrets to GitHub

```bash
# Via GitHub CLI
gh secret set FIREBASE_SERVICE_ACCOUNT < service-account.json
gh secret set NEXT_PUBLIC_FIREBASE_API_KEY --body "AIza..."
# etc.
```

Or go to: `https://github.com/<org>/<repo>/settings/secrets/actions`

## Deployment Flow

```
Push to main (web/ changes)
  → web-deploy.yml runs
  → Next.js builds with env vars
  → Deploys to Firebase Hosting live
  → Site live at https://the-secret-super-app.web.app

Push to main (mobile/ changes)
  → flutter-web.yml runs
  → Flutter analyzes, tests, builds
  → Artifact uploaded to GitHub Actions

Tag v1.0.0 (mobile/ changes)
  → android-apk.yml runs
  → APK built and signed
  → Uploads artifact
  → Optionally pushes to Firebase App Distribution
```

## Local CI Test

To run workflows locally before pushing:
```bash
# Install act (GitHub Actions local runner)
brew install act

# Run web deploy workflow
act push -W .github/workflows/web-deploy.yml --secret-file .secrets
```
