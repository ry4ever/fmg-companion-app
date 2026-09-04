import 'package:flutter/material.dart';

class TelemetryObserver extends StatefulWidget {
  final Widget child;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const TelemetryObserver({
    super.key,
    required this.child,
    required this.onPause,
    required this.onResume,
  });

  @override
  State<TelemetryObserver> createState() => _TelemetryObserverState();
}

class _TelemetryObserverState extends State<TelemetryObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      widget.onPause(); // Pause AV playback and telemetry timer
    } else if (state == AppLifecycleState.resumed) {
      widget.onResume(); // Resume state
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}