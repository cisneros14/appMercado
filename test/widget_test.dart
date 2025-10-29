// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:triara/main.dart';

void main() {
  testWidgets('Onboarding app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TriaraApp());

    // Verify that the app loads (it should show loading initially)
    expect(find.byType(MaterialApp), findsOneWidget);

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // The app should either show loading or the first onboarding slide
    // Since we're testing the basic structure, we just verify the app doesn't crash
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
