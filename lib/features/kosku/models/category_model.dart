/// ============================================================================
/// FILE: lib/features/kosku/models/category_model.dart
/// FUNGSI: Model data representasi tabel `categories` Supabase.
/// MANAJEMEN HANDLES: Struktur Data Kategori Transaksi
/// LOKASI LOGIC: Menyimpan informasi id, userId, name, type (pemasukan/pengeluaran),
///               serta method toMap() dan fromMap() untuk query Supabase.
/// ============================================================================

class CategoryModel {
  final int? id;
  final int userId;
  final String name;
  final String type; // 'pemasukan' atau 'pengeluaran'
  final DateTime? createdAt;

  CategoryModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      type: map['type'].toString(),
      createdAt: map['created_at'] != null 
          ? (map['created_at'] is DateTime ? map['created_at'] : DateTime.parse(map['created_at'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
    };
  }
}
