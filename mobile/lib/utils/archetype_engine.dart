import '../models/onboarding_state.dart';
import '../utils/constants.dart';

/// Archetype assignment engine.
///
/// Maps the 5-question onboarding survey inputs to:
/// - Core archetype (from roadblock Q3)
/// - Secondary sessions (from position Q1 for Tactical Errors)
/// - Active session IDs for calendar generation
/// - UI/theme customization (from match-day target Q2 + competitive level Q5)
class ArchetypeEngine {
  /// Assign core archetype based on roadblock (Q3)
  static Archetype assignArchetype(String roadblock) {
    switch (roadblock) {
      case 'Pre-Match Nerves':
        return Archetype.calmOperator;
      case 'The Error Spiral':
      case 'The Form Slump':
        return Archetype.resilientBounceback;
      case 'Tactical Errors':
        return Archetype.sharpDecisionMaker;
      case 'Sideline/Crowd Distractions':
      case 'Sideline Distractions':
        return Archetype.unshakableCompetitor;
      default:
        return Archetype.resilientBounceback;
    }
  }

  /// Get active session IDs for a given archetype.
  ///
  /// Returns [coreSessionId, secondarySessionId1, secondarySessionId2]
  static List<String> getActiveSessions(Archetype archetype, String position) {
    switch (archetype) {
      case Archetype.calmOperator:
        return ['session_nerves_equal_performance', 'session_flow_trigger', 'session_play_your_next_game'];
      case Archetype.resilientBounceback:
        return ['session_back_to_your_best', 'session_empowered_thinking', 'session_enjoyment'];
      case Archetype.sharpDecisionMaker:
        // Position-based secondary archetypes
        switch (position) {
          case 'Attacker':
            return ['session_ice_cold_finisher', 'session_better_final_ball', 'session_team_mate_6th_sense'];
          case 'Midfielder':
            return ['session_better_final_ball', 'session_team_mate_6th_sense', 'session_sharpen_your_game'];
          case 'Defender':
            return ['session_defending_with_positive_aggression', 'session_sharpen_your_game', 'session_team_mate_6th_sense'];
          default:
            return ['session_better_final_ball', 'session_team_mate_6th_sense', 'session_sharpen_your_game'];
        }
      case Archetype.unshakableCompetitor:
        return ['session_unshakable', 'session_team_mate_6th_sense', 'session_play_your_next_game'];
    }
  }

  /// Generate weekly schedule based on onboarding inputs.
  ///
  /// Training frequency (Q4) determines the active-to-rest day ratio:
  /// - 2 Days: 2 active + 5 rest
  /// - 3 Days: 3 active + 4 rest
  /// - 5 Days: 5 active + 2 rest
  static WeeklySchedule generateWeeklySchedule(OnboardingState state) {
    final activeSessions = getActiveSessions(
      assignArchetype(state.roadblock ?? ''),
      state.position ?? '',
    );

    // Determine number of active days based on training frequency
    int activeDayCount;
    switch (state.trainingFrequency) {
      case '2 Days':
        activeDayCount = 2;
        break;
      case '3 Days':
        activeDayCount = 3;
        break;
      case '5 Days':
        activeDayCount = 5;
        break;
      default:
        activeDayCount = 3;
    }

    final now = DateTime.now().toIso8601String();
    final weekStart = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).toIso8601String();

    final days = <String, DailySchedule>{
      'monday': DailySchedule(sessionId: activeSessions[0], completed: false),
      'tuesday': DailySchedule(sessionId: activeSessions[1], completed: false),
      'wednesday': DailySchedule(sessionId: activeSessions[2], completed: false),
      'thursday': DailySchedule(sessionId: activeSessions[0], completed: false),
      'friday': DailySchedule(sessionId: activeSessions[1], completed: false),
      'saturday': DailySchedule(sessionId: activeSessions[2], completed: false),
      'sunday': DailySchedule(sessionId: null, completed: false),
    };

    // Apply rest-day injection based on training frequency
    if (activeDayCount == 2) {
      days['tuesday'] = DailySchedule(sessionId: null, completed: false);
      days['thursday'] = DailySchedule(sessionId: null, completed: false);
      days['friday'] = DailySchedule(sessionId: null, completed: false);
      days['saturday'] = DailySchedule(sessionId: null, completed: false);
      days['sunday'] = DailySchedule(sessionId: null, completed: false);
    } else if (activeDayCount == 3) {
      days['thursday'] = DailySchedule(sessionId: null, completed: false);
      days['friday'] = DailySchedule(sessionId: null, completed: false);
      days['saturday'] = DailySchedule(sessionId: null, completed: false);
      days['sunday'] = DailySchedule(sessionId: null, completed: false);
    } else if (activeDayCount == 5) {
      days['saturday'] = DailySchedule(sessionId: null, completed: false);
      days['sunday'] = DailySchedule(sessionId: null, completed: false);
    }

    return WeeklySchedule(
      activeWeekStart: weekStart,
      isCustomMode: true,
      days: days,
    );
  }

  /// Get the core session ID for a given archetype (for display in UI)
  static String getCoreSessionId(Archetype archetype) {
    switch (archetype) {
      case Archetype.calmOperator:
        return 'session_nerves_equal_performance';
      case Archetype.resilientBounceback:
        return 'session_back_to_your_best';
      case Archetype.sharpDecisionMaker:
        return 'session_better_final_ball';
      case Archetype.unshakableCompetitor:
        return 'session_unshakable';
    }
  }
}