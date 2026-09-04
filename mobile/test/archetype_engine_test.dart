import 'package:flutter_test/flutter_test.dart';
import 'package:fmg_companion/utils/constants.dart';
import 'package:fmg_companion/utils/archetype_engine.dart';
import 'package:fmg_companion/models/onboarding_state.dart';

void main() {
  group('ArchetypeEngine.assignArchetype', () {
    test('maps Pre-Match Nerves to Calm Operator', () {
      expect(
        ArchetypeEngine.assignArchetype('Pre-Match Nerves'),
        equals(Archetype.calmOperator),
      );
    });

    test('maps The Error Spiral to Resilient Bounceback', () {
      expect(
        ArchetypeEngine.assignArchetype('The Error Spiral'),
        equals(Archetype.resilientBounceback),
      );
    });

    test('maps The Form Slump to Resilient Bounceback', () {
      expect(
        ArchetypeEngine.assignArchetype('The Form Slump'),
        equals(Archetype.resilientBounceback),
      );
    });

    test('maps Tactical Errors to Sharp Decision Maker', () {
      expect(
        ArchetypeEngine.assignArchetype('Tactical Errors'),
        equals(Archetype.sharpDecisionMaker),
      );
    });

    test('maps Sideline/Crowd Distractions to Unshakable Competitor', () {
      expect(
        ArchetypeEngine.assignArchetype('Sideline/Crowd Distractions'),
        equals(Archetype.unshakableCompetitor),
      );
    });

    test('maps Sideline Distractions to Unshakable Competitor', () {
      expect(
        ArchetypeEngine.assignArchetype('Sideline Distractions'),
        equals(Archetype.unshakableCompetitor),
      );
    });

    test('maps unknown roadblock to Resilient Bounceback (default)', () {
      expect(
        ArchetypeEngine.assignArchetype('Unknown Block'),
        equals(Archetype.resilientBounceback),
      );
    });
  });

  group('ArchetypeEngine.getActiveSessions', () {
    test('Calm Operator returns 3 sessions', () {
      final sessions = ArchetypeEngine.getActiveSessions(
        Archetype.calmOperator,
        'Attacker',
      );
      expect(sessions.length, equals(3));
      expect(sessions[0], equals('session_nerves_equal_performance'));
    });

    test('Resilient Bounceback returns 3 sessions', () {
      final sessions = ArchetypeEngine.getActiveSessions(
        Archetype.resilientBounceback,
        'Midfielder',
      );
      expect(sessions.length, equals(3));
      expect(sessions[0], equals('session_back_to_your_best'));
    });

    test('Sharp Decision Maker uses position for secondary sessions', () {
      final attackerSessions = ArchetypeEngine.getActiveSessions(
        Archetype.sharpDecisionMaker,
        'Attacker',
      );
      final defenderSessions = ArchetypeEngine.getActiveSessions(
        Archetype.sharpDecisionMaker,
        'Defender',
      );
      // Primary should be same
      expect(attackerSessions[0], equals('session_ice_cold_finisher'));
      expect(defenderSessions[0], equals('session_ice_cold_finisher'));
      // Secondary should differ by position
      expect(attackerSessions[1], isNot(equals(defenderSessions[1])));
    });

    test('Unshakable Competitor returns 3 sessions', () {
      final sessions = ArchetypeEngine.getActiveSessions(
        Archetype.unshakableCompetitor,
        'Goalkeeper',
      );
      expect(sessions.length, equals(3));
      expect(sessions[0], equals('session_unshakable'));
    });
  });

  group('ArchetypeEngine.generateWeeklySchedule', () {
    test('2 Days frequency produces 2 active days', () {
      final state = OnboardingState(
        currentStep: 5,
        position: 'Attacker',
        matchDayTarget: 'Calm & Composed',
        roadblock: 'Pre-Match Nerves',
        trainingFrequency: '2 Days',
        competitiveLevel: 'Club-Travel',
      );
      final schedule = ArchetypeEngine.generateWeeklySchedule(state);

      final activeDays = schedule.days.entries
          .where((e) => e.value.sessionId != null && e.value.sessionId!.isNotEmpty)
          .toList();

      expect(activeDays.length, equals(2));
    });

    test('3 Days frequency produces 3 active days', () {
      final state = OnboardingState(
        currentStep: 5,
        position: 'Attacker',
        matchDayTarget: 'Calm & Composed',
        roadblock: 'Pre-Match Nerves',
        trainingFrequency: '3 Days',
        competitiveLevel: 'Club-Travel',
      );
      final schedule = ArchetypeEngine.generateWeeklySchedule(state);

      final activeDays = schedule.days.entries
          .where((e) => e.value.sessionId != null && e.value.sessionId!.isNotEmpty)
          .toList();

      expect(activeDays.length, equals(3));
    });

    test('5 Days frequency produces 5 active days', () {
      final state = OnboardingState(
        currentStep: 5,
        position: 'Attacker',
        matchDayTarget: 'Calm & Composed',
        roadblock: 'Pre-Match Nerves',
        trainingFrequency: '5 Days',
        competitiveLevel: 'Club-Travel',
      );
      final schedule = ArchetypeEngine.generateWeeklySchedule(state);

      final activeDays = schedule.days.entries
          .where((e) => e.value.sessionId != null && e.value.sessionId!.isNotEmpty)
          .toList();

      expect(activeDays.length, equals(5));
    });

    test('all days start as not completed', () {
      final state = OnboardingState(
        currentStep: 5,
        position: 'Attacker',
        roadblock: 'Pre-Match Nerves',
        trainingFrequency: '3 Days',
      );
      final schedule = ArchetypeEngine.generateWeeklySchedule(state);

      for (final day in schedule.days.values) {
        expect(day.completed, isFalse);
      }
    });

    test('uses correct archetype sessions for roadblock', () {
      final state = OnboardingState(
        currentStep: 5,
        position: 'Attacker',
        roadblock: 'Pre-Match Nerves', // Calm Operator
        trainingFrequency: '3 Days',
      );
      final schedule = ArchetypeEngine.generateWeeklySchedule(state);

      final activeSessions = schedule.days.entries
          .where((e) => e.value.sessionId != null)
          .map((e) => e.value.sessionId!)
          .toSet();

      expect(activeSessions, contains('session_nerves_equal_performance'));
    });
  });

  group('AppStrings.getArchetypeName', () {
    test('returns correct display names', () {
      expect(AppStrings.getArchetypeName(Archetype.calmOperator),
          equals('The Calm Operator'));
      expect(AppStrings.getArchetypeName(Archetype.resilientBounceback),
          equals('The Resilient Bounceback'));
      expect(AppStrings.getArchetypeName(Archetype.sharpDecisionMaker),
          equals('The Sharp Decision-Maker'));
      expect(AppStrings.getArchetypeName(Archetype.unshakableCompetitor),
          equals('The Unshakable Competitor'));
    });
  });

  group('DayKeys.forToday', () {
    test('returns correct keys for each day', () {
      // Test each day explicitly
      expect(DayKeys.forToday(DateTime(2024, 9, 2)), equals(DayKeys.monday));
      expect(DayKeys.forToday(DateTime(2024, 9, 3)), equals(DayKeys.tuesday));
      expect(DayKeys.forToday(DateTime(2024, 9, 4)), equals(DayKeys.wednesday));
      expect(DayKeys.forToday(DateTime(2024, 9, 5)), equals(DayKeys.thursday));
      expect(DayKeys.forToday(DateTime(2024, 9, 6)), equals(DayKeys.friday));
      expect(DayKeys.forToday(DateTime(2024, 9, 7)), equals(DayKeys.saturday));
      expect(DayKeys.forToday(DateTime(2024, 9, 8)), equals(DayKeys.sunday));
    });
  });

  group('SessionCatalog', () {
    test('returns correct info for known session id', () {
      final info = SessionCatalog.forId('session_nerves_equal_performance');
      expect(info.name, equals('Nerves = Performance'));
      expect(info.targetDurationSeconds, equals(300));
    });

    test('returns default info for unknown session id', () {
      final info = SessionCatalog.forId('unknown_session');
      expect(info.name, equals('Training Session'));
      expect(info.targetDurationSeconds, equals(300));
    });
  });
}
