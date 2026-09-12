// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/login_screen.dart';

export 'models/big_decimal.dart';
export 'models/calculation_result.dart';
export 'services/calculator_service.dart';
export 'views/login_screen.dart';
export 'views/main_navigation_screen.dart';
export 'views/calculator_view.dart';
export 'views/odd_even_view.dart';
export 'views/statistics_view.dart';
export 'views/team_view.dart';

void main() {
  runApp(const AplikasiKalkulatorKece());
}

class AplikasiKalkulatorKece extends StatelessWidget {
  const AplikasiKalkulatorKece({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Super',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HalamanLogin(),
    );
  }
}