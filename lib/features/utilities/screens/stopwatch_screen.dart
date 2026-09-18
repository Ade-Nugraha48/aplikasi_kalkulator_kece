// lib/features/utilities/screens/stopwatch_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

// TODO: Implementasi Fitur Stopwatch untuk Bottom Navbar (FR-T2-09)
class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  void _pauseStopwatch() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime() {
    final milliseconds = _stopwatch.elapsedMilliseconds;
    final hundreds = (milliseconds ~/ 10) % 100;
    final seconds = (milliseconds ~/ 1000) % 60;
    final minutes = (milliseconds ~/ (1000 * 60)) % 60;
    final hours = (milliseconds ~/ (1000 * 60 * 60));

    String hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    return '$hoursStr${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning = _stopwatch.isRunning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch Presisi'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  border: Border.all(color: theme.colorScheme.primary, width: 4),
                ),
                child: Center(
                  child: Text(
                    _formatTime(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isRunning ? _pauseStopwatch : _startStopwatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? Colors.orange : Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(isRunning ? 'PAUSE' : 'MULAI'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: _resetStopwatch,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('RESET'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
