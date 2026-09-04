/// Weekly schedule document matching Firestore schema:
/// /users/{athleteAuthUid}/schedules/weekly
class WeeklySchedule {
  final String activeWeekStart; // ISO 8601
  final bool isCustomMode;
  final Map<String, DailySchedule> days; // monday through sunday

  WeeklySchedule({
    required this.activeWeekStart,
    required this.isCustomMode,
    required this.days,
  });

  factory WeeklySchedule.fromMap(Map<String, dynamic> map) {
    final daysMap = <String, DailySchedule>{};
    final daysData = map['days'] as Map<dynamic, dynamic>?;
    if (daysData != null) {
      daysMap['monday'] = daysData['monday'] != null
          ? DailySchedule.fromMap(daysData['monday'] as Map<String, dynamic>)
          : DailySchedule(sessionId: null, completed: false);
      daysMap['tuesday'] = daysData['tuesday'] != null
          ? DailySchedule.fromMap(daysData['tuesday'] as Map<String, dynamic>)
          : DailySchedule(sessionId: null, completed: false);
      daysMap['wednesday'] = daysData['wednesday'] != null
          ? DailySchedule.fromMap(daysData['wednesday'] as Map<String, dynamic>)
          : DailySchedule(sessionId: null, completed: false);
      daysMap['thursday'] = daysData['thursday'] != null
          ? DailySchedule.fromMap(daysData['thursday'] as Map<String, dynamic>)
          : DailySchedule(sessionId: null, completed: false);
      daysMap['friday'] = daysData['friday'] != null
          ? DailySchedule.fromMap(daysData['friday'] as Map<String, dynamic>)
          : DailySchedule(sessionId: null, completed: false);
      daysMap['saturday'] = daysData['saturday'] != null
          ? DailySchedule.fromMap(daysData['saturday'] as Map<String, dynamic>)
          : DailySchedule(sessionId: null, completed: false);
      daysMap['sunday'] = daysData['sunday'] != null
          ? DailySchedule.fromMap(daysData['sunday'] as Map<String, dynamic>)
          : DailySchedule(sessionId: null, completed: false);
    }

    return WeeklySchedule(
      activeWeekStart: map['active_week_start'] as String,
      isCustomMode: map['is_custom_mode'] as bool,
      days: daysMap,
    );
  }

  Map<String, dynamic> toMap() {
    final daysData = <String, dynamic>{};
    daysData['monday'] = days['monday'].toMap();
    daysData['tuesday'] = days['tuesday'].toMap();
    daysData['wednesday'] = days['wednesday'].toMap();
    daysData['thursday'] = days['thursday'].toMap();
    daysData['friday'] = days['friday'].toMap();
    daysData['saturday'] = days['saturday'].toMap();
    daysData['sunday'] = days['sunday'].toMap();

    return {
      'active_week_start': activeWeekStart,
      'is_custom_mode': isCustomMode,
      'days': daysData,
    };
  }
}

/// Daily schedule item nested inside WeeklySchedule.days
class DailySchedule {
  final String? sessionId;
  final bool completed;

  DailySchedule({this.sessionId, required this.completed});

  factory DailySchedule.fromMap(Map<String, dynamic> map) {
    return DailySchedule(
      sessionId: map['session_id'] as String?,
      completed: map['completed'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'completed': completed,
    };
  }
}