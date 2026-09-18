// lib/features/finance_t2/screens/dashboard_kosku_screen.dart
import 'package:flutter/material.dart';
import '../../../core/utils/database_helper.dart';
import '../models/transaksi_model.dart';
import 'form_transaksi_screen.dart';

class DashboardKoskuScreen extends StatefulWidget {
  const DashboardKoskuScreen({super.key});

  @override
  State<DashboardKoskuScreen> createState() => _DashboardKoskuScreenState();
}

class _DashboardKoskuScreenState extends State<DashboardKoskuScreen> {
  List<TransaksiModel> _daftarTransaksi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatDataTransaksi();
  }

  Future<void> _muatDataTransaksi() async {
    setState(() => _isLoading = true);
    final rawData = await DatabaseHelper.instance.getTransactions();

    final List<TransaksiModel> loaded = rawData.map((item) {
      final tipeStr = item['tipe'].toString();
      final isIncome = tipeStr == 'pemasukan';
      return TransaksiModel(
        id: item['id'].toString(),
        judul: item['judul'].toString(),
        jumlah: (item['jumlah'] as num).toDouble(),
        tipe: isIncome ? TipeTransaksi.pemasukan : TipeTransaksi.pengeluaran,
        tanggal: item['tanggal'] is DateTime ? item['tanggal'] as DateTime : DateTime.parse(item['tanggal'].toString()),
        kategori: item['kategori'].toString(),
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      _daftarTransaksi = loaded;
      _isLoading = false;
    });
  }

  double get _totalPemasukan {
    return _daftarTransaksi
        .where((t) => t.tipe == TipeTransaksi.pemasukan)
        .fold(0, (sum, item) => sum + item.jumlah);
  }

  double get _totalPengeluaran {
    return _daftarTransaksi
        .where((t) => t.tipe == TipeTransaksi.pengeluaran)
        .fold(0, (sum, item) => sum + item.jumlah);
  }

  double get _saldoAkhir => _totalPemasukan - _totalPengeluaran;

  Future<void> _hapusTransaksi(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await _muatDataTransaksi();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil dihapus.')),
    );
  }

  void _bukaFormTambah() async {
    final result = await Navigator.push<TransaksiModel>(
      context,
      MaterialPageRoute(builder: (context) => const FormTransaksiScreen()),
    );
    if (result != null) {
      await DatabaseHelper.instance.addTransaction(
        judul: result.judul,
        jumlah: result.jumlah,
        tipe: result.tipe == TipeTransaksi.pemasukan ? 'pemasukan' : 'pengeluaran',
        kategori: result.kategori,
        tanggal: result.tanggal,
      );
      await _muatDataTransaksi();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard KosKu'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormTambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Saldo Ringkasan
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: theme.colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Saldo KosKu',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rp ${_saldoAkhir.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.white24,
                                      child: Icon(Icons.arrow_downward, color: Colors.greenAccent),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Pemasukan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        Text(
                                          'Rp ${_totalPemasukan.toStringAsFixed(0)}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.white24,
                                      child: Icon(Icons.arrow_upward, color: Colors.redAccent),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        Text(
                                          'Rp ${_totalPengeluaran.toStringAsFixed(0)}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Riwayat Transaksi',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_daftarTransaksi.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Belum ada transaksi kos.'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _daftarTransaksi.length,
                      itemBuilder: (context, index) {
                        final item = _daftarTransaksi[index];
                        final isIncome = item.tipe == TipeTransaksi.pemasukan;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                              child: Icon(
                                isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${item.kategori} • ${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'} Rp ${item.jumlah.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                  onPressed: () => _hapusTransaksi(item.id),
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
    );
  }
}
