/// ============================================================================
/// FILE: lib/features/hijri_converter/views/hijri_converter_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Tanggal Hijriah.
/// MANAJEMEN HANDLES: FR-T2-05 (Konversi Tanggal Hijriah, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan DatePicker Masehi & algoritma/library konversi
///               ke tanggal, bulan, dan tahun Hijriah Islam.
/// ============================================================================

import 'package:flutter/material.dart';

class HijriConverterView extends StatefulWidget {
  const HijriConverterView({super.key});

  @override
  State<HijriConverterView> createState() => _HijriConverterViewState();
}

class _HijriConverterViewState extends State<HijriConverterView> {
  // Default input = hari ini (FR-T2-05)
  DateTime _selectedDate = DateTime.now();
  String _hijriResult = '';

  void _konversiKeHijriah() {
    // TODO: Implementasi logika konversi DateTime masehi ke Tanggal Hijriah
    setState(() {
      _hijriResult = '14 Rabiul Awal 1448 H';
    });
  }

  @override
  void initState() {
    super.initState();
    _konversiKeHijriah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Tanggal Hijriah'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Tanggal Masehi Input:'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
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
                    _konversiKeHijriah();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Hasil Konversi Tanggal Hijriah:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      _hijriResult,
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
