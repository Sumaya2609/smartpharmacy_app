// test/widget_test.dart
//
// Basic smoke test for Smart Pharmacy app.
// Verifies that the app builds and shows the Intro screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_pharmacy_app/main.dart';
import 'package:smart_pharmacy_app/routes.dart';

void main() {
  testWidgets('App starts on Intro page', (WidgetTester tester) async {
    // Build our app with a known initialRoute.
    await tester.pumpWidget(
      const MyApp(initialRoute: AppRoutes.intro),
    );

    // Let all frames render.
    await tester.pumpAndSettle();

    // Adjust these expectations to something that actually appears on IntroPage.
    // For example, if your IntroPage shows "Smart Pharmacy" and a "Get Started" button:
    expect(find.text('Smart Pharmacy'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
