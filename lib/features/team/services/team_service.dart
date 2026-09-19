/// ============================================================================
/// FILE: lib/features/team/services/team_service.dart
/// FUNGSI: Service pengambil data Anggota Kelompok dari PostgreSQL.
/// MANAJEMEN HANDLES: FR-U-03 (Fetch Anggota Kelompok dari tabel `members` DB)
/// LOKASI LOGIC: Tempat penulisan query SELECT * FROM members ORDER BY id ASC.
/// ============================================================================

import 'dart:async';
import '../models/team_member_model.dart';
import '../../../core/database/database_helper.dart';

class TeamService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Handles FR-U-03: Membaca daftar anggota kelompok dari tabel `members` DB PostgreSQL
  Future<List<AnggotaKelompok>> fetchMembers() async {
    // TODO: Implementasi SQL SELECT * FROM members ORDER BY id ASC
    return [
      const AnggotaKelompok(nim: '123220001', name: 'Anggota 1'),
      const AnggotaKelompok(nim: '123220002', name: 'Anggota 2'),
    ];
  }
}
