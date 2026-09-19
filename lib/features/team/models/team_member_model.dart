/// ============================================================================
/// FILE: lib/features/team/models/team_member_model.dart
/// FUNGSI: Model data representasi tabel `members` PostgreSQL (Tugas 1 -> DB).
/// MANAJEMEN HANDLES: Data Model untuk FR-U-03 (Daftar Anggota Kelompok dari DB)
/// LOKASI LOGIC: Atribut nim, name, createdAt, serta converter dari/ke PostgreSQL Map.
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

  /// Factory untuk konversi dari Map PostgreSQL
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

  /// Konversi ke Map untuk query PostgreSQL
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nim': nim,
      'name': name,
    };
  }
}
