/// Athlete user document matching Firestore schema:
/// /users/{athleteAuthUid}
class AthleteUser {
  final String uid;
  final String parentUid;
  final String name;
  final String role;
  final String assignedArchetype;
  final bool onboardingCompleted;
  final int composureStreak;
  final String lastCompletedTimestamp; // ISO 8601
  final bool shirtEligibleFlag;
  final String shirtStatus; // 'unclaimed' | 'shipped' | 'delivered'
  final String subscriptionStatus; // 'active' | 'inactive'

  AthleteUser({
    required this.uid,
    required this.parentUid,
    required this.name,
    required this.role,
    required this.assignedArchetype,
    required this.onboardingCompleted,
    required this.composureStreak,
    required this.lastCompletedTimestamp,
    required this.shirtEligibleFlag,
    required this.shirtStatus,
    this.subscriptionStatus = 'inactive',
  });

  factory AthleteUser.fromMap(Map<String, dynamic> map) {
    return AthleteUser(
      uid: map['uid'] as String,
      parentUid: map['parent_uid'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      assignedArchetype: map['assigned_archetype'] as String,
      onboardingCompleted: map['onboarding_completed'] as bool,
      composureStreak: map['composure_streak'] as int,
      lastCompletedTimestamp: map['last_completed_timestamp'] as String,
      shirtEligibleFlag: map['shirt_eligible_flag'] as bool,
      shirtStatus: map['shirt_status'] as String,
      subscriptionStatus: map['subscription_status'] as String? ?? 'inactive',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'parent_uid': parentUid,
      'name': name,
      'role': role,
      'assigned_archetype': assignedArchetype,
      'onboarding_completed': onboardingCompleted,
      'composure_streak': composureStreak,
      'last_completed_timestamp': lastCompletedTimestamp,
      'shirt_eligible_flag': shirtEligibleFlag,
      'shirt_status': shirtStatus,
      'subscription_status': subscriptionStatus,
    };
  }
}