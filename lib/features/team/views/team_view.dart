/// ============================================================================
/// FILE: lib/features/team/views/team_view.dart
/// FUNGSI: Tampilan Daftar Anggota Kelompok.
/// MANAJEMEN HANDLES: FR-U-03 (UI Anggota Kelompok dari Supabase)
/// LOKASI LOGIC: Tempat penulisan FutureBuilder untuk menampilkan data dari TeamService.fetchMembers().
/// ============================================================================

import 'package:flutter/material.dart';
import '../models/team_member_model.dart';
import '../services/team_service.dart';

class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class ViewDataKelompok extends StatelessWidget {
  const ViewDataKelompok({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamView();
  }
}

class _TeamViewState extends State<TeamView> {
  final TeamService _teamService = TeamService();
  late Future<List<AnggotaKelompok>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _teamService.fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Kelompok'),
      ),
      body: FutureBuilder<List<AnggotaKelompok>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final members = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(member.name),
                  subtitle: Text('NIM: ${member.nim}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
