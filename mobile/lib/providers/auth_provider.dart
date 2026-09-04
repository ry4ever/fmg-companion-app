import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/athlete_user.dart';
import '../models/weekly_schedule.dart';
import '../services/firestore_service.dart';
import '../services/onboarding_storage.dart';
import '../services/streak_service.dart';
import '../utils/constants.dart';

/// Firestore service provider
final firestoreServiceProvider = Provider((ref) => FirestoreService());

/// Auth state provider — watches Firebase Auth sign-in state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Athlete user provider — watches the current athlete user doc in Firestore
///
/// The athlete's auth UID is the document key for /users/{athleteUid}.
final athleteUserProvider = StreamProvider<AthleteUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  if (uid == null) return const Stream.value(null);

  final firestoreService = ref.read(firestoreServiceProvider);
  final stream = firestoreService.watchAthleteUser(uid);

  // Side effect: check streak integrity when user data is first loaded
  return stream.map((user) {
    if (user != null) {
      // Fire-and-forget: reset streak if day was missed
      StreakService().checkAndResetStreak(uid);
    }
    return user;
  });
});

/// Weekly schedule provider — watches /users/{uid}/schedules/weekly
final weeklyScheduleProvider = StreamProvider<WeeklySchedule?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  if (uid == null) return const Stream.value(null);

  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.watchWeeklySchedule(uid);
});

/// Is premium provider — computed from the athlete user's subscription status
final isPremiumProvider = Provider<bool>((ref) {
  final athleteUser = ref.watch(athleteUserProvider);
  return athleteUser.maybeWhen(
    data: (user) => user?.subscriptionStatus == 'active',
    orElse: () => false,
  );
});

/// Onboarding completed provider
final onboardingCompletedProvider = Provider<bool>((ref) {
  final athleteUser = ref.watch(athleteUserProvider);
  return athleteUser.maybeWhen(
    data: (user) => user?.onboardingCompleted ?? false,
    orElse: () => false,
  );
});

/// Cached onboarding step provider — reads from local OnboardingStorage
final cachedStepProvider = FutureProvider<int>((ref) async {
  final storage = OnboardingStorage();
  final state = await storage.retrieveLocalState();
  return state?.currentStep ?? 0;
});

/// Daily session provider — returns the sessionId scheduled for today.
///
/// Looks up the current day-of-week in the user's weekly schedule. Returns
/// null on rest days, or if the user has no schedule yet.
final dailySessionProvider = Provider<DailySession?>((ref) {
  final weeklyAsync = ref.watch(weeklyScheduleProvider);
  return weeklyAsync.maybeWhen(
    data: (schedule) {
      if (schedule == null) return null;
      final todayKey = DayKeys.forToday();
      final day = schedule.days[todayKey];
      if (day == null || day.sessionId == null || day.sessionId!.isEmpty) {
        return const DailySession(isRestDay: true);
      }
      final info = SessionCatalog.forId(day.sessionId!);
      return DailySession(
        isRestDay: false,
        sessionId: day.sessionId,
        sessionName: info.name,
        targetDurationSeconds: info.targetDurationSeconds,
        alreadyCompleted: day.completed,
      );
    },
    orElse: () => null,
  );
});

class DailySession {
  final bool isRestDay;
  final String? sessionId;
  final String? sessionName;
  final int? targetDurationSeconds;
  final bool alreadyCompleted;

  const DailySession({
    required this.isRestDay,
    this.sessionId,
    this.sessionName,
    this.targetDurationSeconds,
    this.alreadyCompleted = false,
  });
}