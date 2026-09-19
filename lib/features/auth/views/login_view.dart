/// ============================================================================
/// FILE: lib/features/auth/views/login_view.dart
/// FUNGSI: Tampilan Halaman Login Pengguna & Tool Diagnosa/Setting Database PostgreSQL.
/// MANAJEMEN HANDLES: FR-U-01 (Tampilan & Form Login Pengguna ke PostgreSQL)
/// LOKASI LOGIC: Input Username & Password, validasi Kredensial PostgreSQL,
///               penyimpanan Session (FR-U-06), & Dialog Setting/Tes Koneksi DB.
/// ============================================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../core/database/database_config.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/session/session_manager.dart';
import '../../main_navigation/views/main_navigation_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _prosesLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final result = await _authService.login(
      username: username,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result.success && result.user != null) {
      // Handles FR-U-06: Simpan Session User
      await SessionManager().startSession(result.user!.toMap());

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(result.errorMessage ?? 'Gagal login.')),
            ],
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _bukaModalPengaturanDatabase() async {
    await DatabaseConfig.loadConfig();

    final hostCtrl = TextEditingController(text: DatabaseConfig.host);
    final portCtrl = TextEditingController(text: DatabaseConfig.port.toString());
    final dbCtrl = TextEditingController(text: DatabaseConfig.databaseName);
    final userCtrl = TextEditingController(text: DatabaseConfig.username);
    final passCtrl = TextEditingController(text: DatabaseConfig.password);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        bool testing = false;
        String? testMessage;
        bool? testSuccess;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings_input_component, color: Color(0xFF6C5CE7)),
                        const SizedBox(width: 12),
                        const Text(
                          'Pengaturan Koneksi PostgreSQL',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ubah IP Host atau Password PostgreSQL sesuai konfigurasi pgAdmin 4 di laptop Anda.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hostCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Host IP Address',
                        hintText: '10.0.2.2 (Emulator) / 127.0.0.1 / IP LAN',
                        prefixIcon: Icon(Icons.computer),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: portCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Port', prefixIcon: Icon(Icons.numbers)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: dbCtrl,
                            decoration: const InputDecoration(labelText: 'Database', prefixIcon: Icon(Icons.storage)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: userCtrl,
                      decoration: const InputDecoration(labelText: 'PostgreSQL User', prefixIcon: Icon(Icons.person_outline)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'PostgreSQL Password', prefixIcon: Icon(Icons.key)),
                    ),
                    const SizedBox(height: 16),
                    if (testMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: testSuccess == true ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: testSuccess == true ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        child: Text(
                          testMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            color: testSuccess == true ? Colors.green.shade900 : Colors.red.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: testing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.network_check),
                        label: Text(testing ? 'Menguji...' : 'TES & SIMPAN KONEKSI'),
                        onPressed: testing
                            ? null
                            : () async {
                                setModalState(() {
                                  testing = true;
                                  testMessage = null;
                                });

                                final port = int.tryParse(portCtrl.text.trim()) ?? 5432;
                                await DatabaseConfig.saveConfig(
                                  host: hostCtrl.text.trim(),
                                  port: port,
                                  dbName: dbCtrl.text.trim(),
                                  user: userCtrl.text.trim(),
                                  pass: passCtrl.text,
                                );

                                final success = await DatabaseHelper().initDatabase();

                                setModalState(() {
                                  testing = false;
                                  testSuccess = success;
                                  if (success) {
                                    testMessage = '✅ KONEKSI BERHASIL! Database "${DatabaseConfig.databaseName}" terhubung di ${DatabaseConfig.host}:${DatabaseConfig.port}';
                                  } else {
                                    testMessage = '❌ GAGAL: ${DatabaseHelper().lastErrorDetail}';
                                  }
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Aplikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Pengaturan & Tes Database PostgreSQL',
            onPressed: _bukaModalPengaturanDatabase,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_person, size: 64, color: Color(0xFF6C5CE7)),
                      const SizedBox(height: 16),
                      const Text(
                        'Selamat Datang',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Silakan masuk dengan akun PostgreSQL Anda',
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
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _prosesLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('MASUK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Belum punya akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterView()),
                              );
                            },
                            child: const Text('Daftar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
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
