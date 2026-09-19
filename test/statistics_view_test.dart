// test/statistics_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneforall/views/statistics_view.dart';

void main() {
  testWidgets('ViewTotalAngka memperhitungkan statistik deret angka dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ViewTotalAngka(),
        ),
      ),
    );

    expect(find.text('Hitung Jumlah & Statistik'), findsOneWidget);

    final textField = find.byType(TextField);
    await tester.enterText(textField, '10 20 30');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Hasil Ringkasan Statistik'), findsOneWidget);
    expect(find.text('3 data'), findsOneWidget);
  });

  testWidgets('ViewTotalAngka menampilkan error card merah saat input kosong', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ViewTotalAngka(),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Input Tidak Valid'), findsOneWidget);
    expect(find.text('Harap masukkan deret angka terlebih dahulu.'), findsOneWidget);
  });
}
