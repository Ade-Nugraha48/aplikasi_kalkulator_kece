/// ============================================================================
/// FILE: lib/core/session/session_listener.dart
/// FUNGSI: Wrapper Widget untuk mendeteksi interaksi/gestur user di seluruh aplikasi.
/// MANAJEMEN HANDLES: FR-U-06 (Session Management Inactivity Reset)
/// LOKASI LOGIC: Membungkus MaterialApp atau Screen utama dengan Listener/GestureDetector
///               agar setiap sentuhan/klikan otomatis mereset timer session 1 jam.
/// ============================================================================

import 'package:flutter/material.dart';
import 'session_manager.dart';

class SessionListener extends StatelessWidget {
  final Widget child;

  const SessionListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        // Reset timer inaktivitas session setiap kali layar disentuh
        SessionManager().resetInactivityTimer();
      },
      child: child,
    );
  }
}
