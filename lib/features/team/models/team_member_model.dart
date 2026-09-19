/// ============================================================================
/// FILE: lib/features/team/models/team_member_model.dart
/// FUNGSI: Model data representasi tabel `members` Supabase (Tugas 1 -> DB).
/// MANAJEMEN HANDLES: Struktur Data Anggota Kelompok
/// LOKASI LOGIC: Atribut nim, name, createdAt, serta converter dari/ke Map.
/// ============================================================================

class AnggotaKelompok {
  final int? id;
  final String nim;
  final String name;
  final DateTime? createdAt;

  const AnggotaKelompok({
    this.id,
    required this.nim,
    required this.name,
    this.createdAt,
  });

  /// Factory untuk konversi dari Map Supabase
  factory AnggotaKelompok.fromMap(Map<String, dynamic> map) {
    return AnggotaKelompok(
      id: map['id'] as int?,
      nim: map['nim'] as String,
      name: map['name'] as String,
      createdAt: map['created_at'] != null 
          ? (map['created_at'] is DateTime ? map['created_at'] : DateTime.parse(map['created_at'].toString()))
          : null,
    );
  }

  /// Konversi ke Map untuk query Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nim': nim,
      'name': name,
    };
  }
}
