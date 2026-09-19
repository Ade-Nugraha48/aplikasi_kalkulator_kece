/// ============================================================================
/// FILE: lib/features/kosku/services/kosku_service.dart
/// FUNGSI: Service pengolahan CRUD data transaksi keuangan & kategori via Supabase Client.
/// MANAJEMEN HANDLES: FR-T2-01 (Summary Dashboard), FR-T2-02 (Input/Create),
///                    FR-T2-03 (Delete), & FR-T2-04 (Update)
/// LOKASI LOGIC: Supabase direct query (`financial_records` & `categories`).
/// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/financial_record_model.dart';
import '../models/category_model.dart';

class KoskuService {

  /// Handles FR-T2-01: Mengambil ringkasan total pemasukan, total pengeluaran, & saldo
  Future<Map<String, double>> getFinancialSummary(int userId) async {
    try {
      final response = await Supabase.instance.client
          .from('financial_records')
          .select('type, amount')
          .eq('user_id', userId);

      double totalPemasukan = 0.0;
      double totalPengeluaran = 0.0;

      for (var row in response) {
        final type = row['type'].toString();
        final amount = (row['amount'] is num)
            ? (row['amount'] as num).toDouble()
            : double.tryParse(row['amount'].toString()) ?? 0.0;

        if (type == 'pemasukan') {
          totalPemasukan += amount;
        } else if (type == 'pengeluaran') {
          totalPengeluaran += amount;
        }
      }

      return {
        'total_pemasukan': totalPemasukan,
        'total_pengeluaran': totalPengeluaran,
        'saldo': totalPemasukan - totalPengeluaran,
      };
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase getFinancialSummary error: $e');
      }
    }

    return {
      'total_pemasukan': 0.0,
      'total_pengeluaran': 0.0,
      'saldo': 0.0,
    };
  }

  /// Handles FR-T2-01: Mengambil daftar seluruh transaksi keuangan user
  Future<List<FinancialRecordModel>> getRecords(int userId) async {
    try {
      final response = await Supabase.instance.client
          .from('financial_records')
          .select()
          .eq('user_id', userId)
          .order('record_date', ascending: false);

      return response
          .map((item) => FinancialRecordModel.fromMap(item))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase getRecords error: $e');
      }
    }
    return [];
  }

  /// Handles FR-T2-02: Menambah transaksi baru ke database Supabase
  Future<bool> createRecord(FinancialRecordModel record) async {
    try {
      final data = {
        'user_id': record.userId,
        if (record.categoryId != null) 'category_id': record.categoryId,
        'type': record.type,
        'amount': record.amount,
        'title': record.title,
        'description': record.description,
        'record_date': record.recordDate.toIso8601String(),
      };

      await Supabase.instance.client.from('financial_records').insert(data);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase createRecord error: $e');
      }
      return false;
    }
  }

  /// Handles FR-T2-04: Mengubah/memperbarui data transaksi di Supabase
  Future<bool> updateRecord(FinancialRecordModel record) async {
    if (record.id == null) return false;
    try {
      final data = {
        if (record.categoryId != null) 'category_id': record.categoryId,
        'type': record.type,
        'amount': record.amount,
        'title': record.title,
        'description': record.description,
        'record_date': record.recordDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('financial_records')
          .update(data)
          .eq('id', record.id!);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase updateRecord error: $e');
      }
      return false;
    }
  }

  /// Handles FR-T2-03: Menghapus transaksi dari database Supabase
  Future<bool> deleteRecord(int recordId) async {
    try {
      await Supabase.instance.client
          .from('financial_records')
          .delete()
          .eq('id', recordId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase deleteRecord error: $e');
      }
      return false;
    }
  }

  /// Handles FR-T2-02: Mengambil daftar kategori dinamis user dari DB Supabase
  Future<List<CategoryModel>> getCategories(int userId) async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('name', ascending: true);

      return response
          .map((item) => CategoryModel.fromMap(item))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase getCategories error: $e');
      }
    }
    return [];
  }

  /// Handles FR-T2-02: Menambah kategori dinamis baru ke DB Supabase
  Future<bool> createCategory(CategoryModel category) async {
    try {
      await Supabase.instance.client.from('categories').insert({
        'user_id': category.userId,
        'name': category.name,
        'type': category.type,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase createCategory error: $e');
      }
      return false;
    }
  }
}
