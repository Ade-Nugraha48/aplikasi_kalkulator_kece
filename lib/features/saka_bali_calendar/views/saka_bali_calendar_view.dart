/// ============================================================================
/// FILE: lib/features/saka_bali_calendar/views/saka_bali_calendar_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Kalender Saka Bali.
/// MANAJEMEN HANDLES: FR-T2-08 (Konversi Kalender Saka Bali, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan kalkulasi Pawukon, Rahinan, Purnam/Tilem,
///               serta penentuan tahun Saka Bali.
/// ============================================================================

import 'package:flutter/material.dart';

class SakaBaliCalendarView extends StatefulWidget {
  const SakaBaliCalendarView({super.key});

  @override
  State<SakaBaliCalendarView> createState() => _SakaBaliCalendarViewState();
}

class _SakaBaliCalendarViewState extends State<SakaBaliCalendarView> {
  // Handles FR-T2-08: Default input = hari ini
  DateTime _selectedDate = DateTime.now();
  String _sakaResult = '';

  void _hitungSakaBali() {
    // TODO: Implementasi logika konversi DateTime ke Tahun Saka Bali & Pawukon
    setState(() {
      _sakaResult = 'Tahun Saka 1948 (Wara: Saniscara, Wuku: Watugunung)';
    });
  }

  @override
  void initState() {
    super.initState();
    _hitungSakaBali();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Saka Bali'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Tanggal Input:'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.brightness_6),
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
                    _hitungSakaBali();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Kalender Saka Bali:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      _sakaResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
