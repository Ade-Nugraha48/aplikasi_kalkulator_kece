// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_kalkulator_kece/main.dart'; // Sesuaikan dengan nama project Anda

void main() {
  testWidgets('Aplikasi dapat memuat Halaman Login', (WidgetTester tester) async {
    // Build aplikasi dan jalankan satu frame
    await tester.pumpWidget(const AplikasiKalkulatorKece());

    // Verifikasi bahwa halaman Login terbuka dan memiliki input Username
    expect(find.text('Login Aplikasi'), findsOneWidget);
    expect(find.byIcon(Icons.lock_person), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
  });
}