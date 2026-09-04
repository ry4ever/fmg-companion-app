import 'package:cloud_firestore/cloud_firestore.dart';

/// Streak management service.
///
/// Handles composure streak increment, reset, and shirt eligibility checks.
class StreakService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Increment the athlete's composure streak by 1 and update last completed timestamp.
  ///
  /// Also checks and updates shirt eligibility (>= 30 day streak).
  Future<void> incrementStreak(String athleteUid) async {
    final ref = _db.collection('users').doc(athleteUid);
    final now = DateTime.now();
    final nowIso = now.toUtc().toIso8601String();

    // Get current user to check existing streak
    final doc = await ref.get();
    final currentStreak = (doc.data()?['composure_streak'] as int?) ?? 0;
    final newStreak = currentStreak + 1;

    // Shirt eligibility: 30+ day streak
    final shirtEligible = newStreak >= 30;

    await ref.update({
      'composure_streak': newStreak,
      'last_completed_timestamp': nowIso,
      'shirt_eligible_flag': shirtEligible,
    });
  }

  /// Check if the athlete's streak should be reset.
  ///
  /// If the last completed timestamp is more than 1 day in the past
  /// (i.e., yesterday was missed), reset composure_streak to 0.
  ///
  /// Call this on app launch to enforce streak integrity.
  Future<bool> checkAndResetStreak(String athleteUid) async {
    final doc = await _db.collection('users').doc(athleteUid).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final lastCompleted = data['last_completed_timestamp'] as String?;
    final currentStreak = (data['composure_streak'] as int?) ?? 0;

    // No streak to check if never completed
    if (lastCompleted == null || lastCompleted.isEmpty) return false;
    if (currentStreak == 0) return false; // Already reset

    final lastDate = DateTime.tryParse(lastCompleted);
    if (lastDate == null) return false;

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);

    // If last completion was before yesterday, streak is broken
    if (lastDateOnly.isBefore(yesterday)) {
      await _db.collection('users').doc(athleteUid).update({
        'composure_streak': 0,
      });
      return true; // Streak was reset
    }

    return false; // Streak intact
  }

  /// Get the current streak value for an athlete.
  Future<int> getStreak(String athleteUid) async {
    final doc = await _db.collection('users').doc(athleteUid).get();
    return (doc.data()?['composure_streak'] as int?) ?? 0;
  }

  /// Check if athlete is eligible for a shirt (30+ day streak).
  Future<bool> isShirtEligible(String athleteUid) async {
    final streak = await getStreak(athleteUid);
    return streak >= 30;
  }
}
