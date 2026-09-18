// test/odd_even_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_kalkulator_kece/features/calculator_t1/screens/ganjil_genap_screen.dart';

void main() {
  testWidgets('GanjilGenapScreen memeriksa angka genap dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GanjilGenapScreen(),
      ),
    );

    final textField = find.byType(TextField);
    await tester.enterText(textField, '100');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Bilangan 100 adalah GENAP.'), findsOneWidget);
  });

  testWidgets('GanjilGenapScreen menampilkan pesan error saat input kosong', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GanjilGenapScreen(),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Harap masukkan bilangan terlebih dahulu.'), findsOneWidget);
  });
}
