/// ============================================================================
/// FILE: lib/features/stopwatch/views/stopwatch_view.dart
/// FUNGSI: Tampilan Halaman Stopwatch (Tab 2 Bottom Navbar).
/// MANAJEMEN HANDLES: Tab 2 (Stopwatch Application Feature)
/// LOKASI LOGIC: Tempat penulisan Timer Stopwatch (Start, Pause, Reset, Lap Time),
///               serta render tampilan digital timer.
/// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  State<StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView> {
  // Gunakan kelas Stopwatch bawaan sistem agar terhindar dari time drift
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  
  final List<int> _laps = [];

  @override
  void dispose() {
    // Mematikan timer untuk mencegah memory leak
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startTimer() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      // Update UI setiap 30ms (sekitar 33 fps) agar milidetik terlihat mulus tapi CPU tidak nge-lag
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _pauseTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      setState(() {});
    }
  }

  void _resetTimer() {
    _stopwatch.reset();
    _stopwatch.stop();
    _timer?.cancel();
    _laps.clear();
    setState(() {});
  }

  void _addLap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _stopwatch.elapsedMilliseconds);
      });
    }
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr.$hundredsStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning = _stopwatch.isRunning;
    final hasStarted = _stopwatch.elapsedMilliseconds > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
      ),
      body: Column(
        children: [
          // Area Display Timer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatTime(_stopwatch.elapsedMilliseconds),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier', // Monospace font untuk kestabilan angka
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'HH:MM:SS.MS',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Area Tombol Kontrol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Tombol Reset/Lap
              FloatingActionButton.extended(
                heroTag: 'btn_reset_lap',
                onPressed: (isRunning) 
                    ? _addLap 
                    : (hasStarted ? _resetTimer : null),
                backgroundColor: isRunning 
                    ? theme.colorScheme.secondary 
                    : (hasStarted ? theme.colorScheme.error : theme.colorScheme.surfaceVariant),
                foregroundColor: isRunning 
                    ? theme.colorScheme.onSecondary 
                    : (hasStarted ? theme.colorScheme.onError : theme.colorScheme.onSurfaceVariant),
                icon: Icon(isRunning ? Icons.flag : Icons.refresh),
                label: Text(isRunning ? 'Lap' : 'Reset'),
              ),
              
              // Tombol Start/Pause
              FloatingActionButton.extended(
                heroTag: 'btn_start_pause',
                onPressed: isRunning ? _pauseTimer : _startTimer,
                backgroundColor: isRunning ? theme.colorScheme.tertiary : theme.colorScheme.primary,
                foregroundColor: isRunning ? theme.colorScheme.onTertiary : theme.colorScheme.onPrimary,
                icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(isRunning ? 'Pause' : 'Start'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          
          // Area Daftar Lap Time (Mencegah Overflow dengan Expanded + ListView)
          Expanded(
            child: _laps.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada putaran (lap).',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _laps.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      // Karena list diisi dengan insert(0), index 0 adalah lap terbaru
                      final reversedIndex = _laps.length - index;
                      final currentLapTime = _laps[index];
                      final previousLapTime = (index < _laps.length - 1) ? _laps[index + 1] : 0;
                      final lapDuration = currentLapTime - previousLapTime;

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            child: Text(
                              '$reversedIndex',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer
                              ),
                            ),
                          ),
                          title: Text(
                            '+ ${_formatTime(lapDuration)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Courier'),
                          ),
                          trailing: Text(
                            _formatTime(currentLapTime),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontFamily: 'Courier'
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
