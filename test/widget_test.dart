import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expensar/main.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.byType(Scaffold), findsWidgets);
  });
}
