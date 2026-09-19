/// ============================================================================
/// FILE: lib/features/kosku/views/kosku_form_view.dart
/// FUNGSI: Tampilan Form Tambah & Edit Catatan Keuangan KosKu.
/// MANAJEMEN HANDLES: FR-T2-02 & Validasi Input Standar Industri
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../models/financial_record_model.dart';
import '../models/category_model.dart';
import '../services/kosku_service.dart';
import '../../../core/session/session_manager.dart';

class KoskuFormView extends StatefulWidget {
  final FinancialRecordModel? recordToEdit;

  const KoskuFormView({super.key, this.recordToEdit});

  @override
  State<KoskuFormView> createState() => _KoskuFormViewState();
}

class _KoskuFormViewState extends State<KoskuFormView> {
  final KoskuService _koskuService = KoskuService();
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'pengeluaran'; // Default
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;
  
  bool _isLoading = false;
  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];
  
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
      _loadCategories();
      
      if (widget.recordToEdit != null) {
        final rec = widget.recordToEdit!;
        _titleController.text = rec.title;
        _amountController.text = rec.amount.toInt().toString();
        _descriptionController.text = rec.description ?? '';
        _selectedType = rec.type;
        _selectedDate = rec.recordDate;
        _selectedCategoryId = rec.categoryId;
      }
    }
  }

  Future<void> _loadCategories() async {
    if (_userId == null) return;
    
    final cats = await _koskuService.getCategories(_userId!);
    setState(() {
      _allCategories = cats;
      _filterCategories();
    });
  }

  void _filterCategories() {
    _filteredCategories = _allCategories.where((c) => c.type == _selectedType).toList();
    if (_selectedCategoryId != null) {
      final exists = _filteredCategories.any((c) => c.id == _selectedCategoryId);
      if (!exists) _selectedCategoryId = null;
    }
  }

  Future<void> _pilihTanggalWaktu() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _tambahKategoriBaru() {
    final ctrl = TextEditingController();
    String? localError;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Kategori ${_selectedType == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran'} Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    maxLength: 30,
                    decoration: InputDecoration(
                      hintText: _selectedType == 'pemasukan' ? 'Contoh: Bonus Beasiswa' : 'Contoh: Makanan & Minuman',
                      errorText: localError,
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    final name = ctrl.text.trim();
                    if (name.isEmpty) {
                      setDialogState(() => localError = "Nama kategori tidak boleh kosong");
                      return;
                    }
                    if (name.length > 30) {
                      setDialogState(() => localError = "Maksimal 30 karakter");
                      return;
                    }
                    // Cek duplikasi
                    final isDuplicate = _filteredCategories.any((c) => c.name.toLowerCase() == name.toLowerCase());
                    if (isDuplicate) {
                      setDialogState(() => localError = "Kategori dengan nama tersebut sudah ada");
                      return;
                    }

                    if (_userId != null) {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      final newCat = CategoryModel(userId: _userId!, name: name, type: _selectedType);
                      final success = await _koskuService.createCategory(newCat);
                      
                      if (success) {
                        await _loadCategories();
                        final justAdded = _filteredCategories.where((c) => c.name.toLowerCase() == name.toLowerCase()).toList();
                        if (justAdded.isNotEmpty) {
                          setState(() => _selectedCategoryId = justAdded.last.id);
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat kategori')));
                        }
                      }
                      setState(() => _isLoading = false);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _simpanCatatan() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih atau buat kategori terlebih dahulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_userId == null) return;
    
    setState(() => _isLoading = true);
    
    final record = FinancialRecordModel(
      id: widget.recordToEdit?.id,
      userId: _userId!,
      categoryId: _selectedCategoryId,
      type: _selectedType,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      recordDate: _selectedDate,
    );

    bool success;
    if (widget.recordToEdit == null) {
      success = await _koskuService.createRecord(record);
    } else {
      success = await _koskuService.updateRecord(record);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan catatan. Periksa koneksi internet Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('KosKu')),
        body: const Center(child: Text('Harap Login terlebih dahulu.')),
      );
    }

    final titlePlaceholder = _selectedType == 'pemasukan'
        ? 'Contoh: Kiriman Ortu Bulan Ini'
        : 'Contoh: Beli Nasi Goreng Pak Ali';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordToEdit == null ? 'Tambah Catatan' : 'Edit Catatan'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Button Tipe
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'pemasukan', label: Text('Pemasukan')),
                  ButtonSegment(value: 'pengeluaran', label: Text('Pengeluaran')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _filterCategories();
                  });
                },
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _titleController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Judul Catatan', 
                  hintText: titlePlaceholder,
                  border: const OutlineInputBorder()
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Judul catatan tidak boleh kosong';
                  if (val.length > 50) return 'Judul terlalu panjang (maksimal 50 karakter)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)', 
                  hintText: 'Cth: 15000',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nominal wajib diisi';
                  final numVal = double.tryParse(val);
                  if (numVal == null || numVal <= 0) return 'Nominal harus lebih besar dari Rp 0';
                  if (numVal > 999999999) return 'Nominal maksimal Rp 999.999.999';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      value: _selectedCategoryId,
                      hint: const Text('Pilih Kategori'),
                      items: _filteredCategories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                      validator: (val) => val == null ? 'Pilih atau buat kategori terlebih dahulu' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: IconButton.filledTonal(
                      onPressed: _tambahKategoriBaru,
                      icon: const Icon(Icons.add),
                      tooltip: 'Tambah Kategori Baru',
                      iconSize: 28,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              InkWell(
                onTap: _pilihTanggalWaktu,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Waktu Pencatatan', border: OutlineInputBorder()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy, HH:mm').format(_selectedDate)),
                      const Icon(Icons.calendar_month, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Tambahan (Opsional)', 
                  hintText: 'Contoh: Nasi goreng + es teh manis (nota ada di dompet)',
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _simpanCatatan,
                child: const Text('Simpan Catatan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

