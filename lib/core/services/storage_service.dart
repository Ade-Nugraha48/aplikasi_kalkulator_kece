/// ============================================================================
/// FILE: lib/core/services/storage_service.dart
/// FUNGSI: Mengelola proses upload foto ke Supabase Storage (Bucket 'avatars')
///         serta pembaruan avatar_url di tabel users.
/// MANAJEMEN HANDLES: Upload file, validasi tipe & ukuran, cleanup file lama.
/// ============================================================================

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String bucketName = 'avatars';
  static const int maxFileSizeInBytes = 2 * 1024 * 1024; // 2 MB

  /// Mengunggah avatar, menghapus yang lama jika ada, lalu meng-update tabel users.
  Future<String?> uploadAvatar({
    required int userId,
    required Uint8List fileBytes,
    required String fileName,
    required String oldAvatarUrl,
  }) async {
    try {
      // 1. Validasi Ukuran File (Maksimal 2 MB)
      if (fileBytes.lengthInBytes > maxFileSizeInBytes) {
        throw Exception("Ukuran gambar terlalu besar (Maksimal 2 MB)");
      }

      // 2. Validasi Ekstensi/MIME type sederhana
      final String path = fileName.toLowerCase();
      if (!path.endsWith('.jpg') &&
          !path.endsWith('.jpeg') &&
          !path.endsWith('.png') &&
          !path.endsWith('.webp')) {
        throw Exception("Format file tidak didukung (Hanya JPG, PNG, WEBP)");
      }

      // 3. Hapus foto lama di bucket (jika ada) untuk menghemat storage
      if (oldAvatarUrl.isNotEmpty) {
        try {
          // Asumsi oldAvatarUrl adalah public url: 
          // https://[project_id].supabase.co/storage/v1/object/public/avatars/user_1_12345.jpg
          // Kita butuh mengambil relative path-nya saja, yakni nama file-nya.
          final uri = Uri.parse(oldAvatarUrl);
          final pathSegments = uri.pathSegments;
          // Segment format: [storage, v1, object, public, avatars, nama_file.jpg]
          final index = pathSegments.indexOf(bucketName);
          if (index != -1 && index + 1 < pathSegments.length) {
            final fileObj = pathSegments.skip(index + 1).join('/');
            if (fileObj.isNotEmpty) {
              await _client.storage.from(bucketName).remove([fileObj]);
            }
          }
        } catch (e) {
          debugPrint("Gagal menghapus avatar lama (mungkin sudah hilang): $e");
        }
      }

      // 4. Unggah foto baru dengan penamaan unik
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = path.split('.').last;
      final newFileName = 'user_${userId}_$timestamp.$ext';

      await _client.storage.from(bucketName).uploadBinary(
            newFileName,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // 5. Dapatkan Public URL
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(newFileName);

      // 6. Update tabel 'users' kolom 'avatar_url'
      await _client
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      return publicUrl;
    } catch (e) {
      debugPrint("StorageService error: $e");
      rethrow;
    }
  }
}
