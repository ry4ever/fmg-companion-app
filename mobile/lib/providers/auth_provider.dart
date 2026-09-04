import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/athlete_user.dart';
import '../models/weekly_schedule.dart';
import '../services/firestore_service.dart';
import '../services/onboarding_storage.dart';

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
  if (authState == null) return const Stream.value(null);

  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.watchAthleteUser(authState.uid);
});

/// Weekly schedule provider — watches /users/{uid}/schedules/weekly
final weeklyScheduleProvider = StreamProvider<WeeklySchedule?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState == null) return const Stream.value(null);

  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.watchWeeklySchedule(authState.uid);
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