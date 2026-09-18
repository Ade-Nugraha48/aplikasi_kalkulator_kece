// lib/features/utilities/screens/anggota_screen.dart
import 'package:flutter/material.dart';
import '../../../core/utils/database_helper.dart';

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({super.key});

  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  List<Map<String, dynamic>> _anggotaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatDaftarAnggota();
  }

  Future<void> _muatDaftarAnggota() async {
    final list = await DatabaseHelper.instance.getMembers();
    if (!mounted) return;
    setState(() {
      _anggotaList = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Anggota Kelompok'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Tim Pengembang Aplikasi',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Praktikum Pemrograman Mobile - FR-U-03',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _anggotaList.length,
                        itemBuilder: (context, index) {
                          final item = _anggotaList[index];
                          final nama = item['name'] ?? item['nama'] ?? 'Anggota';
                          final nim = item['nim'] ?? '-';
                          final peranan = item['peranan'] ?? 'Anggota Kelompok';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            elevation: 3,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                nama.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text('NIM: $nim • $peranan'),
                              trailing: const Icon(Icons.badge_outlined, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
