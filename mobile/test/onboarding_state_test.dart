import 'package:flutter_test/flutter_test.dart';
import 'package:fmg_companion/models/onboarding_state.dart';

void main() {
  group('OnboardingState', () {
    test('defaults to step 0 with all null fields', () {
      final state = OnboardingState();
      expect(state.currentStep, equals(0));
      expect(state.position, isNull);
      expect(state.matchDayTarget, isNull);
      expect(state.roadblock, isNull);
      expect(state.trainingFrequency, isNull);
      expect(state.competitiveLevel, isNull);
    });

    test('isPartial returns true when partially completed', () {
      final state = OnboardingState(currentStep: 3);
      expect(state.isPartial, isTrue);
    });

    test('isPartial returns false when at step 0', () {
      final state = OnboardingState(currentStep: 0);
      expect(state.isPartial, isFalse);
    });

    test('isComplete returns true at step 5', () {
      final state = OnboardingState(currentStep: 5);
      expect(state.isComplete, isTrue);
    });

    test('isComplete returns false before step 5', () {
      final state = OnboardingState(currentStep: 4);
      expect(state.isComplete, isFalse);
    });

    test('toJson serializes all fields', () {
      final state = OnboardingState(
        currentStep: 3,
        position: 'Attacker',
        matchDayTarget: 'Calm & Composed',
        roadblock: 'Pre-Match Nerves',
        trainingFrequency: '3 Days',
        competitiveLevel: 'Club-Travel',
      );
      final json = state.toJson();

      expect(json['currentStep'], equals(3));
      expect(json['position'], equals('Attacker'));
      expect(json['matchDayTarget'], equals('Calm & Composed'));
      expect(json['roadblock'], equals('Pre-Match Nerves'));
      expect(json['trainingFrequency'], equals('3 Days'));
      expect(json['competitiveLevel'], equals('Club-Travel'));
    });

    test('fromJson deserializes all fields', () {
      final json = {
        'currentStep': 4,
        'position': 'Midfielder',
        'matchDayTarget': 'Sharp Decisions',
        'roadblock': 'The Error Spiral',
        'trainingFrequency': '2 Days',
        'competitiveLevel': 'Professional Academy',
      };
      final state = OnboardingState.fromJson(json);

      expect(state.currentStep, equals(4));
      expect(state.position, equals('Midfielder'));
      expect(state.matchDayTarget, equals('Sharp Decisions'));
      expect(state.roadblock, equals('The Error Spiral'));
      expect(state.trainingFrequency, equals('2 Days'));
      expect(state.competitiveLevel, equals('Professional Academy'));
    });

    test('fromJson handles missing fields gracefully', () {
      final json = <String, dynamic>{};
      final state = OnboardingState.fromJson(json);

      expect(state.currentStep, equals(0));
      expect(state.position, isNull);
    });

    test('fromJson handles null values', () {
      final json = {
        'currentStep': null,
        'position': null,
        'roadblock': null,
      };
      final state = OnboardingState.fromJson(json);
      expect(state.currentStep, equals(0));
      expect(state.position, isNull);
    });

    test('copyWith updates specified fields', () {
      final original = OnboardingState(
        currentStep: 1,
        position: 'Attacker',
        roadblock: 'Pre-Match Nerves',
      );
      final updated = original.copyWith(
        currentStep: 2,
        trainingFrequency: '3 Days',
      );

      expect(updated.currentStep, equals(2));
      expect(updated.position, equals('Attacker')); // unchanged
      expect(updated.roadblock, equals('Pre-Match Nerves')); // unchanged
      expect(updated.trainingFrequency, equals('3 Days')); // updated
    });

    test('round-trip: toJson -> fromJson preserves data', () {
      final original = OnboardingState(
        currentStep: 4,
        position: 'Defender',
        matchDayTarget: 'Fearless Play',
        roadblock: 'The Form Slump',
        trainingFrequency: '5 Days',
        competitiveLevel: 'Grassroots',
      );
      final restored = OnboardingState.fromJson(original.toJson());

      expect(restored.currentStep, equals(original.currentStep));
      expect(restored.position, equals(original.position));
      expect(restored.matchDayTarget, equals(original.matchDayTarget));
      expect(restored.roadblock, equals(original.roadblock));
      expect(restored.trainingFrequency, equals(original.trainingFrequency));
      expect(restored.competitiveLevel, equals(original.competitiveLevel));
    });
  });
}
