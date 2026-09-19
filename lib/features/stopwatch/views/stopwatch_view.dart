/// ============================================================================
/// FILE: lib/features/stopwatch/views/stopwatch_view.dart
/// FUNGSI: Tampilan Halaman Stopwatch (Tab 2 Bottom Navbar).
/// MANAJEMEN HANDLES: Tab 2 (Stopwatch Application Feature)
/// LOKASI LOGIC: Tempat penulisan Timer Stopwatch (Start, Pause, Reset, Lap Time),
///               serta render tampilan digital timer.
/// ============================================================================

import 'package:flutter/material.dart';

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  State<StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView> {
  // TODO: Implementasi Stopwatch timer state & logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
      ),
      body: const Center(
        child: Text(
          '00:00:00',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
