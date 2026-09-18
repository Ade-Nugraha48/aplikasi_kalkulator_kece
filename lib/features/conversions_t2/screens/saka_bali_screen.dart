// lib/features/conversions_t2/screens/saka_bali_screen.dart
import 'package:flutter/material.dart';

// TODO: Implementasi FR-T2-08 Konversi Kalender Saka Bali di sini
class SakaBaliScreen extends StatefulWidget {
  const SakaBaliScreen({super.key});

  @override
  State<SakaBaliScreen> createState() => _SakaBaliScreenState();
}

class _SakaBaliScreenState extends State<SakaBaliScreen> {
  DateTime _selectedDate = DateTime.now();
  String _hasilSaka = '';

  void _konversiSakaBali() {
    // TODO: Implementasi perhitungan Saka Bali lengkap (Wuku, Pawukon, Rahinan)
    int tahunSaka = _selectedDate.year - 78;
    setState(() {
      _hasilSaka = 'Tahun Saka Bali: $tahunSaka Saka\n'
          'Tanggal Masehi: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Kalender Saka Bali'),
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
                    const Icon(Icons.temple_hindu, size: 60, color: Color(0xFF6C5CE7)),
                    const SizedBox(height: 16),
                    const Text(
                      'Konversi Kalender Saka Bali',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      title: const Text('Pilih Tanggal Masehi'),
                      subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _konversiSakaBali,
                      child: const Text('HITUNG SAKA BALI'),
                    ),
                    if (_hasilSaka.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _hasilSaka,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C5CE7),
                            fontSize: 15,
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
