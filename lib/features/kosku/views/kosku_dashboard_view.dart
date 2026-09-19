/// ============================================================================
/// FILE: lib/features/kosku/views/kosku_dashboard_view.dart
/// FUNGSI: Tampilan Dashboard Keuangan Anak Kos "KosKu".
/// MANAJEMEN HANDLES: FR-T2-01 (Ringkasan Pemasukan/Pengeluaran DB) & FR-T2-03 (Hapus Transaksi DB)
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/kosku_service.dart';
import '../models/financial_record_model.dart';
import '../../../core/session/session_manager.dart';
import 'kosku_form_view.dart';

class KoskuDashboardView extends StatefulWidget {
  const KoskuDashboardView({super.key});

  @override
  State<KoskuDashboardView> createState() => _KoskuDashboardViewState();
}

class _KoskuDashboardViewState extends State<KoskuDashboardView> {
  final KoskuService _koskuService = KoskuService();
  
  bool _isLoading = true;
  double _totalPemasukan = 0.0;
  double _totalPengeluaran = 0.0;
  double _saldo = 0.0;
  
  List<FinancialRecordModel> _records = [];
  Map<int, String> _categoryMap = {}; // mapping id -> name
  
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() {
    final user = SessionManager().currentUser;
    if (user != null && user['id'] != null) {
      _userId = user['id'] as int;
      _loadData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    
    final summary = await _koskuService.getFinancialSummary(_userId!);
    final records = await _koskuService.getRecords(_userId!);
    final categories = await _koskuService.getCategories(_userId!);
    
    Map<int, String> catMap = {};
    for (var cat in categories) {
      if (cat.id != null) {
        catMap[cat.id!] = cat.name;
      }
    }

    setState(() {
      _totalPemasukan = summary['total_pemasukan'] ?? 0.0;
      _totalPengeluaran = summary['total_pengeluaran'] ?? 0.0;
      _saldo = summary['saldo'] ?? 0.0;
      _records = records;
      _categoryMap = catMap;
      _isLoading = false;
    });
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  void _hapusCatatan(FinancialRecordModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Anda yakin ingin menghapus catatan "${record.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (record.id != null) {
                final success = await _koskuService.deleteRecord(record.id!);
                if (success) {
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catatan berhasil dihapus')),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal menghapus catatan. Periksa koneksi internet Anda.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('KosKu - Catatan Keuangan')),
        body: const Center(child: Text('Harap Login terlebih dahulu.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KosKu - Catatan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 88.0),
                child: Column(
                  children: [
                    // Ringkasan
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text('Sisa Saldo', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(_saldo), 
                              style: TextStyle(
                                fontSize: 28, 
                                fontWeight: FontWeight.bold,
                                color: _saldo < 0 ? Colors.red : Colors.blue.shade700
                              )
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Pemasukan', style: TextStyle(color: Colors.green)),
                                    Text(_formatCurrency(_totalPemasukan), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Pengeluaran', style: TextStyle(color: Colors.red)),
                                    Text(_formatCurrency(_totalPengeluaran), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Riwayat Catatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    
                    if (_records.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada catatan keuangan.\nYuk, catat pengeluaran nasi bungkus pertamamu!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          final isPemasukan = record.type == 'pemasukan';
                          final categoryName = record.categoryId != null 
                              ? _categoryMap[record.categoryId!] ?? 'Tanpa Kategori'
                              : 'Tanpa Kategori';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isPemasukan ? Colors.green.shade100 : Colors.red.shade100,
                                child: Icon(
                                  isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isPemasukan ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('$categoryName • ${_formatDate(record.recordDate)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatCurrency(record.amount),
                                    style: TextStyle(
                                      color: isPemasukan ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => KoskuFormView(recordToEdit: record)),
                                        ).then((_) => _loadData());
                                      } else if (value == 'hapus') {
                                        _hapusCatatan(record);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(value: 'hapus', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KoskuFormView()),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
    );
  }
}

