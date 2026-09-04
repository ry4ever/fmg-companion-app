import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/telemetry_session.dart';
import '../models/weekly_schedule.dart';

/// Foreground telemetry tracker implementing Module 4 (Anti-Cheat Guard).
///
/// Tracks foreground-only playtime via a Stopwatch and uses
/// WidgetsBindingObserver to pause/resume on lifecycle transitions.
///
/// On media completion, validates that foreground playtime >= 95% of
/// target duration before writing completed_fully: true to Firestore.
class TelemetryScheduler extends WidgetsBindingObserver {
  final String athleteUid;
  final String sessionId;
  final int targetDurationSeconds;
  final DateTime startedAt;

  final Stopwatch _stopwatch = Stopwatch();
  final DateTime _completionTime;
  final bool _completedFully;

  bool _isRunning = false;
  bool _hasCompleted = false;
  bool _hasWritten = false;

  /// Total foreground playtime accumulated before this session
  int _accumulatedForegroundSeconds = 0;

  TelemetryScheduler({
    required this.athleteUid,
    required this.sessionId,
    required this.targetDurationSeconds,
    required this.startedAt,
    required DateTime completionTime,
    required bool completedFully,
  }) : _completionTime = completionTime,
       _completedFully = completedFully;

  /// Start tracking. Call when media playback begins.
  void start() {
    if (_isRunning) return;
    _stopwatch.start();
    _isRunning = true;
    _hasCompleted = false;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Pause the tracker (e.g., backgrounding, opening social media, phone call).
  void pause() {
    if (!_isRunning) return;
    _stopwatch.stop();
    _accumulatedForegroundSeconds += _stopwatch.elapsedMilliseconds ~/ 1000;
    _stopwatch.reset();
    _isRunning = false;
  }

  /// Resume the tracker when returning to foreground.
  void resume() {
    if (_isRunning) return;
    _stopwatch.start();
    _isRunning = true;
  }

  /// Stop tracking and write telemetry + schedule update to Firestore.
  Future<void> stop() async {
    if (_hasWritten) return;
    if (_isRunning) {
      _stopwatch.stop();
      _accumulatedForegroundSeconds += _stopwatch.elapsedMilliseconds ~/ 1000;
      _stopwatch.reset();
      _isRunning = false;
    }

    _hasWritten = true;
    WidgetsBinding.instance.removeObserver(this);

    // Validate completion: foreground playtime must be >= 95% of target duration
    final isValid = _accumulatedForegroundSeconds >= (targetDurationSeconds * 0.95).ceil();
    final completedFully = _completedFully && isValid;

    final session = TelemetrySession(
      sessionId: sessionId,
      startedAt: startedAt.toIso8601String(),
      completedAt: _completionTime.toIso8601String(),
      targetDurationSeconds: targetDurationSeconds,
      foregroundPlaytimeSeconds: _accumulatedForegroundSeconds,
      completedFully: completedFully,
    );

    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // Write telemetry
    final telemetryRef = db
        .collection('users')
        .doc(athleteUid)
        .collection('telemetry')
        .doc(sessionId);
    batch.set(telemetryRef, session.toMap());

    // Update weekly schedule: mark the day as completed
    if (completedFully) {
      final todayKey = _dayKey(_completionTime);
      final scheduleRef = db
          .collection('users')
          .doc(athleteUid)
          .collection('schedules')
          .doc('weekly');
      batch.update(scheduleRef, {
        'days.$todayKey.completed': true,
      });
    }

    await batch.commit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        resume();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        pause();
        break;
      case AppLifecycleState.hidden:
        pause();
        break;
    }
  }

  /// Map a date to the lowercase day key used in the weekly schedule.
  String _dayKey(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'monday';
    }
  }
}