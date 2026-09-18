// lib/features/conversions_t2/screens/weton_screen.dart
import 'package:flutter/material.dart';

// TODO: Implementasi FR-T2-07 Konversi Kalender Weton di sini
class WetonScreen extends StatefulWidget {
  const WetonScreen({super.key});

  @override
  State<WetonScreen> createState() => _WetonScreenState();
}

class _WetonScreenState extends State<WetonScreen> {
  DateTime _selectedDate = DateTime.now();
  String _hasilWeton = '';

  void _hitungWeton() {
    // TODO: Gantikan dengan logika kalkulasi pasaran (Legi, Pahing, Pon, Wage, Kliwon)
    final pasaranList = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];
    final hariList = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    String hari = hariList[_selectedDate.weekday % 7];
    String pasaran = pasaranList[_selectedDate.day % 5];

    setState(() {
      _hasilWeton = 'Weton untuk ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}:\n$hari $pasaran';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Kalender Weton'),
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
                    const Icon(Icons.auto_awesome, size: 60, color: Color(0xFF6C5CE7)),
                    const SizedBox(height: 16),
                    const Text(
                      'Hitung Weton Jawa',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      title: const Text('Pilih Tanggal'),
                      subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      trailing: const Icon(Icons.today),
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
                      onPressed: _hitungWeton,
                      child: const Text('HITUNG WETON'),
                    ),
                    if (_hasilWeton.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _hasilWeton,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C5CE7),
                            fontSize: 16,
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
