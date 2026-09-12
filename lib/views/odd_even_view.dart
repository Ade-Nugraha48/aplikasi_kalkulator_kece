// lib/views/odd_even_view.dart
import 'package:flutter/material.dart';
import '../models/big_decimal.dart';

class ViewGanjilGenap extends StatefulWidget {
  const ViewGanjilGenap({super.key});

  @override
  State<ViewGanjilGenap> createState() => _ViewGanjilGenapState();
}

class _ViewGanjilGenapState extends State<ViewGanjilGenap> {
  final _angkaCtrl = TextEditingController();
  String _status = '';
  Color _statusColor = Colors.black;
  bool _isGenap = false;
  bool _hasResult = false;

  void _cekAngka() {
    FocusScope.of(context).unfocus();
    String input = _angkaCtrl.text.replaceAll(',', '').trim();
    if (input.isEmpty) {
      setState(() {
        _status = 'Harap masukkan bilangan terlebih dahulu.';
        _statusColor = Colors.grey;
        _hasResult = false;
      });
      return;
    }

    BigDecimal? dec = BigDecimal.tryParse(input);
    if (dec == null) {
      setState(() {
        _status = 'Input bukan angka yang valid.';
        _statusColor = Colors.red;
        _hasResult = false;
      });
      return;
    }

    if (!dec.isInteger) {
      setState(() {
        _status = 'Angka adalah desimal (Ganjil/Genap hanya berlaku untuk bilangan bulat).';
        _statusColor = Colors.orange;
        _hasResult = false;
      });
      return;
    }

    BigInt angka = dec.toBigInt();
    bool genap = (angka % BigInt.two == BigInt.zero);

    setState(() {
      _hasResult = true;
      _isGenap = genap;
      if (genap) {
        _status = 'Bilangan ${dec.toFormattedString()} adalah GENAP.';
        _statusColor = Colors.green;
      } else {
        _status = 'Bilangan ${dec.toFormattedString()} adalah GANJIL.';
        _statusColor = Colors.blue;
      }
    });
  }

  @override
  void dispose() {
    _angkaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        child: Icon(Icons.numbers, size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cek Ganjil / Genap',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Analisis sifat bilangan bulat super besar',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _angkaCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _cekAngka(),
                        decoration: const InputDecoration(
                          labelText: 'Masukkan Bilangan Bulat',
                          hintText: 'Contoh: 9876543210123456789',
                          prefixIcon: Icon(Icons.pin),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _cekAngka,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search),
                              SizedBox(width: 8),
                              Text('CEK BILANGAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_status.isNotEmpty) ...[
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    color: _hasResult
                        ? (_isGenap
                            ? (isDark ? Colors.teal.shade900.withValues(alpha: 0.4) : Colors.teal.shade50)
                            : (isDark ? Colors.blue.shade900.withValues(alpha: 0.4) : Colors.blue.shade50))
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            _hasResult
                                ? (_isGenap ? Icons.check_circle_outline : Icons.info_outline)
                                : Icons.warning_amber_rounded,
                            size: 40,
                            color: _statusColor,
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _status,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color: _statusColor,
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
    );
  }
}
