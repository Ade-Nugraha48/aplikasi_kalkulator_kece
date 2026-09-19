/// ============================================================================
/// FILE: lib/features/team/services/team_service.dart
/// FUNGSI: Service pengambil data Anggota Kelompok dari Supabase.
/// MANAJEMEN HANDLES: FR-U-03 (Fetch Anggota Kelompok dari tabel `members` Supabase DB)
/// LOKASI LOGIC: Supabase Direct Query (`Supabase.instance.client.from('members').select()`).
/// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_member_model.dart';

class TeamService {

  /// Handles FR-U-03: Membaca daftar anggota kelompok dari tabel `members` Supabase DB
  Future<List<AnggotaKelompok>> fetchMembers() async {
    // 1. Coba via Online Supabase Client
    try {
      final response = await Supabase.instance.client
          .from('members')
          .select()
          .order('id', ascending: true);

      if (response.isNotEmpty) {
        return response
            .map((item) => AnggotaKelompok.fromMap(item))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase Fetch Members gagal: $e');
      }
    }

    // Fallback data statis jika belum ada koneksi DB
    return [
      const AnggotaKelompok(nim: '123220001', name: 'Ade Nugraha'),
      const AnggotaKelompok(nim: '123220002', name: 'Anggota Kelompok 2'),
      const AnggotaKelompok(nim: '123220003', name: 'Anggota Kelompok 3'),
    ];
  }
}
