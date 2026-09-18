// lib/features/conversions_t2/screens/hijriah_screen.dart
import 'package:flutter/material.dart';

// TODO: Implementasi FR-T2-05 Konversi Tanggal Hijriah di sini
class HijriahScreen extends StatefulWidget {
  const HijriahScreen({super.key});

  @override
  State<HijriahScreen> createState() => _HijriahScreenState();
}

class _HijriahScreenState extends State<HijriahScreen> {
  DateTime _selectedDate = DateTime.now();
  String _hasilHijriah = '';

  void _konversiHijriah() {
    // TODO: Gantikan dengan algoritma perhitungan kalender Hijriah presisi
    setState(() {
      _hasilHijriah = 'Tanggal Masehi ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} setara dengan kalender Hijriah.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Tanggal Hijriah'),
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
                    const Icon(Icons.calendar_month, size: 60, color: Color(0xFF6C5CE7)),
                    const SizedBox(height: 16),
                    const Text(
                      'Konversi Kalender Masehi ke Hijriah',
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
                      trailing: const Icon(Icons.event),
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
                      onPressed: _konversiHijriah,
                      child: const Text('HITUNG KONVERSI HIJRIAH'),
                    ),
                    if (_hasilHijriah.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _hasilHijriah,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7)),
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
