/// ============================================================================
/// FILE: lib/features/hijri_converter/views/hijri_converter_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Tanggal Hijriah.
/// MANAJEMEN HANDLES: FR-T2-05 (Konversi Tanggal Hijriah, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan DatePicker Masehi & algoritma/library konversi
///               ke tanggal, bulan, dan tahun Hijriah Islam.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/hijri_service.dart';

class HijriConverterView extends StatefulWidget {
  const HijriConverterView({super.key});

  @override
  State<HijriConverterView> createState() => _HijriConverterViewState();
}

class _HijriConverterViewState extends State<HijriConverterView> {
  DateTime _selectedDate = DateTime.now();
  String _hijriResult = '';

  void _konversiKeHijriah() {
    setState(() {
      _hijriResult = HijriService.convertToHijri(_selectedDate);
    });
  }

  void _resetKeHariIni() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _konversiKeHijriah();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Pilih tanggal Masehi di bawah ini untuk melihat padanannya dalam penanggalan Hijriah.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: const Text('Tanggal Masehi:', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_month, size: 32),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900), // Batas aman konversi (FR-T2-05)
                    lastDate: DateTime(2100),
                    helpText: 'Pilih Tanggal Masehi',
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetKeHariIni,
              icon: const Icon(Icons.today),
              label: const Text('Kembali ke Hari Ini'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      'Hasil Konversi Hijriah',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _hijriResult,
                      style: TextStyle(
                        fontSize: 26, 
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer
                      ),
                      textAlign: TextAlign.center,
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
