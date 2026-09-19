// test/big_decimal_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:oneforall/models/big_decimal.dart';
import 'package:oneforall/services/calculator_service.dart';

void main() {
  group('BigDecimal High Precision Tests', () {
    test('Penjumlahan angka super besar', () {
      final a = BigDecimal.tryParse('9999999999999999999999999999999999999999');
      final b = BigDecimal.tryParse('1');
      expect(a, isNotNull);
      expect(b, isNotNull);
      final result = a! + b!;
      expect(result.toString(), '10000000000000000000000000000000000000000');
    });

    test('Perkalian presisi tinggi', () {
      final a = BigDecimal.tryParse('123456789123456789');
      final b = BigDecimal.tryParse('987654321987654321');
      expect(a, isNotNull);
      expect(b, isNotNull);
      final result = a! * b!;
      expect(result.toString(), '121932631356500531347203169112635269');
    });

    test('Format angka dengan pemisah ribuan', () {
      final val = BigDecimal.tryParse('1234567890.123');
      expect(val, isNotNull);
      expect(val!.toFormattedString(), '1.234.567.890,123');
    });

    test('Kalkulator service evaluator ekspresi kompleks', () {
      final calc = KalkulatorService();
      calc.tambahInput('1000 + 500 * (2 - 1)');
      final hasil = calc.hitung();
      expect(hasil.sukses, true);
      expect(hasil.nilai?.toString(), '1500');
    });
  });
}
