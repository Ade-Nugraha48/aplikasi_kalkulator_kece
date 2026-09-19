/// ============================================================================
/// FILE: lib/features/weton_calendar/views/weton_calendar_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Kalender Weton Jawa.
/// MANAJEMEN HANDLES: FR-T2-07 (Konversi Kalender Weton, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan algoritma pencarian pasaran Jawa (Legi, Pahing,
///               Pon, Wage, Kliwon) & perhitungan Neptu.
/// ============================================================================

import 'package:flutter/material.dart';

class WetonCalendarView extends StatefulWidget {
  const WetonCalendarView({super.key});

  @override
  State<WetonCalendarView> createState() => _WetonCalendarViewState();
}

class _WetonCalendarViewState extends State<WetonCalendarView> {
  // Handles FR-T2-07: Default input = hari ini
  DateTime _selectedDate = DateTime.now();
  String _wetonResult = '';

  void _hitungWeton() {
    // TODO: Implementasi logika konversi hari masehi + pasaran Jawa (Legi/Pahing/Pon/Wage/Kliwon)
    setState(() {
      _wetonResult = 'Sabtu Pahing (Neptu: 18)';
    });
  }

  @override
  void initState() {
    super.initState();
    _hitungWeton();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Weton Jawa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Tanggal Input:'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.event_repeat),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _hitungWeton();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Weton & Pasaran Jawa:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      _wetonResult,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
