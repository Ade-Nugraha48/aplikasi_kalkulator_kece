// lib/features/math_tools/domain/calculation_result.dart
import 'big_decimal.dart';

/// Model Pembungkus Hasil Kalkulasi (Sukses / Gagal).
class HasilKalkulasi {
  final BigDecimal? nilai;
  final bool sukses;
  final String? pesanError;

  HasilKalkulasi.sukses(this.nilai)
      : sukses = true,
        pesanError = null;

  HasilKalkulasi.gagal(this.pesanError)
      : sukses = false,
        nilai = null;
}
