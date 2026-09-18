// lib/features/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import '../../../core/utils/database_helper.dart';
import '../../../core/utils/session_manager.dart';

// TODO: Implementasi FR-U-01, FR-U-02, FR-U-05, FR-U-06 Logika Autentikasi
class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    // TODO: FR-U-01 Login dengan database
    bool success = await DatabaseHelper.instance.validateUser(username, password);
    if (success) {
      _isLoggedIn = true;
      _currentUser = username;
      notifyListeners();
    }
    return success;
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String tanggalLahir,
  }) async {
    // TODO: FR-U-02 Registrasi User
    return await DatabaseHelper.instance.registerUser(
      username: username,
      password: password,
      email: email,
      tanggalLahir: tanggalLahir,
    );
  }

  void logout() {
    // TODO: FR-U-05 Logout
    _isLoggedIn = false;
    _currentUser = null;
    SessionManager.instance.stopSession();
    notifyListeners();
  }
}
