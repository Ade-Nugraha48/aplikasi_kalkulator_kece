/// ============================================================================
/// FILE: lib/features/statistics/views/statistics_view.dart
/// FUNGSI: Tampilan Hitung Jumlah & Statistik Deret Angka.
/// MANAJEMEN HANDLES: FR-T1-03 (Deret Jumlah & Statistik Angka UI & Logic)
/// LOKASI LOGIC: Input deret angka dipisah spasi/koma, parsing ke BigDecimal,
///               kalkulasi total penjumlahan, rata-rata, nilai min, dan nilai max.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../calculator/models/big_decimal.dart';

class ViewTotalAngka extends StatefulWidget {
  const ViewTotalAngka({super.key});

  @override
  State<ViewTotalAngka> createState() => _ViewTotalAngkaState();
}

class _ViewTotalAngkaState extends State<ViewTotalAngka> {
  final _deretCtrl = TextEditingController();
  String _errorMessage = '';
  int _totalValidCount = 0;
  String _sumVal = '';
  String _avgVal = '';
  String _minVal = '';
  String _maxVal = '';
  bool _hasResult = false;

  void _hitungStatistik() {
    FocusScope.of(context).unfocus();
    String input = _deretCtrl.text.trim();
    if (input.isEmpty) {
      setState(() {
        _hasResult = false;
        _errorMessage = 'Harap masukkan deret angka terlebih dahulu.';
      });
      return;
    }

    List<String> rawTokens = input.split(RegExp(r'[\s,]+'));
    List<BigDecimal> validNumbers = [];
    List<String> invalidTokens = [];

    for (String item in rawTokens) {
      if (item.isEmpty) continue;
      BigDecimal? num = BigDecimal.tryParse(item);
      if (num != null) {
        validNumbers.add(num);
      } else {
        invalidTokens.add(item);
      }
    }

    if (invalidTokens.isNotEmpty) {
      setState(() {
        _hasResult = false;
        _errorMessage =
            'Input mengandung data yang bukan angka valid:\n"${invalidTokens.join(', ')}"\n\nHanya angka yang diperbolehkan (pisahkan dengan spasi atau koma).';
      });
      return;
    }

    if (validNumbers.isEmpty) {
      setState(() {
        _hasResult = false;
        _errorMessage = 'Tidak ada angka valid yang dimasukkan.';
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
      _errorMessage = '';
      _totalValidCount = validNumbers.length;
      _sumVal = total.toFormattedString();
      _avgVal = average.toFormattedString();
      _minVal = minVal.toFormattedString();
      _maxVal = maxVal.toFormattedString();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hitung Statistik'),
      ),
      body: SingleChildScrollView(
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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\s,\.\-]')),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Ketik deret angka dipisahkan spasi atau koma',
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
              ] else if (_errorMessage.isNotEmpty) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    color: isDark ? Colors.red.shade900.withValues(alpha: 0.4) : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Input Tidak Valid',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
