import 'package:flutter_test/flutter_test.dart';
import 'package:fmg_companion/models/athlete_user.dart';

void main() {
  group('AthleteUser', () {
    test('fromMap parses all fields', () {
      final map = {
        'uid': 'athlete-123',
        'parent_uid': 'parent-456',
        'name': 'John Smith',
        'role': 'athlete',
        'assigned_archetype': 'The Calm Operator',
        'onboarding_completed': true,
        'composure_streak': 12,
        'last_completed_timestamp': '2024-09-01T10:30:00Z',
        'shirt_eligible_flag': false,
        'shirt_status': 'unclaimed',
        'subscription_status': 'active',
      };
      final user = AthleteUser.fromMap(map);

      expect(user.uid, equals('athlete-123'));
      expect(user.parentUid, equals('parent-456'));
      expect(user.name, equals('John Smith'));
      expect(user.role, equals('athlete'));
      expect(user.assignedArchetype, equals('The Calm Operator'));
      expect(user.onboardingCompleted, isTrue);
      expect(user.composureStreak, equals(12));
      expect(user.lastCompletedTimestamp, equals('2024-09-01T10:30:00Z'));
      expect(user.shirtEligibleFlag, isFalse);
      expect(user.shirtStatus, equals('unclaimed'));
      expect(user.subscriptionStatus, equals('active'));
    });

    test('fromMap defaults subscription_status to inactive', () {
      final map = {
        'uid': 'athlete-123',
        'parent_uid': 'parent-456',
        'name': 'Jane Doe',
        'role': 'athlete',
        'assigned_archetype': 'The Resilient Bounceback',
        'onboarding_completed': false,
        'composure_streak': 0,
        'last_completed_timestamp': '',
        'shirt_eligible_flag': false,
        'shirt_status': 'unclaimed',
      };
      final user = AthleteUser.fromMap(map);

      expect(user.subscriptionStatus, equals('inactive'));
    });

    test('toMap produces correct output', () {
      final user = AthleteUser(
        uid: 'athlete-123',
        parentUid: 'parent-456',
        name: 'John Smith',
        role: 'athlete',
        assignedArchetype: 'The Calm Operator',
        onboardingCompleted: true,
        composureStreak: 12,
        lastCompletedTimestamp: '2024-09-01T10:30:00Z',
        shirtEligibleFlag: true,
        shirtStatus: 'shipped',
        subscriptionStatus: 'active',
      );
      final map = user.toMap();

      expect(map['uid'], equals('athlete-123'));
      expect(map['parent_uid'], equals('parent-456'));
      expect(map['name'], equals('John Smith'));
      expect(map['assigned_archetype'], equals('The Calm Operator'));
      expect(map['onboarding_completed'], isTrue);
      expect(map['composure_streak'], equals(12));
      expect(map['shirt_eligible_flag'], isTrue);
      expect(map['shirt_status'], equals('shipped'));
      expect(map['subscription_status'], equals('active'));
    });

    test('round-trip: toMap -> fromMap preserves data', () {
      final original = AthleteUser(
        uid: 'athlete-999',
        parentUid: 'parent-111',
        name: 'Test Athlete',
        role: 'athlete',
        assignedArchetype: 'The Unshakable Competitor',
        onboardingCompleted: true,
        composureStreak: 30,
        lastCompletedTimestamp: '2024-09-05T08:00:00Z',
        shirtEligibleFlag: true,
        shirtStatus: 'delivered',
        subscriptionStatus: 'active',
      );
      final restored = AthleteUser.fromMap(original.toMap());

      expect(restored.uid, equals(original.uid));
      expect(restored.parentUid, equals(original.parentUid));
      expect(restored.name, equals(original.name));
      expect(restored.assignedArchetype, equals(original.assignedArchetype));
      expect(restored.onboardingCompleted, equals(original.onboardingCompleted));
      expect(restored.composureStreak, equals(original.composureStreak));
      expect(restored.shirtEligibleFlag, equals(original.shirtEligibleFlag));
      expect(restored.subscriptionStatus, equals(original.subscriptionStatus));
    });

    test('shirt eligibility at exactly 30 days', () {
      final map = {
        'uid': 'athlete-30',
        'parent_uid': 'parent-1',
        'name': 'Shirt Eligible Athlete',
        'role': 'athlete',
        'assigned_archetype': 'The Sharp Decision-Maker',
        'onboarding_completed': true,
        'composure_streak': 30,
        'last_completed_timestamp': '2024-09-05T10:00:00Z',
        'shirt_eligible_flag': true,
        'shirt_status': 'unclaimed',
        'subscription_status': 'active',
      };
      final user = AthleteUser.fromMap(map);
      expect(user.composureStreak, equals(30));
      expect(user.shirtEligibleFlag, isTrue);
    });
  });
}
