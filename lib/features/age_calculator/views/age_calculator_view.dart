/// ============================================================================
/// FILE: lib/features/age_calculator/views/age_calculator_view.dart
/// FUNGSI: Tampilan Kalkulator Umur Detail (Tahun, Bulan, Hari, Jam, Menit, Detik).
/// MANAJEMEN HANDLES: FR-T2-06 (Konversi Tanggal Lahir ke Umur Detail, default = birth_date user)
/// LOKASI LOGIC: Tempat penulisan kalkulasi selisih DateTime.now() dengan tanggal lahir user,
///               serta timer update real-time detik/jam umur.
/// ============================================================================

import 'package:flutter/material.dart';
import '../../../core/session/session_manager.dart';

class AgeCalculatorView extends StatefulWidget {
  const AgeCalculatorView({super.key});

  @override
  State<AgeCalculatorView> createState() => _AgeCalculatorViewState();
}

class _AgeCalculatorViewState extends State<AgeCalculatorView> {
  DateTime _birthDate = DateTime(2000, 1, 1);

  @override
  void initState() {
    super.initState();
    // Handles FR-T2-06: Default input dari birth_date user di Session/DB
    final user = SessionManager().currentUser;
    if (user != null && user['birth_date'] != null) {
      _birthDate = user['birth_date'] is DateTime 
          ? user['birth_date'] 
          : DateTime.tryParse(user['birth_date'].toString()) ?? _birthDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(_birthDate);

    final years = now.year - _birthDate.year;
    final months = now.month - _birthDate.month;
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Umur Anda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Tanggal Lahir Input:'),
                subtitle: Text('${_birthDate.day}/${_birthDate.month}/${_birthDate.year}'),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _birthDate = picked;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            // Output Detail Umur: Tahun, Bulan, Hari, Jam, Menit, Detik
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text('Umur: ~$years Tahun $months Bulan', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    ListTile(title: const Text('Total Hari'), trailing: Text('$days hari')),
                    ListTile(title: const Text('Total Jam'), trailing: Text('$hours jam')),
                    ListTile(title: const Text('Total Menit'), trailing: Text('$minutes menit')),
                    ListTile(title: const Text('Total Detik'), trailing: Text('$seconds detik')),
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
