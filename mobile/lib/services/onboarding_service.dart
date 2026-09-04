import 'package:firebase_auth/firebase_auth.dart';
import '../models/athlete_user.dart';
import '../models/onboarding_state.dart';
import '../services/firestore_service.dart';
import '../services/onboarding_storage.dart';
import '../utils/archetype_engine.dart';

/// Orchestrates the onboarding completion flow:
/// 1. Calculate archetype + active sessions via ArchetypeEngine
/// 2. Generate weekly schedule
/// 3. Persist athlete user + weekly schedule to Firestore
/// 4. Clear local onboarding cache
class OnboardingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final OnboardingStorage _storage = OnboardingStorage();

  /// Complete onboarding for the current user.
  Future<void> completeOnboarding({
    required String? position,
    required String? matchDayTarget,
    required String? roadblock,
    required String? trainingFrequency,
    required String? competitiveLevel,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Build the onboarding state for the archetype engine
    final state = OnboardingState(
      currentStep: 5,
      position: position,
      matchDayTarget: matchDayTarget,
      roadblock: roadblock,
      trainingFrequency: trainingFrequency,
      competitiveLevel: competitiveLevel,
    );

    final archetype = ArchetypeEngine.assignArchetype(roadblock ?? '');
    final archetypeName = AppStrings.getArchetypeName(archetype);
    final schedule = ArchetypeEngine.generateWeeklySchedule(state);

    // Update athlete user in Firestore
    final existingUser = await _firestore.getAthleteUser(user.uid);
    final updatedUser = AthleteUser(
      uid: user.uid,
      parentUid: existingUser?.parentUid ?? '',
      name: existingUser?.name ?? user.email?.split('@').first ?? 'Athlete',
      role: 'athlete',
      assignedArchetype: archetypeName,
      onboardingCompleted: true,
      composureStreak: existingUser?.composureStreak ?? 0,
      lastCompletedTimestamp: existingUser?.lastCompletedTimestamp ?? '',
      shirtEligibleFlag: existingUser?.shirtEligibleFlag ?? false,
      shirtStatus: existingUser?.shirtStatus ?? 'unclaimed',
      subscriptionStatus: existingUser?.subscriptionStatus ?? 'active',
    );

    await _firestore.upsertAthleteUser(user.uid, updatedUser);
    await _firestore.setWeeklySchedule(user.uid, schedule);

    // Clear local onboarding cache
    await _storage.clearLocalState();
  }
}