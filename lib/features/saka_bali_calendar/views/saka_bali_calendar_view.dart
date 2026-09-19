/// ============================================================================
/// FILE: lib/features/saka_bali_calendar/views/saka_bali_calendar_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Kalender Saka Bali.
/// MANAJEMEN HANDLES: FR-T2-08 (Konversi Kalender Saka Bali, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan kalkulasi Pawukon, Rahinan, Purnam/Tilem,
///               serta penentuan tahun Saka Bali.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/saka_bali_service.dart';

class SakaBaliCalendarView extends StatefulWidget {
  const SakaBaliCalendarView({super.key});

  @override
  State<SakaBaliCalendarView> createState() => _SakaBaliCalendarViewState();
}

class _SakaBaliCalendarViewState extends State<SakaBaliCalendarView> {
  DateTime _selectedDate = DateTime.now();
  SakaBaliResult? _sakaResult;

  void _hitungSakaBali() {
    setState(() {
      _sakaResult = SakaBaliService.hitungSakaBali(_selectedDate);
    });
  }

  void _resetKeHariIni() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _hitungSakaBali();
  }

  @override
  void initState() {
    super.initState();
    _hitungSakaBali();
  }

  Widget _buildWewaranBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Saka Bali'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Pilih tanggal Masehi di bawah ini untuk melihat padanannya dalam penanggalan Saka Bali dan Siklus Pawukon.',
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
                trailing: const Icon(Icons.brightness_6, size: 32),
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
            
            if (_sakaResult != null)
              Card(
                elevation: 4,
                color: theme.colorScheme.tertiaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Alert Rahinan (Bila ada)
                      if (_sakaResult!.rahinan != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.stars, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 8),
                                  Text('RAHINAN / HARI SUCI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _sakaResult!.rahinan!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      Text(
                        'Tahun Saka',
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onTertiaryContainer.withOpacity(0.8)
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_sakaResult!.tahunSaka}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36, 
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onTertiaryContainer
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Wuku & Sasih Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Chip(
                            label: Text('Wuku: ${_sakaResult!.wuku}'),
                            backgroundColor: theme.colorScheme.tertiary,
                            labelStyle: TextStyle(color: theme.colorScheme.onTertiary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Chip(
                            label: Text('Sasih: ${_sakaResult!.sasih}'),
                            backgroundColor: theme.colorScheme.secondary,
                            labelStyle: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text('Siklus Wewaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      
                      // Grid Wewaran
                      Row(
                        children: [
                          _buildWewaranBox('Triwara', _sakaResult!.triwara, Colors.purple),
                          const SizedBox(width: 8),
                          _buildWewaranBox('Sadwara', _sakaResult!.sadwara, Colors.orange),
                          const SizedBox(width: 8),
                          _buildWewaranBox('Saptawara', _sakaResult!.saptawara, Colors.teal),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildWewaranBox('Pancawara', _sakaResult!.pancawara, Colors.brown),
                        ],
                      )
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
