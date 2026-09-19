/// ============================================================================
/// FILE: lib/features/calculator/models/calculation_result.dart
/// FUNGSI: Data model pembungkus hasil eksekusi ekspresi matematika kalkulator.
/// MANAJEMEN HANDLES: Model untuk FR-T1-01 (Super Precision Calculator)
/// LOKASI LOGIC: Menyimpan nilai BigDecimal hasil hitungan atau pesan error jika terjadi kegagalan.
/// ============================================================================

import 'big_decimal.dart';

class HasilKalkulasi {
  final BigDecimal? nilai;
  final String? pesanPesanError;
  final bool sukses;

  HasilKalkulasi.sukses(this.nilai)
      : pesanPesanError = null,
        sukses = true;

  HasilKalkulasi.gagal(this.pesanPesanError)
      : nilai = null,
        sukses = false;
}
