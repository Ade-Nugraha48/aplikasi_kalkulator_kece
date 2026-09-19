/// ============================================================================
/// FILE: lib/features/calculator/views/calculator_view.dart
/// FUNGSI: Tampilan Halaman Kalkulator Presisi Super (Big Integer).
/// MANAJEMEN HANDLES: FR-T1-01 (Kalkulator Presisi Super Big Integer UI)
/// LOKASI LOGIC: UI Keypad interaktif, input ekspresi matematika kompleks,
///               preview hasil kalkulasi real-time, serta tombol salin hasil.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculation_result.dart';
import '../services/calculator_service.dart';

class ViewKalkulator extends StatefulWidget {
  const ViewKalkulator({super.key});

  @override
  State<ViewKalkulator> createState() => _ViewKalkulatorState();
}

class _ViewKalkulatorState extends State<ViewKalkulator> {
  final KalkulatorService _kalkulator = KalkulatorService();
  final TextEditingController _inputCtrl = TextEditingController();
  String _hasilPreview = '';
  bool _isError = false;

  void _hitungRealtime(String input) {
    _kalkulator.reset();
    _kalkulator.tambahInput(input);

    if (_kalkulator.apakahKosong) {
      setState(() {
        _hasilPreview = '';
        _isError = false;
      });
      return;
    }

    HasilKalkulasi hasil = _kalkulator.hitung();
    setState(() {
      if (hasil.sukses && hasil.nilai != null) {
        _hasilPreview = hasil.nilai!.toFormattedString();
        _isError = false;
      } else {
        _hasilPreview = hasil.pesanPesanError ?? 'Error';
        _isError = true;
      }
    });
  }

  void _onKeypadTap(String val) {
    String current = _inputCtrl.text;
    if (val == 'C') {
      _inputCtrl.clear();
      _hitungRealtime('');
    } else if (val == '⌫') {
      if (current.isNotEmpty) {
        String updated = current.substring(0, current.length - 1);
        _inputCtrl.text = updated;
        _inputCtrl.selection = TextSelection.fromPosition(TextPosition(offset: updated.length));
        _hitungRealtime(updated);
      }
    } else if (val == '=') {
      _hitungRealtime(_inputCtrl.text);
    } else {
      String updated = current + val;
      _inputCtrl.text = updated;
      _inputCtrl.selection = TextSelection.fromPosition(TextPosition(offset: updated.length));
      _hitungRealtime(updated);
    }
  }

  void _salinHasil() {
    if (_hasilPreview.isNotEmpty && !_isError) {
      Clipboard.setData(ClipboardData(text: _hasilPreview.replaceAll('.', '').replaceAll(',', '.')));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Hasil berhasil disalin ke clipboard!'),
            ],
          ),
          backgroundColor: Color(0xFF6C5CE7),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Presisi'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.calculate, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kalkulator Presisi Tinggi',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Mendukung angka super besar & ekspresi matematika kompleks',
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
                        controller: _inputCtrl,
                        onChanged: _hitungRealtime,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\*\/\.\(\)\s]')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Contoh: 1000 + 500 * (2 - 1)',
                          labelText: 'Masukkan Ekspresi',
                          suffixIcon: _inputCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _inputCtrl.clear();
                                    _hitungRealtime('');
                                  },
                                )
                              : const Icon(Icons.edit_note),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text('Contoh: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            _buildSampleChip('1000 + 500 * (2 - 1)'),
                            _buildSampleChip('9999999999999999 * 8888888888888888'),
                            _buildSampleChip('100 / 3'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_hasilPreview.isNotEmpty) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _isError
                      ? Card(
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
                                SelectableText(
                                  _hasilPreview,
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
                        )
                      : Card(
                          color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.4) : theme.colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Hasil Kalkulasi:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark ? Colors.purpleAccent : theme.colorScheme.primary,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _salinHasil,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.copy, size: 14),
                                            SizedBox(width: 4),
                                            Text('Salin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SelectableText(
                                  _hasilPreview,
                                  style: TextStyle(
                                    fontSize: _hasilPreview.length > 30 ? 18 : 26,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                    color: isDark ? Colors.white : Colors.deepPurple.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Keypad Interaktif',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      _buildKeypadGrid(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildSampleChip(String expr) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        label: Text(expr, style: const TextStyle(fontSize: 11)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        onPressed: () {
          _inputCtrl.text = expr;
          _hitungRealtime(expr);
        },
      ),
    );
  }

  Widget _buildKeypadGrid() {
    final List<List<String>> layout = [
      ['C', '(', ')', '/'],
      ['7', '8', '9', '*'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '⌫', '='],
    ];

    return Column(
      children: layout.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: row.map((btn) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildKeyButton(btn),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton(String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    bool isOp = ['+', '-', '*', '/', '='].contains(text);
    bool isAction = ['C', '⌫', '(', ')'].contains(text);

    Color bgColor;
    Color textColor;

    if (text == '=') {
      bgColor = theme.colorScheme.primary;
      textColor = Colors.white;
    } else if (isOp) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.15);
      textColor = theme.colorScheme.primary;
    } else if (isAction) {
      bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
      textColor = text == 'C' ? Colors.redAccent : (isDark ? Colors.white : Colors.black87);
    } else {
      bgColor = isDark ? const Color(0xFF2A2A3C) : Colors.grey.shade100;
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 1,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _onKeypadTap(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: text == '⌫' ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
