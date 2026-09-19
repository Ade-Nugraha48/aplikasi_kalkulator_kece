import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/database/supabase_config.dart';
import 'core/session/session_manager.dart';
import 'core/session/session_listener.dart';
import 'features/auth/views/login_view.dart';
import 'features/main_navigation/views/main_navigation_view.dart';

export 'features/calculator/models/big_decimal.dart';
export 'features/calculator/models/calculation_result.dart';
export 'features/calculator/services/calculator_service.dart';
export 'features/auth/views/login_view.dart';
export 'features/main_navigation/views/main_navigation_view.dart';
export 'features/calculator/views/calculator_view.dart';
export 'features/odd_even/views/odd_even_view.dart';
export 'features/statistics/views/statistics_view.dart';
export 'features/team/views/team_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase Online Cloud Database
  await SupabaseConfig.loadConfig();
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('⚠️ Supabase Initialize Warning: $e');
  }

  // Inisialisasi Persistent Session dari SharedPreferences
  await SessionManager().initSession();

  runApp(const AplikasiKalkulatorKece());
}

class AplikasiKalkulatorKece extends StatelessWidget {
  const AplikasiKalkulatorKece({super.key});

  @override
  Widget build(BuildContext context) {
    final bool sessionActive = SessionManager().isSessionValid();

    return SessionListener(
      child: MaterialApp(
        title: 'Aplikasi Tugas 2 Super',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: sessionActive ? const MainNavigationView() : const LoginView(),
      ),
    );
  }
}
