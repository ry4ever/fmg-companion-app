import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/athlete_user.dart';
import '../models/weekly_schedule.dart';

/// Local storage for demo mode.
///
/// Persists athlete user + weekly schedule to SharedPreferences when
/// Firebase is unavailable, so the onboarding → My Gym flow works offline.
class DemoStore {
  static const String _athleteKey = 'fmg_demo_athlete';
  static const String _scheduleKey = 'fmg_demo_schedule';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  /// Save athlete user + weekly schedule locally.
  Future<void> save({
    required AthleteUser athlete,
    required WeeklySchedule schedule,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_athleteKey, jsonEncode(athlete.toMap()));
    await prefs.setString(_scheduleKey, jsonEncode(schedule.toMap()));
  }

  /// Load athlete user, or null if not cached.
  Future<AthleteUser?> loadAthlete() async {
    final prefs = await _prefs;
    final json = prefs.getString(_athleteKey);
    if (json == null) return null;
    return AthleteUser.fromMap(Map<String, dynamic>.from(jsonDecode(json)));
  }

  /// Load weekly schedule, or null if not cached.
  Future<WeeklySchedule?> loadSchedule() async {
    final prefs = await _prefs;
    final json = prefs.getString(_scheduleKey);
    if (json == null) return null;
    return WeeklySchedule.fromMap(Map<String, dynamic>.from(jsonDecode(json)));
  }

  /// Clear cached demo data.
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_athleteKey);
    await prefs.remove(_scheduleKey);
  }
}