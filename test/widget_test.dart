import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:help_ping_ui/main.dart';

void main() {
  testWidgets('shows splash then login', (WidgetTester tester) async {
    // Build the app.
    await tester.pumpWidget(const HelpPingApp());

    // At first, splash image should be visible.
    expect(find.byType(Image), findsWidgets);

    // After 2 seconds, app should navigate to LoginScreen.
    await tester.pump(const Duration(seconds: 2));

    // Now expect to see the login title text.
    expect(find.text('HelpPing'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });
}
