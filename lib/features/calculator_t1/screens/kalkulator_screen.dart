// lib/features/calculator_t1/screens/kalkulator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/calculation_result.dart';
import '../logic/calculator_service.dart';

// TODO: Implementasi FR-T1-01 Kalkulator Presisi (BigInt)
class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({super.key});

  @override
  State<KalkulatorScreen> createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
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
        _hasilPreview = hasil.pesanError ?? 'Error';
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
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _inputCtrl,
                      keyboardType: TextInputType.text,
                      onChanged: _hitungRealtime,
                      decoration: InputDecoration(
                        labelText: 'Input Ekspresi Matematika',
                        hintText: 'Contoh: 9999999999 + 1234567890',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _inputCtrl.clear();
                            _hitungRealtime('');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isError
                            ? (isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50)
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isError ? Colors.redAccent : theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isError ? 'Error / Status:' : 'Hasil Presisi Tinggi:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _isError ? Colors.redAccent : Colors.grey,
                                ),
                              ),
                              if (!_isError && _hasilPreview.isNotEmpty)
                                InkWell(
                                  onTap: _salinHasil,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.copy, size: 14, color: Color(0xFF6C5CE7)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Salin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6C5CE7),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _hasilPreview.isEmpty ? '0' : _hasilPreview,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _isError ? Colors.redAccent : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Keypad
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.3,
                      children: [
                        'C', '(', ')', '/',
                        '7', '8', '9', '*',
                        '4', '5', '6', '-',
                        '1', '2', '3', '+',
                        '0', '.', '⌫', '=',
                      ].map((btn) {
                        bool isOp = ['+', '-', '*', '/', '=', 'C', '⌫', '(', ')'].contains(btn);
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOp ? theme.colorScheme.primary : (isDark ? const Color(0xFF33334D) : Colors.white),
                            foregroundColor: isOp ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            elevation: isOp ? 3 : 1,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => _onKeypadTap(btn),
                          child: Text(
                            btn,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
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
