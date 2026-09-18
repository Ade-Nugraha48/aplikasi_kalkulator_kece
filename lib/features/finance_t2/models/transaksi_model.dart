// lib/features/finance_t2/models/transaksi_model.dart

// TODO: Implementasi FR-T2 Model Transaksi KosKu
enum TipeTransaksi { pemasukan, pengeluaran }

class TransaksiModel {
  final String id;
  final String judul;
  final double jumlah;
  final TipeTransaksi tipe;
  final DateTime tanggal;
  final String kategori;

  TransaksiModel({
    required this.id,
    required this.judul,
    required this.jumlah,
    required this.tipe,
    required this.tanggal,
    this.kategori = 'Umum',
  });
}
