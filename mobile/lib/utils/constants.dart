/// Shared constants used across the Flutter mobile app.

/// Onboarding survey questions and options (ordered as per FMG.md)
enum OnboardingQuestion {
  position('Q1: On-Pitch Position'),
  matchDayTarget('Q2: Match-Day Target'),
  roadblock('Q3: Mental Block / Roadblock'),
  trainingFrequency('Q4: Training Frequency'),
  competitiveLevel('Q5: Competitive Level');

  final String label;
  const OnboardingQuestion(this.label);
}

/// Position options for Q1
enum Position { attacker, midfielder, defender, goalkeeper }

/// Match-Day Target options for Q2
enum MatchDayTarget { calmComposed, sharpDecisions, fearlessPlay, unstoppableFocus }

/// Roadblock / Mental Block options for Q3
enum Roadblock { preMatchNerves, errorSpiral, formSlump, sidelineDistractions }

/// Training Frequency options for Q4
enum TrainingFrequency { days2, days3, days5 }

/// Competitive Level options for Q5
enum CompetitiveLevel { grassroots, clubTravel, professionalAcademy }

/// Archetype assignment based on roadblock (Q3) per FMG.md spec
enum Archetype { calmOperator, resilientBounceback, sharpDecisionMaker, unshakableCompetitor }

/// UI strings and labels
class AppStrings {
  static const appName = 'Football Mind Gym';
  static const onboardingTitle = 'Tell us about yourself';
  static const onboardingSubtitle = 'Help us personalize your training journey';
  static const completeButton = 'Generate My Routine';
  static const continueButton = 'Continue';

  /// Archetype display names
  static String getArchetypeName(Archetype a) {
    switch (a) {
      case Archetype.calmOperator: return 'The Calm Operator';
      case Archetype.resilientBounceback: return 'The Resilient Bounceback';
      case Archetype.sharpDecisionMaker: return 'The Sharp Decision-Maker';
      case Archetype.unshakableCompetitor: return 'The Unshakable Competitor';
    }
  }

  /// Streak-related strings
  static String getStreakStatus(int streak) {
    if (streak >= 30) return '30+ day streak - Shirt eligible!';
    return '$streak day streak';
  }
}

/// Firestore collection paths
class FirestorePaths {
  static const parent = 'users'; // Parent docs use email as ID
  static const athlete = 'users'; // Athlete docs use auth UID as ID
  static const telemetry = 'telemetry';
  static const schedules = 'schedules';
}

/// Stripe metadata keys (for reference / matching backend)
class StripeMetadataKeys {
  static const parentEmail = 'parent_email';
  static const childName = 'child_name';
  static const planTier = 'plan_tier';
}

/// Encharge template IDs (for reference)
class EnchargeTemplateIds {
  static const welcomeEmail = 'welcome_invite';
  static const shirtNotification = 'shirt_eligibility';
}