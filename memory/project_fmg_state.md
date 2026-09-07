---
name: FMG project current state
description: FMG mobile app state as of 2026-09-03 — backend and mobile integration complete, screens wired to real Firestore data
type: project
originSessionId: 6fa01c06-ec65-4e07-9c85-fc8558027fdc
originSessionId2: 97c3ee3a-ecf0-449e-a6f6-7bbc5b1a6a1b
---

As of 2026-09-03, the FMG (Football Mind Gym) project is a mobile-only Flutter app backed by Firebase (Auth + Firestore + Cloud Functions).

**Backend (Sprint 1, original):**
- `functions/src/stripeWebhook.ts` — Stripe checkout webhook, creates parent/athlete Firestore docs, triggers Encharge welcome
- `functions/src/streakTrigger.ts` — Firestore trigger on telemetry writes, calculates daily streaks, shirt eligibility at 30 days

**Mobile architecture (flutter_riverpod + go_router + Firebase):**

| File | Purpose |
|------|---------|
| `lib/providers/auth_provider.dart` | `authStateProvider`, `athleteUserProvider`, `weeklyScheduleProvider`, `isPremiumProvider`, `onboardingCompletedProvider`, `cachedStepProvider` |
| `lib/services/onboarding_service.dart` | Completes onboarding: archetype mapping via `ArchetypeEngine`, generates weekly schedule, upserts Firestore |
| `lib/services/telemetry_scheduler.dart` | Foreground telemetry with `WidgetsBindingObserver`, 95% completion validation, Firestore batch write |
| `lib/services/firestore_service.dart` | All CRUD for athlete users, telemetry, weekly schedules + `watchWeeklySchedule` stream |
| `lib/services/auth_service.dart` | Firebase Auth email link sign-in |
| `lib/services/onboarding_storage.dart` | Local persistence of onboarding state via `shared_preferences` |
| `lib/utils/archetype_engine.dart` | Archetype assignment from roadmap + active sessions mapping |
| `lib/utils/constants.dart` | All enums, Firestore paths, UI strings |

**Screens (wired to real data via Riverpod providers):**

| Screen | Data |
|--------|------|
| `home_screen.dart` | Athlete profile, streak counter, weekly schedule grid, archetype card, "Start Session" button |
| `my_gym_screen.dart` | Stats row (streak + sessions), archetype info with active sessions, weekly plan, parent conversation starter |
| `onboarding_screen.dart` | 5-question survey → `OnboardingService.completeOnboarding()` → `/my-gym` |
| `paywall_screen.dart` | Stub — needs Stripe web checkout link (billing stays on web per spec) |

**Still needs:**
- `firebase_options.dart` — Placeholder `YOUR_*` config; run `flutterfire configure`
- Session playback screen — Integrate `video_player` + `TelemetryScheduler` with `TelemetryObserver` widget
- Magic link deep link handling in `AuthService` for onboarding completion
- `CalendarScreen` (tab 2) — placeholder, needs weekly schedule view
- `CommunityScreen` (tab 3) — placeholder, no spec yet

**How to apply:** Focus on `mobile/lib/`. Backend functions exist in `functions/` but are from old Sprint 1. If backend changes needed, update there.
