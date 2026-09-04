import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/telemetry_session.dart';

/// Telemetry service for session tracking and anti-cheat validation.
///
/// Implements Module 4 (Foreground Telemetry & Anti-Cheat Guard):
/// - Track foreground-only playtime via Stopwatch
/// - Validate completion only if foreground time >= 95% of target duration
/// - Write telemetry to /users/{athleteUid}/telemetry/{sessionId}
class TelemetryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> writeTelemetry(
    String athleteUid,
    String sessionId,
    TelemetrySession data,
  ) async {
    await _db
        .collection('users')
        .doc(athleteUid)
        .collection('telemetry')
        .doc(sessionId)
        .set(data.toMap());
  }

  /// Validate that the session meets the 95% foreground threshold.
  ///
  /// Returns true only if foreground_playtime_seconds >= 95% of target_duration_seconds.
  bool isValidCompletion(int foregroundPlaytimeSeconds, int targetDurationSeconds) {
    if (targetDurationSeconds <= 0) return false;
    final threshold = (targetDurationSeconds * 0.95).ceil();
    return foregroundPlaytimeSeconds >= threshold;
  }

  TelemetrySession createSession({
    required String sessionId,
    required String startedAt,
    required String completedAt,
    required int targetDurationSeconds,
    required int foregroundPlaytimeSeconds,
    required bool completedFully,
  }) {
    return TelemetrySession(
      sessionId: sessionId,
      startedAt: startedAt,
      completedAt: completedAt,
      targetDurationSeconds: targetDurationSeconds,
      foregroundPlaytimeSeconds: foregroundPlaytimeSeconds,
      completedFully: completedFully,
    );
  }
}
