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

/// Session metadata: id -> human-readable name and target duration in seconds.
class SessionCatalog {
  static const Map<String, SessionInfo> all = {
    'session_nerves_equal_performance': SessionInfo(
      name: 'Nerves = Performance',
      targetDurationSeconds: 300,
    ),
    'session_flow_trigger': SessionInfo(
      name: 'Flow Trigger',
      targetDurationSeconds: 300,
    ),
    'session_play_your_next_game': SessionInfo(
      name: 'Play Your Next Game',
      targetDurationSeconds: 300,
    ),
    'session_back_to_your_best': SessionInfo(
      name: 'Back To Your Best',
      targetDurationSeconds: 300,
    ),
    'session_empowered_thinking': SessionInfo(
      name: 'Empowered Thinking',
      targetDurationSeconds: 300,
    ),
    'session_enjoyment': SessionInfo(
      name: 'Enjoyment',
      targetDurationSeconds: 300,
    ),
    'session_ice_cold_finisher': SessionInfo(
      name: 'Ice Cold Finisher',
      targetDurationSeconds: 300,
    ),
    'session_better_final_ball': SessionInfo(
      name: 'Better Final Ball',
      targetDurationSeconds: 300,
    ),
    'session_team_mate_6th_sense': SessionInfo(
      name: 'Team Mate 6th Sense',
      targetDurationSeconds: 300,
    ),
    'session_defending_with_positive_aggression': SessionInfo(
      name: 'Defending With Positive Aggression',
      targetDurationSeconds: 300,
    ),
    'session_sharpen_your_game': SessionInfo(
      name: 'Sharpen Your Game',
      targetDurationSeconds: 300,
    ),
    'session_unshakable': SessionInfo(
      name: 'UNSHAKABLE',
      targetDurationSeconds: 300,
    ),
  };

  static SessionInfo forId(String sessionId) {
    return all[sessionId] ??
        const SessionInfo(name: 'Training Session', targetDurationSeconds: 300);
  }
}

class SessionInfo {
  final String name;
  final int targetDurationSeconds;
  const SessionInfo({required this.name, required this.targetDurationSeconds});
}

/// Day-of-week key strings (lowercase) used in WeeklySchedule.days.
class DayKeys {
  static const monday = 'monday';
  static const tuesday = 'tuesday';
  static const wednesday = 'wednesday';
  static const thursday = 'thursday';
  static const friday = 'friday';
  static const saturday = 'saturday';
  static const sunday = 'sunday';

  static String forToday([DateTime? now]) {
    final date = now ?? DateTime.now();
    switch (date.weekday) {
      case DateTime.monday: return monday;
      case DateTime.tuesday: return tuesday;
      case DateTime.wednesday: return wednesday;
      case DateTime.thursday: return thursday;
      case DateTime.friday: return friday;
      case DateTime.saturday: return saturday;
      case DateTime.sunday: return sunday;
      default: return monday;
    }
  }
}