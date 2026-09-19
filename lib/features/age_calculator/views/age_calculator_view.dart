/// ============================================================================
/// FILE: lib/features/age_calculator/views/age_calculator_view.dart
/// FUNGSI: Tampilan Kalkulator Umur Detail (Tahun, Bulan, Hari, Jam, Menit, Detik).
/// MANAJEMEN HANDLES: FR-T2-06 (Konversi Tanggal Lahir ke Umur Detail, default = birth_date user)
/// LOKASI LOGIC: Tempat penulisan kalkulasi selisih DateTime.now() dengan tanggal lahir user,
///               serta timer update real-time detik/jam umur.
/// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/session/session_manager.dart';
import '../services/age_calculator_service.dart';

class AgeCalculatorView extends StatefulWidget {
  const AgeCalculatorView({super.key});

  @override
  State<AgeCalculatorView> createState() => _AgeCalculatorViewState();
}

class _AgeCalculatorViewState extends State<AgeCalculatorView> {
  DateTime _birthDate = DateTime(2000, 1, 1);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Handles FR-T2-06: Default input dari birth_date user di Session/DB
    final user = SessionManager().currentUser;
    if (user != null && user['birth_date'] != null) {
      final dbDate = user['birth_date'] is DateTime 
          ? user['birth_date'] 
          : DateTime.tryParse(user['birth_date'].toString());
      if (dbDate != null) {
        // Handle timezone offset (bug prevention)
        _birthDate = dbDate.toLocal();
      }
    }

    // Memulai Timer Real-time setiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Memicu re-render UI age secara instan
      }
    });
  }

  @override
  void dispose() {
    // Mematikan timer saat berpindah halaman agar tidak Memory Leak
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pilihTanggalLahir() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // Validasi Bug: Tidak boleh tanggal depan
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_birthDate),
      );
      
      if (pickedTime != null) {
        final newDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Validasi: Waktu kombinasi tidak boleh > waktu sekarang
        if (newDate.isAfter(DateTime.now())) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tanggal lahir tidak boleh melebihi waktu saat ini!'),
                backgroundColor: Colors.red,
              )
            );
          }
          return; // Batalkan
        }

        setState(() {
          _birthDate = newDate;
        });
      }
    }
  }

  Widget _buildAgeBox(String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ageMap = AgeCalculatorService.calculateAge(_birthDate);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Umur Anda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: const Text('Tanggal Lahir (Default: Info Akun)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('dd MMMM yyyy, HH:mm').format(_birthDate),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: const Icon(Icons.edit_calendar, size: 30),
                onTap: _pilihTanggalLahir,
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Umur Akurat Anda:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _buildAgeBox(ageMap['years'].toString(), 'Tahun', Colors.purple),
                _buildAgeBox(ageMap['months'].toString(), 'Bulan', Colors.blue),
                _buildAgeBox(ageMap['days'].toString(), 'Hari', Colors.teal),
                _buildAgeBox(ageMap['hours'].toString(), 'Jam', Colors.orange),
                _buildAgeBox(ageMap['minutes'].toString(), 'Menit', Colors.brown),
                _buildAgeBox(ageMap['seconds'].toString(), 'Detik', Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Umur Anda saat ini adalah ${ageMap['years']} Tahun, ${ageMap['months']} Bulan, ${ageMap['days']} Hari, ${ageMap['hours']} Jam, ${ageMap['minutes']} Menit, dan ${ageMap['seconds']} Detik.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onPrimaryContainer,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
