/// Onboarding state model for the 5-question survey.
///
/// Maps to the FMG Blueprint wireframe spec:
/// 1. On-Pitch Position (Attacker / Midfielder / Defender / Goalkeeper)
/// 2. Match-Day Target (Calm & Composed / Sharp Decisions / Fearless Play / Unstoppable Focus)
/// 3. Mental Block / Roadblock (Pre-Match Nerves / The Error Spiral / The Form Slump / Sideline/Crowd Distractions)
/// 4. Training Frequency (2 Days / 3 Days / 5 Days/Week)
/// 5. Competitive Level (Grassroots / Club-Travel / Professional Academy)
class OnboardingState {
  final int currentStep; // 0 to 4
  final String? position;       // Q1
  final String? matchDayTarget; // Q2
  final String? roadblock;      // Q3
  final String? trainingFrequency; // Q4
  final String? competitiveLevel; // Q5

  OnboardingState({
    this.currentStep = 0,
    this.position,
    this.matchDayTarget,
    this.roadblock,
    this.trainingFrequency,
    this.competitiveLevel,
  });

  /// Check if the state is partially completed (user exited mid-survey)
  bool get isPartial => currentStep > 0 && currentStep < 5;

  /// Check if the survey is fully completed
  bool get isComplete => currentStep == 5;

  /// Convert to JSON for local persistence (shared_preferences / Hive)
  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'position': position,
      'matchDayTarget': matchDayTarget,
      'roadblock': roadblock,
      'trainingFrequency': trainingFrequency,
      'competitiveLevel': competitiveLevel,
    };
  }

  /// Create from JSON
  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      currentStep: json['currentStep'] as int? ?? 0,
      position: json['position'] as String?,
      matchDayTarget: json['matchDayTarget'] as String?,
      roadblock: json['roadblock'] as String?,
      trainingFrequency: json['trainingFrequency'] as String?,
      competitiveLevel: json['competitiveLevel'] as String?,
    );
  }

  /// Create a copy with updated fields
  OnboardingState copyWith({
    int? currentStep,
    String? position,
    String? matchDayTarget,
    String? roadblock,
    String? trainingFrequency,
    String? competitiveLevel,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      position: position ?? this.position,
      matchDayTarget: matchDayTarget ?? this.matchDayTarget,
      roadblock: roadblock ?? this.roadblock,
      trainingFrequency: trainingFrequency ?? this.trainingFrequency,
      competitiveLevel: competitiveLevel ?? this.competitiveLevel,
    );
  }
}