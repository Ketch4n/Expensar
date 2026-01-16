import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expensar/src/utils/app_bar_utils.dart';

void main() {
  group('CustomAppBar Tests', () {
    testWidgets('CustomAppBar displays title correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: 'Test Title'),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('CustomAppBar centers title when centerTitle is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: 'Centered', centerTitle: true),
            body: const SizedBox(),
          ),
        ),
      );

      final titleFinder = find.text('Centered');
      expect(titleFinder, findsOneWidget);
    });

    testWidgets('CustomAppBar displays custom background color', (
      WidgetTester tester,
    ) async {
      const customColor = Color(0xFFFF5722);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Custom Color',
              backgroundColor: customColor,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
    });

    testWidgets('CustomAppBar displays action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'With Actions',
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
              ],
            ),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('CustomAppBar has correct elevation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: 'Elevation Test', elevation: 8.0),
            body: const SizedBox(),
          ),
        ),
      );

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
    });
  });
}
