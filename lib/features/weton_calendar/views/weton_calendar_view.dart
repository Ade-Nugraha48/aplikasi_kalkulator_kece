/// ============================================================================
/// FILE: lib/features/weton_calendar/views/weton_calendar_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Kalender Weton Jawa.
/// MANAJEMEN HANDLES: FR-T2-07 (Konversi Kalender Weton, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan algoritma pencarian pasaran Jawa (Legi, Pahing,
///               Pon, Wage, Kliwon) & perhitungan Neptu.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weton_service.dart';

class WetonCalendarView extends StatefulWidget {
  const WetonCalendarView({super.key});

  @override
  State<WetonCalendarView> createState() => _WetonCalendarViewState();
}

class _WetonCalendarViewState extends State<WetonCalendarView> {
  DateTime _selectedDate = DateTime.now();
  WetonResult? _wetonResult;

  void _hitungWeton() {
    setState(() {
      _wetonResult = WetonService.hitungWeton(_selectedDate);
    });
  }

  void _resetKeHariIni() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _hitungWeton();
  }

  @override
  void initState() {
    super.initState();
    _hitungWeton();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Weton Jawa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Pilih tanggal Masehi di bawah ini untuk melihat Hari Pasaran Jawa beserta penjelasan wataknya.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: const Text('Tanggal Kelahiran / Masehi:', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.event_note, size: 32),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900), // Batas limit (FR-T2-07)
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
            
            if (_wetonResult != null)
              Card(
                elevation: 4,
                color: theme.colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Hasil Weton Jawa',
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8)
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _wetonResult!.wetonLengkap,
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Badge Neptu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total Neptu: ${_wetonResult!.totalNeptu} (${_wetonResult!.namaHari}: ${_wetonResult!.neptuHari} + ${_wetonResult!.namaPasaran}: ${_wetonResult!.neptuPasaran})',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // Penjelasan Watak
                      const Text(
                        'Gambaran Karakter/Watak',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _wetonResult!.watak,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, height: 1.4),
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
