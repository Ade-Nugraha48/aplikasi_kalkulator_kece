// lib/models/team_member.dart
// Backward compatibility model export

class TeamMember {
  final String nama;
  final String nim;
  final String peranan;

  const TeamMember({
    required this.nama,
    required this.nim,
    this.peranan = 'Anggota Kelompok',
  });
}
