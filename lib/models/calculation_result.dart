// lib/models/calculation_result.dart
import 'big_decimal.dart';

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
