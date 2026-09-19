// test/odd_even_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneforall/views/odd_even_view.dart';

void main() {
  testWidgets('ViewGanjilGenap memeriksa angka genap dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ViewGanjilGenap(),
        ),
      ),
    );

    final textField = find.byType(TextField);
    await tester.enterText(textField, '100');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Bilangan 100 adalah GENAP.'), findsOneWidget);
  });

  testWidgets('ViewGanjilGenap menampilkan error card merah saat input kosong', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ViewGanjilGenap(),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Input Tidak Valid'), findsOneWidget);
    expect(find.text('Harap masukkan bilangan terlebih dahulu.'), findsOneWidget);
  });
}
