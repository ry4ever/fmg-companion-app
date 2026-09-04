/// Telemetry session document matching Firestore schema:
/// /users/{athleteAuthUid}/telemetry/{sessionId}
class TelemetrySession {
  final String sessionId;
  final String startedAt; // ISO 8601
  final String completedAt; // ISO 8601
  final int targetDurationSeconds;
  final int foregroundPlaytimeSeconds;
  final bool completedFully;

  TelemetrySession({
    required this.sessionId,
    required this.startedAt,
    required this.completedAt,
    required this.targetDurationSeconds,
    required this.foregroundPlaytimeSeconds,
    required this.completedFully,
  });

  factory TelemetrySession.fromMap(Map<String, dynamic> map) {
    return TelemetrySession(
      sessionId: map['session_id'] as String,
      startedAt: map['started_at'] as String,
      completedAt: map['completed_at'] as String,
      targetDurationSeconds: map['target_duration_seconds'] as int,
      foregroundPlaytimeSeconds: map['foreground_playtime_seconds'] as int,
      completedFully: map['completed_fully'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'started_at': startedAt,
      'completed_at': completedAt,
      'target_duration_seconds': targetDurationSeconds,
      'foreground_playtime_seconds': foregroundPlaytimeSeconds,
      'completed_fully': completedFully,
    };
  }
}