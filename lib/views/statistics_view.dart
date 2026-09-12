// lib/views/statistics_view.dart
import 'package:flutter/material.dart';
import '../models/big_decimal.dart';

class ViewTotalAngka extends StatefulWidget {
  const ViewTotalAngka({super.key});

  @override
  State<ViewTotalAngka> createState() => _ViewTotalAngkaState();
}

class _ViewTotalAngkaState extends State<ViewTotalAngka> {
  final _deretCtrl = TextEditingController();
  String _hasilAnalisis = '';
  int _totalValidCount = 0;
  String _sumVal = '';
  String _avgVal = '';
  String _minVal = '';
  String _maxVal = '';
  bool _hasResult = false;

  void _hitungStatistik() {
    FocusScope.of(context).unfocus();
    String input = _deretCtrl.text.trim();
    if (input.isEmpty) return;

    List<String> rawTokens = input.split(RegExp(r'[\s,]+'));
    List<BigDecimal> validNumbers = [];

    for (String item in rawTokens) {
      if (item.isEmpty) continue;
      BigDecimal? num = BigDecimal.tryParse(item);
      if (num != null) validNumbers.add(num);
    }

    if (validNumbers.isEmpty) {
      setState(() {
        _hasResult = false;
        _hasilAnalisis = 'Tidak ada angka valid yang dimasukkan.';
      });
      return;
    }

    BigDecimal total = BigDecimal.zero;
    BigDecimal minVal = validNumbers.first;
    BigDecimal maxVal = validNumbers.first;

    for (BigDecimal num in validNumbers) {
      total += num;
      if (num < minVal) minVal = num;
      if (num > maxVal) maxVal = num;
    }

    BigDecimal count = BigDecimal.fromInt(validNumbers.length);
    BigDecimal average = total.divide(count, maxScale: 50);

    setState(() {
      _hasResult = true;
      _totalValidCount = validNumbers.length;
      _sumVal = total.toFormattedString();
      _avgVal = average.toFormattedString();
      _minVal = minVal.toFormattedString();
      _maxVal = maxVal.toFormattedString();
      _hasilAnalisis = '''
Banyak Angka Valid : ${validNumbers.length}

Total Penjumlahan  : $_sumVal
Rata-Rata (Average): $_avgVal
Nilai Terkecil     : $_minVal
Nilai Terbesar     : $_maxVal
''';
    });
  }

  @override
  void dispose() {
    _deretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.analytics, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hitung Jumlah & Statistik',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Analisis deret angka (Total, Rata-rata, Min, Max)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _deretCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Ketik deret angka dipisahkan spasi atau koma\n\nContoh: 1000 5000 2500 1000000000',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _hitungStatistik,
                          icon: const Icon(Icons.show_chart),
                          label: const Text('HITUNG STATISTIK', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_hasilAnalisis.isNotEmpty) ...[
                if (_hasResult) ...[
                  Card(
                    color: isDark ? Colors.teal.shade900.withValues(alpha: 0.3) : Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.assessment, color: Colors.teal),
                              SizedBox(width: 8),
                              Text('Hasil Ringkasan Statistik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildStatRow('Banyak Angka Valid', '$_totalValidCount data'),
                          _buildStatRow('Total Penjumlahan', _sumVal),
                          _buildStatRow('Rata-Rata (Average)', _avgVal),
                          _buildStatRow('Nilai Terkecil (Min)', _minVal),
                          _buildStatRow('Nilai Terbesar (Max)', _maxVal),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_hasilAnalisis, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Text(' :  '),
          Expanded(
            flex: 3,
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
