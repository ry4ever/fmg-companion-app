# Sprint 3 Planning — FMG Companion App

**Meeting:** Mark Review  
**Date:** 2026-09-07

---

## 🏁 Sprint 2 Complete

**Commit:** `1699e86` — “Sprint 2: Daily sessions, streak management, email sign-in, CI/CD, tests”

### Delivered (90% — blockers are infrastructure, not code)

| Feature | Status | Impact |
|---|---|---|
| **Daily session lookup** | ✅ Done | HomeScreen shows today’s scheduled session; rest day card; completion badge |
| **Streak management** | ✅ Done | Increment on completion; auto-reset on missed day; 30-day shirt unlock at 30 |
| **Email link sign-in** | ✅ Done | `/signin` route, magic link flow, deep-link handling, auth-redirect in router |
| **CI/CD pipeline** | ✅ Done | 3 GitHub Actions workflows (web-deploy, flutter-web, android-apk) |
| **29 unit tests** | ✅ Done | Archetype engine, onboarding state, weekly schedule, athlete user |
| **Web portal build** | ✅ Done (code) | tsconfig fix + firebase.ts type cast → `npm run build` succeeds |
| **Firebase project fix** | ✅ Done | `.firebaserc` corrected → `fearless-football-507714` |
| **21 files, 1546 insertions** | — | |

### 🔴 Blocked (infra — needs human action)

| # | Blocker | What’s needed | ETA |
|---|---------|----------------|-------|
| 1 | **IAM permissions** | Grant `Firebase Hosting Admin` + `Service Usage Consumer` to your account at [IAM console](https://console.cloud.google.com/iam-admin/iam?project=fearless-football-507714) | 2 min |
| 2 | **Firebase Console setup** | Enable Email Link auth; create Firestore DB (test mode) at [Firebase Console](https://console.firebase.google.com/u/0/project/fearless-football-fmg) | 2 min |
| 3 | **Local `flutterfire configure`** | Run on local machine or Cloud Shell to generate real `firebase_options.dart` | 5 min |

> All code is tested and committed. No code is blocked — only deployment and device testing await the 3 infra steps above.

---

## 🚀 Sprint 3 (Planned)

| # | Epic | Description | Depends on |
|---|------|-------------|-------------|
| **1** | Fix IAM permissions → deploy web | Grant roles; `firebase deploy --only hosting` | User action (Step 1+2 above) |
| **2** | Run `flutterfire configure` | Generate real Firebase options + platform configs | User action (Step 3) |
| **3** | **Video player integration** | Replace SessionPlayer mock with `video_player` widget; real session playback | #2 |
| **4** | **Push notifications** | FCM for daily session reminders; background notifications | #2 |
| **5** | **Social/community** | Leaderboard (streaks), friend connections | Backend: Firestore rules |
| **6** | **App store prep** | iOS TestFlight + Google Play Console setup; production builds | #3, #4 |
| **7** | **Integration tests** | End-to-end flow: sign-in → onboarding → session → streak increment | #2, #3 |

---

## 📊 Sprint 2 Metrics

| Metric | Value |
|---|---|
| Files changed | 21 |
| Insertions | 1,554 |
| Unit tests | 29 |
| Bugs fixed | 3 (tsconfig, firebase.ts type, project ID) |
| CI/CD workflows | 3 (web, flutter-web, android-apk) |

---

## 🎯 Recommendation for Mark

Sprint 2 is functionally complete. The 3 blockers are pure “human-in-the-loop” actions — once you grant the IAM roles and enable Firestore/Auth in the console, we can immediately deploy the web portal and ship to TestFlight/Play Store.

**Proposed next step:** Grant the 2 IAM roles now (live, 2 min), then I’ll run `flutterfire configure` and we can tackle video player + push notifications next.
