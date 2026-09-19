/// ============================================================================
/// FILE: lib/features/auth/views/login_view.dart
/// FUNGSI: Tampilan Halaman Login Pengguna & Tool Diagnosa/Setting Database Supabase.
/// MANAJEMEN HANDLES: FR-U-01 (Tampilan & Form Login Pengguna)
/// LOKASI LOGIC: Input Username & Password, validasi Kredensial Supabase,
///               penyimpanan Session (FR-U-06), & Dialog Setting/Tes Koneksi Database.
/// ============================================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../core/database/supabase_config.dart';
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
    await SupabaseConfig.loadConfig();

    final supabaseUrlCtrl = TextEditingController(text: SupabaseConfig.url);
    final supabaseAnonKeyCtrl = TextEditingController(text: SupabaseConfig.anonKey);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        bool testingSupabase = false;
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
                        const Icon(Icons.cloud_sync, color: Color(0xFF6C5CE7), size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pengaturan Koneksi Database',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kelola Kredensial Supabase Cloud Anda.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 1: SUPABASE CLOUD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: Color(0xFF6C5CE7)),
                              const SizedBox(width: 8),
                              const Text(
                                'ONLINE SUPABASE CLOUD (Cloud Database)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6C5CE7)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: supabaseUrlCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SUPABASE URL',
                              hintText: 'https://xyz.supabase.co',
                              prefixIcon: Icon(Icons.link),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: supabaseAnonKeyCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SUPABASE ANON KEY (Public Key)',
                              hintText: 'eyJhbGciOi...',
                              prefixIcon: Icon(Icons.key),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5CE7),
                                foregroundColor: Colors.white,
                              ),
                              icon: testingSupabase
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.cloud_done),
                              label: Text(testingSupabase ? 'Menguji Supabase...' : 'TES & SIMPAN KONEKSI SUPABASE'),
                              onPressed: testingSupabase
                                  ? null
                                  : () async {
                                      setModalState(() {
                                        testingSupabase = true;
                                        testMessage = null;
                                      });

                                      try {
                                        final ok = await SupabaseConfig.testConnection(
                                          testUrl: supabaseUrlCtrl.text,
                                          testAnonKey: supabaseAnonKeyCtrl.text,
                                        );
                                        await SupabaseConfig.saveConfig(
                                          url: supabaseUrlCtrl.text,
                                          anonKey: supabaseAnonKeyCtrl.text,
                                        );

                                        setModalState(() {
                                          testingSupabase = false;
                                          testSuccess = ok;
                                          testMessage = '✅ KONEKSI SUPABASE BERHASIL! Cloud Database terhubung.';
                                        });
                                      } catch (e) {
                                        setModalState(() {
                                          testingSupabase = false;
                                          testSuccess = false;
                                          testMessage = '❌ GAGAL KONEKSI SUPABASE: $e';
                                        });
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
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
            tooltip: 'Pengaturan Koneksi Supabase & Database',
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
                        'Silakan masuk dengan akun Anda (Supabase Cloud DB)',
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
