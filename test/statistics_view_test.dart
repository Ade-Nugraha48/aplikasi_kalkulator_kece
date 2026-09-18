// test/statistics_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_kalkulator_kece/features/calculator_t1/screens/statistik_screen.dart';

void main() {
  testWidgets('StatistikScreen memperhitungkan statistik deret angka dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StatistikScreen(),
      ),
    );

    expect(find.text('Hitung Jumlah & Statistik Deret'), findsOneWidget);

    final textField = find.byType(TextField);
    await tester.enterText(textField, '10 20 30');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Hasil Analisis Statistik'), findsOneWidget);
    expect(find.text('3 angka'), findsOneWidget);
  });

  testWidgets('StatistikScreen menampilkan pesan error saat input kosong', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StatistikScreen(),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Harap masukkan deret angka terlebih dahulu.'), findsOneWidget);
  });
}
