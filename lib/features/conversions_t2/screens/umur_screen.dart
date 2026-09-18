// lib/features/conversions_t2/screens/umur_screen.dart
import 'package:flutter/material.dart';

// TODO: Implementasi FR-T2-06 Konversi Tanggal Lahir ke Umur Rinci di sini
class UmurScreen extends StatefulWidget {
  const UmurScreen({super.key});

  @override
  State<UmurScreen> createState() => _UmurScreenState();
}

class _UmurScreenState extends State<UmurScreen> {
  DateTime? _tanggalLahir;
  String _hasilUmur = '';

  void _hitungUmurRinci() {
    if (_tanggalLahir == null) return;
    DateTime now = DateTime.now();

    int years = now.year - _tanggalLahir!.year;
    int months = now.month - _tanggalLahir!.month;
    int days = now.day - _tanggalLahir!.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    Duration diff = now.difference(_tanggalLahir!);
    int totalHari = diff.inDays;
    int totalJam = diff.inHours;

    setState(() {
      _hasilUmur = '''
Umur Anda saat ini:
• $years Tahun, $months Bulan, $days Hari
• Total Hari : $totalHari Hari
• Total Jam  : $totalJam Jam
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Umur Rinci'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.cake, size: 60, color: Color(0xFF6C5CE7)),
                    const SizedBox(height: 16),
                    const Text(
                      'Kalkulator Umur Presisi Rinci',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      title: const Text('Pilih Tanggal Lahir'),
                      subtitle: Text(_tanggalLahir == null
                          ? 'Belum dipilih'
                          : '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}'),
                      trailing: const Icon(Icons.cake_outlined),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _tanggalLahir = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _hitungUmurRinci,
                      child: const Text('HITUNG UMUR RINCI'),
                    ),
                    if (_hasilUmur.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _hasilUmur,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C5CE7),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
