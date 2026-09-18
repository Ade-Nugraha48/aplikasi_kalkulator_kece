// lib/main.dart
import 'package:flutter/material.dart';
import 'core/utils/database_helper.dart';

import 'core/constants/app_theme.dart';
import 'features/auth/screens/login_screen.dart';

export 'features/calculator_t1/logic/big_decimal.dart';
export 'features/calculator_t1/logic/calculation_result.dart';
export 'features/calculator_t1/logic/calculator_service.dart';
export 'features/auth/screens/login_screen.dart';
export 'features/main_nav/screens/main_layout.dart';
export 'features/calculator_t1/screens/kalkulator_screen.dart';
export 'features/calculator_t1/screens/ganjil_genap_screen.dart';
export 'features/calculator_t1/screens/statistik_screen.dart';
export 'features/utilities/screens/anggota_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDatabase();
  runApp(const AplikasiKalkulatorKece());
}

class AplikasiKalkulatorKece extends StatelessWidget {
  const AplikasiKalkulatorKece({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Super Kece',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
