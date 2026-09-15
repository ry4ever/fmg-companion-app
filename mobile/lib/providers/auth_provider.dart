import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/athlete_user.dart';
import '../models/weekly_schedule.dart';
import '../services/demo_store.dart';
import '../services/firestore_service.dart';
import '../services/onboarding_storage.dart';
import '../services/streak_service.dart';
import '../utils/constants.dart';
import '../utils/archetype_engine.dart';

/// Flag indicating whether Firebase is available for use.
/// Set during main.dart initialization.
bool get isFirebaseAvailable => _isFirebaseAvailable;
bool _isFirebaseAvailable = true;

/// Flag indicating whether the app is running in demo mode (bypasses Firebase).
bool get isDemoMode => _isDemoMode;
bool _isDemoMode = false;

/// Mark demo mode state.
void setDemoMode(bool value) {
  _isDemoMode = value;
  if (value) {
    final demoAthlete = _demoAthleteUser();
    final demoSchedule = _demoWeeklySchedule();
    DemoStore().save(athlete: demoAthlete, schedule: demoSchedule);
  }
}

/// Mark Firebase availability status. Called by main.dart.
void setFirebaseAvailable(bool value) {
  _isFirebaseAvailable = value;
}

/// Demo user credentials.
const String demoUid = 'demo_user_demo';
const String demoEmail = 'demo@example.com';
const String demoName = 'Demo Athlete';

/// Firestore service provider
final firestoreServiceProvider = Provider((ref) => FirestoreService());

/// Simple demo user model for when Firebase is not available
class DemoUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isAnonymous;

  DemoUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isAnonymous = true,
  });
}

/// Auth state provider — watches Firebase Auth sign-in state
final authStateProvider = StreamProvider<DemoUser?>((ref) {
  // Demo mode: return a fixed demo user
  if (isDemoMode) {
    final demoUser = DemoUser(
      uid: demoUid,
      email: demoEmail,
      displayName: demoName,
    );
    return Stream.value(demoUser);
  }

  if (!isFirebaseAvailable) return const Stream<DemoUser?>.empty();
  return FirebaseAuth.instance.authStateChanges().map((firebaseUser) {
    if (firebaseUser == null) return null;
    return DemoUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isAnonymous: firebaseUser.isAnonymous,
    );
  });
});

/// Athlete user provider — watches the current athlete user doc in Firestore
/// or DemoStore in demo mode.
final athleteUserProvider = StreamProvider<AthleteUser?>((ref) {
  // Demo mode: return static demo athlete data immediately
  if (isDemoMode) {
    return Stream.value(_demoAthleteUser());
  }

  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  if (uid == null) return Stream.value(null);

  if (!isFirebaseAvailable) return Stream.value(null);
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
/// or DemoStore in demo mode.
final weeklyScheduleProvider = StreamProvider<WeeklySchedule?>((ref) {
  // Demo mode: return static demo weekly schedule immediately
  if (isDemoMode) {
    return Stream.value(_demoWeeklySchedule());
  }

  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  if (uid == null) return Stream.value(null);

  if (!isFirebaseAvailable) return Stream.value(null);
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

/// Demo athlete user used when running in demo mode without Firebase.
AthleteUser _demoAthleteUser() {
  final archetype = Archetype.resilientBounceback;
  final archetypeName = AppStrings.getArchetypeName(archetype);

  return AthleteUser(
    uid: demoUid,
    parentUid: '',
    name: demoName,
    role: 'athlete',
    assignedArchetype: archetypeName,
    onboardingCompleted: true,
    composureStreak: 0,
    lastCompletedTimestamp: '',
    shirtEligibleFlag: false,
    shirtStatus: 'unclaimed',
    subscriptionStatus: 'active',
  );
}

/// Demo weekly schedule used when running in demo mode without Firebase.
WeeklySchedule _demoWeeklySchedule() {
  final archetype = Archetype.resilientBounceback;
  final activeSessions = ArchetypeEngine.getActiveSessions(archetype, 'Midfielder');

  return WeeklySchedule(
    activeWeekStart: DateTime.now().toUtc().toIso8601String(),
    isCustomMode: true,
    days: {
      'monday': DailySchedule(sessionId: activeSessions[0], completed: false),
      'tuesday': DailySchedule(sessionId: activeSessions[1], completed: false),
      'wednesday': DailySchedule(sessionId: activeSessions[2], completed: false),
      'thursday': DailySchedule(sessionId: activeSessions[0], completed: false),
      'friday': DailySchedule(sessionId: activeSessions[1], completed: false),
      'saturday': DailySchedule(sessionId: activeSessions[2], completed: false),
      'sunday': DailySchedule(sessionId: null, completed: false),
    },
  );
}

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