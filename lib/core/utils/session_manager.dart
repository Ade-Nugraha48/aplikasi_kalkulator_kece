// lib/core/utils/session_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';

// TODO: Implementasi FR-U-06 Session Management (1 jam idle otomatis logout)
class SessionManager {
  static final SessionManager instance = SessionManager._internal();
  SessionManager._internal();

  Timer? _idleTimer;
  VoidCallback? _onSessionTimeout;

  // Durasi idle timeout 1 jam (3600 detik)
  static const Duration timeoutDuration = Duration(hours: 1);

  void startSession({required VoidCallback onTimeout}) {
    _onSessionTimeout = onTimeout;
    resetTimer();
  }

  void resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(timeoutDuration, () {
      if (_onSessionTimeout != null) {
        _onSessionTimeout!();
      }
    });
  }

  void stopSession() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _onSessionTimeout = null;
  }
}
