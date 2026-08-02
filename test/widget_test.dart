import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_drift/main.dart';

void main() {
  testWidgets('App boots to the mode select screen', (tester) async {
    await tester.pumpWidget(const NovaDriftApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
