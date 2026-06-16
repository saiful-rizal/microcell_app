import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:microcell_app/main.dart';

void main() {
  testWidgets('opens main pages from bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Haii Sobat BIOCELL'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Akun Baru'), findsOneWidget);
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
  });
}
