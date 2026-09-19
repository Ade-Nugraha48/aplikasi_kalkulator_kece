/// ============================================================================
/// FILE: lib/features/auth/views/register_view.dart
/// FUNGSI: Tampilan Halaman Registrasi Pengguna Baru.
/// MANAJEMEN HANDLES: FR-U-02 (Tampilan & Form Registrasi User ke PostgreSQL)
/// LOKASI LOGIC: Input Username, Email, Password, DatePicker Tanggal Lahir,
///               validasi form, dan pemanggilan AuthService.register().
/// ============================================================================

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/utils/date_formatter.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  DateTime _selectedBirthDate = DateTime(2002, 1, 1);
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _pilihTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _prosesRegistrasi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newUser = UserModel(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text.trim(),
      birthDate: _selectedBirthDate,
    );

    final result = await _authService.register(newUser);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Registrasi berhasil! Silakan login.'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Kembali ke LoginScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(result.errorMessage ?? 'Gagal mendaftar.')),
            ],
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Akun Baru'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.person_add, size: 54, color: Color(0xFF6C5CE7)),
                      const SizedBox(height: 12),
                      const Text(
                        'Buat Akun Baru',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Daftar akun untuk menyimpan transaksi KosKu & data di PostgreSQL',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Username wajib diisi.';
                          if (val.trim().length < 3) return 'Username minimal 3 karakter.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email wajib diisi.';
                          if (!val.contains('@')) return 'Format email tidak valid.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password wajib diisi.';
                          if (val.length < 6) return 'Password minimal 6 karakter.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pilihTanggalLahir,
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Lahir',
                            prefixIcon: Icon(Icons.cake),
                          ),
                          child: Text(
                            DateFormatter.formatDateIndonesia(_selectedBirthDate),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _prosesRegistrasi,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('DAFTAR AKUN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
