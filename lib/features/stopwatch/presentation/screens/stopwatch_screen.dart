// lib/features/stopwatch/presentation/screens/stopwatch_screen.dart
import 'package:flutter/material.dart';

/// Screen Fitur Stopwatch (FR-T2-09 Tab 2 pada Bottom Navigation)
class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, size: 64, color: Color(0xFF6C5CE7)),
              SizedBox(height: 16),
              Text(
                '00 : 00 : 00 . 00',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Fitur Stopwatch (FR-T2-09 Tab 2)\n'
                '// TODO: Kontrol Start, Pause, Reset, dan Catatan Lap.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
