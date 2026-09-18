// lib/features/calculator_t1/screens/statistik_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/big_decimal.dart';

// TODO: Implementasi FR-T1-03 Deret Jumlah & Statistik
class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  final _deretCtrl = TextEditingController();
  String _hasilAnalisis = '';
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
        _hasilAnalisis = '';
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
        _hasilAnalisis = '';
      });
      return;
    }

    if (validNumbers.isEmpty) {
      setState(() {
        _hasResult = false;
        _errorMessage = 'Tidak ada angka valid yang dimasukkan.';
        _hasilAnalisis = '';
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
      _hasilAnalisis =
          '''
Banyak Angka Valid : ${validNumbers.length}

Total Penjumlahan  : $_sumVal
Rata-Rata (Average): $_avgVal
Nilai Terkecil     : $_minVal
Nilai Terbesar     : $_maxVal
''';
    });
  }

  void _salinStatistik() {
    if (_hasilAnalisis.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _hasilAnalisis));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Hasil analisis berhasil disalin!'),
            ],
          ),
          backgroundColor: Color(0xFF6C5CE7),
        ),
      );
    }
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
        title: const Text('Deret Jumlah & Statistik'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              ),
                              child: Icon(Icons.analytics, color: theme.colorScheme.primary, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hitung Jumlah & Statistik Deret',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Pisahkan angka dengan spasi atau koma',
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
                        const SizedBox(height: 20),
                        TextField(
                          controller: _deretCtrl,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            labelText: 'Masukkan Deret Angka',
                            hintText: 'Contoh: 100, 250, 400.5, 9999999999',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _hitungStatistik,
                            icon: const Icon(Icons.calculate),
                            label: const Text('PROSES & ANALISIS DERET'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: isDark ? Colors.red.shade900.withValues(alpha: 0.4) : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_hasResult) ...[
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hasil Analisis Statistik',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Color(0xFF6C5CE7)),
                                tooltip: 'Salin Ringkasan',
                                onPressed: _salinStatistik,
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 12),
                          _buildStatRow('Jumlah Data (N)', '$_totalValidCount angka', isDark),
                          const SizedBox(height: 10),
                          _buildStatRow('Total Penjumlahan', _sumVal, isDark, isHighlight: true),
                          const SizedBox(height: 10),
                          _buildStatRow('Rata-Rata (Average)', _avgVal, isDark),
                          const SizedBox(height: 10),
                          _buildStatRow('Nilai Minimum', _minVal, isDark),
                          const SizedBox(height: 10),
                          _buildStatRow('Nilai Maksimum', _maxVal, isDark),
                        ],
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

  Widget _buildStatRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlight
            ? (isDark ? const Color(0xFF33334D) : const Color(0xFFF0EDFF))
            : (isDark ? Colors.grey.shade900.withValues(alpha: 0.3) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isHighlight ? 15 : 13,
                color: isHighlight ? const Color(0xFF6C5CE7) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
