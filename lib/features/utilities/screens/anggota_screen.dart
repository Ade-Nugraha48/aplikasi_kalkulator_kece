// lib/features/utilities/screens/anggota_screen.dart
import 'package:flutter/material.dart';

// TODO: Implementasi FR-U-03 Daftar Anggota (Nama & NIM)
class AnggotaScreen extends StatelessWidget {
  const AnggotaScreen({super.key});

  final List<Map<String, String>> _anggotaList = const [
    {
      'nama': 'Ade Nugraha',
      'nim': '2209106048',
      'peranan': 'Ketua / Developer Utama',
    },
    {
      'nama': 'Anggota Tim 1',
      'nim': '22091060XX',
      'peranan': 'Anggota Kelompok',
    },
    {
      'nama': 'Anggota Tim 2',
      'nim': '22091060YY',
      'peranan': 'Anggota Kelompok',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Anggota Kelompok'),
      ),
      body: SingleChildScrollView(
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
                          item['nama']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('NIM: ${item['nim']} • ${item['peranan']}'),
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
