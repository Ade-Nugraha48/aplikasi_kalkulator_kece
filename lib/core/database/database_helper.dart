/// ============================================================================
/// FILE: lib/core/database/database_helper.dart
/// FUNGSI: Mengelola koneksi & eksekusi query PostgreSQL database dengan Diagnostic Logger.
/// MANAJEMEN HANDLES: Infrastruktur Database & Persistence Layer (PostgreSQL v3)
/// LOKASI LOGIC: Tempat penulisan method connection pool, query execution,
///               serta logger diagnostik koneksi PostgreSQL lokal & Web Browser restriction handling.
/// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
import 'database_config.dart';
import 'database_tables.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Connection? _connection;
  bool _isConnected = false;
  String? _lastErrorDetail;

  bool get isConnected => _isConnected;
  String? get lastErrorDetail => _lastErrorDetail;

  /// Inisialisasi koneksi ke server database PostgreSQL lokal & eksekusi DDL schema & seed data
  Future<bool> initDatabase() async {
    // ⚠️ RESTRIKSI CHROME / WEB BROWSER:
    // Web Browser (Chrome) berjalan dalam sandbox dan tidak mendukung koneksi raw TCP Socket PostgreSQL port 5432.
    if (kIsWeb) {
      _isConnected = false;
      _lastErrorDetail = 'WEB_BROWSER_RESTRICTION: Web Browser (Chrome) tidak mendukung TCP Socket PostgreSQL secara langsung (batasan keamanan browser). Harap jalankan aplikasi di "Windows Desktop" (flutter run -d windows) atau "Android Emulator" (flutter run -d android).';
      if (kDebugMode) {
        print('⚠️ $_lastErrorDetail');
      }
      return false;
    }

    try {
      // Load saved config (Host, Port, DB, User, Password)
      await DatabaseConfig.loadConfig();

      // Tutup koneksi lama jika ada
      if (_connection != null) {
        try {
          await _connection!.close();
        } catch (_) {}
          _connection = null;
      }

      final endpoint = Endpoint(
        host: DatabaseConfig.host,
        port: DatabaseConfig.port,
        database: DatabaseConfig.databaseName,
        username: DatabaseConfig.username,
        password: DatabaseConfig.password,
      );

      _connection = await Connection.open(
        endpoint,
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 4),
        ),
      );

      _isConnected = true;
      _lastErrorDetail = null;
      if (kDebugMode) {
        print('✅ [POSTGRES] Koneksi Berhasil ke ${DatabaseConfig.host}:${DatabaseConfig.port}/${DatabaseConfig.databaseName}');
      }

      // Inisialisasi DDL Schema & Seed Data
      await _setupTablesAndSeed();
      return true;
    } catch (e) {
      _isConnected = false;
      _lastErrorDetail = _parseErrorDetail(e);
      if (kDebugMode) {
        print('❌ [POSTGRES ERROR] Gagal terhubung ke (${DatabaseConfig.host}:${DatabaseConfig.port}):');
        print('   Pesan Error: $e');
        print('   Diagnosa: $_lastErrorDetail');
      }
      return false;
    }
  }

  /// Diagnosa detail pesan error koneksi
  String _parseErrorDetail(Object error) {
    if (kIsWeb) {
      return 'WEB_BROWSER_RESTRICTION: Web Browser (Chrome) tidak mendukung TCP Socket PostgreSQL secara langsung. Jalankan di Windows/Android Emulator.';
    }
    final str = error.toString().toLowerCase();
    if (str.contains('connection refused') || str.contains('socketexception')) {
      return 'CONNECTION_REFUSED: PostgreSQL server tidak berjalan pada Host ${DatabaseConfig.host}:${DatabaseConfig.port}, atau listen_addresses di postgresql.conf belum "*".';
    } else if (str.contains('timeout')) {
      return 'CONNECTION_TIMEOUT: Waktu koneksi ke Host "${DatabaseConfig.host}" habis. Pastikan IP HP/Emulator satu jaringan dengan PC dan port 5432 diizinkan oleh Windows Firewall.';
    } else if (str.contains('password authentication failed') || str.contains('invalid password')) {
      return 'AUTH_FAILED: Password/Username PostgreSQL salah untuk user "${DatabaseConfig.username}".';
    } else if (str.contains('database') && str.contains('does not exist')) {
      return 'DB_NOT_FOUND: Database "${DatabaseConfig.databaseName}" belum ada di PostgreSQL. Buat database tersebut terlebih dahulu di pgAdmin 4.';
    }
    return 'UNKNOWN_ERROR: $error';
  }

  /// Running Diagnosa Lengkap Status Koneksi untuk Tampilan UI Debugging
  Future<Map<String, dynamic>> runConnectionDiagnostic() async {
    final success = await initDatabase();
    return {
      'success': success,
      'host': DatabaseConfig.host,
      'port': DatabaseConfig.port,
      'database': DatabaseConfig.databaseName,
      'username': DatabaseConfig.username,
      'password': DatabaseConfig.password,
      'errorDetail': _lastErrorDetail ?? (success ? 'Terhubung sempurna ke PostgreSQL!' : 'Gagal terhubung'),
    };
  }

  /// Memastikan koneksi aktif sebelum eksekusi query
  Future<Connection?> _ensureConnected() async {
    if (_connection == null || !_isConnected) {
      await initDatabase();
    }
    return _connection;
  }

  /// Eksekusi DDL Schema & Seed Data Awal
  Future<void> _setupTablesAndSeed() async {
    try {
      final conn = await _ensureConnected();
      if (conn == null) return;

      // 1. DDL Schema Tables
      await conn.execute(DatabaseTables.createSchemaSql);

      // 2. DML Seed Data Awal
      await conn.execute(DatabaseTables.seedInitialDataSql);

      if (kDebugMode) {
        print('✅ [POSTGRES] DDL Schema & Seed Data PostgreSQL berhasil dieksekusi.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [POSTGRES] Gagal mengeksekusi DDL/Seed SQL: $e');
      }
    }
  }

  /// Menjalankan query SELECT dan mengembalikan hasil dalam bentuk List of Map
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    try {
      final conn = await _ensureConnected();
      if (conn == null) return [];

      late Result result;
      if (substitutionValues != null && substitutionValues.isNotEmpty) {
        result = await conn.execute(
          Sql.named(sql),
          parameters: substitutionValues,
        );
      } else {
        result = await conn.execute(sql);
      }

      final List<Map<String, dynamic>> rows = [];
      for (final row in result) {
        final Map<String, dynamic> rowMap = {};
        for (int i = 0; i < result.schema.columns.length; i++) {
          final colName = result.schema.columns[i].columnName ?? 'col_$i';
          rowMap[colName] = row[i];
        }
        rows.add(rowMap);
      }
      return rows;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Query Error ($sql): $e');
      }
      return [];
    }
  }

  /// Menjalankan SQL Command (INSERT, UPDATE, DELETE) dan mengembalikan jumlah baris terpengaruh
  Future<int> execute(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    try {
      final conn = await _ensureConnected();
      if (conn == null) return 0;

      late Result result;
      if (substitutionValues != null && substitutionValues.isNotEmpty) {
        result = await conn.execute(
          Sql.named(sql),
          parameters: substitutionValues,
        );
      } else {
        result = await conn.execute(sql);
      }

      return result.affectedRows;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Execute SQL Error ($sql): $e');
      }
      return 0;
    }
  }

  /// Menutup koneksi database PostgreSQL
  Future<void> close() async {
    try {
      await _connection?.close();
      _connection = null;
      _isConnected = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error closing PostgreSQL connection: $e');
      }
    }
  }
}
