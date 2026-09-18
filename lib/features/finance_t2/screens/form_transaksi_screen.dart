// lib/features/finance_t2/screens/form_transaksi_screen.dart
import 'package:flutter/material.dart';
import '../models/transaksi_model.dart';

// TODO: Implementasi FR-T2-02 Input (Create) & FR-T2-04 Update Pemasukan/Pengeluaran
class FormTransaksiScreen extends StatefulWidget {
  final TransaksiModel? transaksiEdit;

  const FormTransaksiScreen({super.key, this.transaksiEdit});

  @override
  State<FormTransaksiScreen> createState() => _FormTransaksiScreenState();
}

class _FormTransaksiScreenState extends State<FormTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _kategoriCtrl = TextEditingController();
  TipeTransaksi _tipePilihan = TipeTransaksi.pengeluaran;

  @override
  void initState() {
    super.initState();
    if (widget.transaksiEdit != null) {
      _judulCtrl.text = widget.transaksiEdit!.judul;
      _jumlahCtrl.text = widget.transaksiEdit!.jumlah.toString();
      _kategoriCtrl.text = widget.transaksiEdit!.kategori;
      _tipePilihan = widget.transaksiEdit!.tipe;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _jumlahCtrl.dispose();
    _kategoriCtrl.dispose();
    super.dispose();
  }

  void _simpanTransaksi() {
    if (_formKey.currentState?.validate() ?? false) {
      final model = TransaksiModel(
        id: widget.transaksiEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        judul: _judulCtrl.text.trim(),
        jumlah: double.parse(_jumlahCtrl.text.trim()),
        tipe: _tipePilihan,
        tanggal: DateTime.now(),
        kategori: _kategoriCtrl.text.trim().isEmpty ? 'Umum' : _kategoriCtrl.text.trim(),
      );
      // TODO: Simpan atau Update ke database SQLite/DatabaseHelper
      Navigator.pop(context, model);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.transaksiEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaksi KosKu' : 'Tambah Transaksi KosKu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<TipeTransaksi>(
                    segments: const [
                      ButtonSegment(
                        value: TipeTransaksi.pemasukan,
                        label: Text('Pemasukan'),
                        icon: Icon(Icons.arrow_downward, color: Colors.green),
                      ),
                      ButtonSegment(
                        value: TipeTransaksi.pengeluaran,
                        label: Text('Pengeluaran'),
                        icon: Icon(Icons.arrow_upward, color: Colors.red),
                      ),
                    ],
                    selected: {_tipePilihan},
                    onSelectionChanged: (Set<TipeTransaksi> newSelection) {
                      setState(() {
                        _tipePilihan = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _judulCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Judul Transaksi',
                      hintText: 'Contoh: Sewa Kos / Beli Makan',
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    validator: (val) => (val == null || val.isEmpty) ? 'Judul transaksi wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jumlahCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      hintText: 'Contoh: 50000',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Jumlah nominal wajib diisi';
                      if (double.tryParse(val) == null) return 'Nominal harus berupa angka valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kategoriCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      hintText: 'Contoh: Makan / Sewa / Utilitas',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _simpanTransaksi,
                    icon: const Icon(Icons.save),
                    label: Text(isEdit ? 'UPDATE TRANSAKSI' : 'SIMPAN TRANSAKSI'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
