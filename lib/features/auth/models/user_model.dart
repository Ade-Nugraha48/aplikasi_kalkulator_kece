/// ============================================================================
/// FILE: lib/features/auth/models/user_model.dart
/// FUNGSI: Model data representasi tabel `users` PostgreSQL.
/// MANAJEMEN HANDLES: Data Model untuk FR-U-01 & FR-U-02
/// LOKASI LOGIC: Definisi atribut user (id, username, email, birthDate, password),
///               serta method toMap() dan fromMap() untuk query PostgreSQL.
/// ============================================================================

class UserModel {
  final int? id;
  final String username;
  final String password;
  final String email;
  final DateTime birthDate;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.birthDate,
    this.createdAt,
  });

  /// Mengubah Map dari hasil query PostgreSQL ke objek UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      email: map['email'] as String,
      birthDate: map['birth_date'] is DateTime 
          ? map['birth_date'] 
          : DateTime.parse(map['birth_date'].toString()),
      createdAt: map['created_at'] != null 
          ? (map['created_at'] is DateTime ? map['created_at'] : DateTime.parse(map['created_at'].toString()))
          : null,
    );
  }

  /// Mengubah objek UserModel ke Map untuk query PostgreSQL INSERT/UPDATE
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'birth_date': birthDate.toIso8601String(),
    };
  }
}
