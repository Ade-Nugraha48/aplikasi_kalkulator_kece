/// ============================================================================
/// FILE: lib/features/kosku/views/kosku_form_view.dart
/// FUNGSI: Tampilan Form Tambah & Edit Transaksi Keuangan KosKu.
/// MANAJEMEN HANDLES: FR-T2-02 (Input Transaksi & Kategori Dinamis DB) & FR-T2-04 (Update Transaksi DB)
/// LOKASI LOGIC: Tempat penulisan Form Input (Judul, Nominal, Tipe: Pemasukan/Pengeluaran,
///               Dropdown Kategori Dinamis dari DB, Tanggal Transaksi, Deskripsi).
/// ============================================================================

import 'package:flutter/material.dart';
import '../models/financial_record_model.dart';

class KoskuFormView extends StatefulWidget {
  final FinancialRecordModel? recordToEdit;

  const KoskuFormView({super.key, this.recordToEdit});

  @override
  State<KoskuFormView> createState() => _KoskuFormViewState();
}

class _KoskuFormViewState extends State<KoskuFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'pengeluaran'; // Default 'pemasukan' / 'pengeluaran'

  void _simpanTransaksi() {
    // TODO: Handles FR-T2-02 (Create) & FR-T2-04 (Update) transaksi ke DB PostgreSQL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordToEdit == null ? 'Tambah Transaksi' : 'Edit Transaksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TODO: SegmentedButton / Radio Tipe (Pemasukan / Pengeluaran)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Transaksi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              ),
              const SizedBox(height: 16),
              // TODO: Dropdown Kategori Dinamis dari PostgreSQL `categories` table
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpanTransaksi,
                child: const Text('Simpan Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
