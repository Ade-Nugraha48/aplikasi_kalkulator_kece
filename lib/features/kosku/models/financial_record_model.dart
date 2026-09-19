/// ============================================================================
/// FILE: lib/features/kosku/models/financial_record_model.dart
/// FUNGSI: Model data representasi tabel `financial_records` PostgreSQL.
/// MANAJEMEN HANDLES: Model data transaksi Keuangan Anak Kos "KosKu"
/// LOKASI LOGIC: Atribut id, userId, categoryId, type ('pemasukan'/'pengeluaran'),
///               amount, title, description, recordDate, serta converter Map PostgreSQL.
/// ============================================================================

class FinancialRecordModel {
  final int? id;
  final int userId;
  final int? categoryId;
  final String type; // 'pemasukan' / 'pengeluaran'
  final double amount;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FinancialRecordModel({
    this.id,
    required this.userId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.title,
    this.description,
    required this.recordDate,
    this.createdAt,
    this.updatedAt,
  });

  factory FinancialRecordModel.fromMap(Map<String, dynamic> map) {
    return FinancialRecordModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int?,
      type: map['type'].toString(),
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : double.parse(map['amount'].toString()),
      title: map['title'] as String,
      description: map['description'] as String?,
      recordDate: map['record_date'] is DateTime 
          ? map['record_date'] 
          : DateTime.parse(map['record_date'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'title': title,
      'description': description,
      'record_date': recordDate.toIso8601String(),
    };
  }
}
