import 'package:flutter_test/flutter_test.dart';
import 'package:fmg_companion/models/weekly_schedule.dart';

void main() {
  group('DailySchedule', () {
    test('fromMap parses session id and completed flag', () {
      final map = {
        'session_id': 'session_test',
        'completed': true,
      };
      final day = DailySchedule.fromMap(map);

      expect(day.sessionId, equals('session_test'));
      expect(day.completed, isTrue);
    });

    test('fromMap handles null session id', () {
      final map = {
        'session_id': null,
        'completed': false,
      };
      final day = DailySchedule.fromMap(map);

      expect(day.sessionId, isNull);
      expect(day.completed, isFalse);
    });

    test('toMap produces correct output', () {
      final day = DailySchedule(
        sessionId: 'session_nerves',
        completed: true,
      );
      final map = day.toMap();

      expect(map['session_id'], equals('session_nerves'));
      expect(map['completed'], isTrue);
    });
  });

  group('WeeklySchedule', () {
    test('fromMap parses all 7 days', () {
      final map = {
        'active_week_start': '2024-09-02T00:00:00Z',
        'is_custom_mode': true,
        'days': {
          'monday': {'session_id': 'session_1', 'completed': false},
          'tuesday': {'session_id': 'session_2', 'completed': true},
          'wednesday': {'session_id': null, 'completed': false},
          'thursday': {'session_id': 'session_3', 'completed': false},
          'friday': {'session_id': null, 'completed': false},
          'saturday': {'session_id': 'session_1', 'completed': false},
          'sunday': {'session_id': null, 'completed': false},
        },
      };
      final schedule = WeeklySchedule.fromMap(map);

      expect(schedule.activeWeekStart, equals('2024-09-02T00:00:00Z'));
      expect(schedule.isCustomMode, isTrue);
      expect(schedule.days.length, equals(7));

      expect(schedule.days['monday']!.sessionId, equals('session_1'));
      expect(schedule.days['monday']!.completed, isFalse);
      expect(schedule.days['tuesday']!.sessionId, equals('session_2'));
      expect(schedule.days['tuesday']!.completed, isTrue);
      expect(schedule.days['wednesday']!.sessionId, isNull);
    });

    test('fromMap handles missing days gracefully', () {
      final map = {
        'active_week_start': '2024-09-02T00:00:00Z',
        'is_custom_mode': false,
        'days': <String, dynamic>{},
      };
      final schedule = WeeklySchedule.fromMap(map);

      // Missing days get a default rest-day value
      expect(schedule.days['monday']!.sessionId, isNull);
      expect(schedule.days['monday']!.completed, isFalse);
      expect(schedule.days['tuesday']!.sessionId, isNull);
      expect(schedule.days['sunday']!.sessionId, isNull);
    });

    test('toMap produces correct output', () {
      final schedule = WeeklySchedule(
        activeWeekStart: '2024-09-02T00:00:00Z',
        isCustomMode: true,
        days: {
          'monday': DailySchedule(sessionId: 'session_1', completed: true),
          'tuesday': DailySchedule(sessionId: null, completed: false),
          'wednesday': DailySchedule(sessionId: 'session_2', completed: false),
          'thursday': DailySchedule(sessionId: null, completed: false),
          'friday': DailySchedule(sessionId: null, completed: false),
          'saturday': DailySchedule(sessionId: null, completed: false),
          'sunday': DailySchedule(sessionId: null, completed: false),
        },
      );
      final map = schedule.toMap();

      expect(map['active_week_start'], equals('2024-09-02T00:00:00Z'));
      expect(map['is_custom_mode'], isTrue);
      expect((map['days'] as Map)['monday']['session_id'], equals('session_1'));
      expect((map['days'] as Map)['monday']['completed'], isTrue);
      expect((map['days'] as Map)['tuesday']['session_id'], isNull);
    });

    test('round-trip: toMap -> fromMap preserves data', () {
      final original = WeeklySchedule(
        activeWeekStart: '2024-09-02T00:00:00Z',
        isCustomMode: true,
        days: {
          'monday': DailySchedule(sessionId: 'session_nerves', completed: true),
          'tuesday': DailySchedule(sessionId: 'session_flow', completed: false),
          'wednesday': DailySchedule(sessionId: null, completed: false),
          'thursday': DailySchedule(sessionId: 'session_unshakable', completed: false),
          'friday': DailySchedule(sessionId: null, completed: false),
          'saturday': DailySchedule(sessionId: 'session_nerves', completed: false),
          'sunday': DailySchedule(sessionId: null, completed: false),
        },
      );
      final restored = WeeklySchedule.fromMap(original.toMap());

      expect(restored.activeWeekStart, equals(original.activeWeekStart));
      expect(restored.isCustomMode, equals(original.isCustomMode));
      expect(restored.days.length, equals(original.days.length));
      expect(restored.days['monday']!.sessionId,
          equals(original.days['monday']!.sessionId));
      expect(restored.days['monday']!.completed,
          equals(original.days['monday']!.completed));
    });
  });
}
