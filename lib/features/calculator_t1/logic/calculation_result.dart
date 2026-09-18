// lib/features/calculator_t1/logic/calculation_result.dart
import 'big_decimal.dart';

class HasilKalkulasi {
  final bool sukses;
  final BigDecimal? nilai;
  final String? pesanError;

  HasilKalkulasi.sukses(this.nilai)
      : sukses = true,
        pesanError = null;

  HasilKalkulasi.gagal(this.pesanError)
      : sukses = false,
        nilai = null;
}
