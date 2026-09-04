import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/telemetry_scheduler.dart';
import '../widgets/telemetry_observer.dart';

/// Session playback screen implementing Module 4 (Active Foreground Telemetry).
///
/// Uses TelemetryScheduler to track foreground playtime via lifecycle events.
/// On media completion, validates the 95% threshold and commits to Firestore
/// via a batch operation (telemetry doc + weekly schedule day update).
class SessionPlayerScreen extends StatefulWidget {
  final String athleteUid;
  final String sessionId;
  final String sessionName;
  final int targetDurationSeconds;

  const SessionPlayerScreen({
    super.key,
    required this.athleteUid,
    required this.sessionId,
    required this.sessionName,
    required this.targetDurationSeconds,
  });

  @override
  State<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<SessionPlayerScreen> {
  late TelemetryScheduler _scheduler;
  late Timer _progressTimer;

  // Simulated playback progress (in a real app, this would be driven by video_player)
  int _elapsedSeconds = 0;
  bool _isPlaying = false;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _scheduler = TelemetryScheduler(
      athleteUid: widget.athleteUid,
      sessionId: widget.sessionId,
      targetDurationSeconds: widget.targetDurationSeconds,
      startedAt: DateTime.now(),
      completionTime: DateTime.now(),
      completedFully: true,
    );

    _progressTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (!_isPlaying) return;
    if (_hasCompleted) return;

    setState(() {
      _elapsedSeconds++;
    });

    if (_elapsedSeconds >= widget.targetDurationSeconds) {
      _completeSession();
    }
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _scheduler.start();
    } else {
      _scheduler.pause();
    }
  }

  void _completeSession() async {
    setState(() {
      _isPlaying = false;
      _hasCompleted = true;
    });

    _scheduler.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session complete! Streak updated.')),
    );

    // Return to home after a brief moment
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _progressTimer.cancel();
    _scheduler.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _elapsedSeconds / widget.targetDurationSeconds;
    final displayProgress = (progress.clamp(0.0, 1.0)).toDouble();

    return TelemetryObserver(
      onPause: () {
        // Pause playback + scheduler when app backgrounds
        setState(() {
          _isPlaying = false;
        });
        _scheduler.pause();
      },
      onResume: () {
        // Resume playback + scheduler when app foregrounds
        if (_hasCompleted) return;
        setState(() {
          _isPlaying = true;
        });
        _scheduler.resume();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.sessionName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Simulated video player area
              Container(
                width: double.infinity,
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isPlaying && !_hasCompleted)
                      const Icon(Icons.play_circle_fill, size: 48, color: Colors.white54)
                    else if (_hasCompleted)
                      const Icon(Icons.check_circle, size: 48, color: Colors.green)
                    else
                      const Icon(Icons.pause_circle_fill, size: 48, color: Colors.white54),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: LinearProgressIndicator(
                        value: displayProgress,
                        backgroundColor: Colors.grey[800],
                        color: Colors.purple,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Timer display
              Text(
                '${formatDuration(_elapsedSeconds)} / ${formatDuration(widget.targetDurationSeconds)}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 4),
               Text(
                _hasCompleted
                  ? 'Session Completed!'
                  : _isPlaying
                    ? 'Training in progress...'
                    : 'Paused — switch to another app to keep your streak going',
                style: TextStyle(
                  color: _hasCompleted ? Colors.green : Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_hasCompleted)
                    FloatingActionButton(
                      onPressed: _togglePlay,
                      backgroundColor: _isPlaying ? Colors.orange : Colors.purple,
                      child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                  if (_hasCompleted)
                    const Icon(Icons.check_circle, size: 48, color: Colors.green),
                  const SizedBox(width: 16),
                  if (!_hasCompleted)
                    TextButton.icon(
                      onPressed: _elapsedSeconds > 0 ? _completeSession : null,
                      icon: const Icon(Icons.stop, color: Colors.red),
                      label: const Text('Stop', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}