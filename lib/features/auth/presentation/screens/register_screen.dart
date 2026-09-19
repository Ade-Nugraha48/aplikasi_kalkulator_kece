// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';

/// Screen Registrasi User Baru (FR-U-02)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi User Baru'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Form Registrasi User Baru (FR-U-02)\n'
              'Merekam Username, Password, Email, dan Tanggal Lahir ke Supabase DB.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
