// lib/features/calculator_t1/screens/ganjil_genap_screen.dart
import 'package:flutter/material.dart';
import '../logic/big_decimal.dart';

// TODO: Implementasi FR-T1-02 Cek Ganjil Genap
class GanjilGenapScreen extends StatefulWidget {
  const GanjilGenapScreen({super.key});

  @override
  State<GanjilGenapScreen> createState() => _GanjilGenapScreenState();
}

class _GanjilGenapScreenState extends State<GanjilGenapScreen> {
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
        _statusColor = Colors.red;
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
        _statusColor = Colors.red;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Ganjil / Genap'),
      ),
      body: Center(
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
                        Text(
                          'Deteksi Bilangan Ganjil & Genap',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mendukung angka sangat besar tanpa batas (BigInt)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _angkaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Masukkan Angka',
                            hintText: 'Contoh: 123456789123456789',
                            prefixIcon: Icon(Icons.pin),
                          ),
                          onSubmitted: (_) => _cekAngka(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _cekAngka,
                            child: const Text('PERIKSA BILANGAN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_status.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    color: _hasResult
                        ? (_isGenap ? Colors.green.shade50 : Colors.blue.shade50)
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(
                            _hasResult ? (_isGenap ? Icons.check_circle : Icons.info) : Icons.error,
                            color: _statusColor,
                            size: 32,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _status,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _statusColor,
                              ),
                            ),
                          ),
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
}
