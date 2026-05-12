import 'package:collectarr_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app shows auth screen first', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: CollectarrApp()));
    await tester.pumpAndSettle();

    expect(find.text('Collectarr'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Fill dev credentials'),
        findsOneWidget);
    expect(find.text('Dev credentials: user@example.com / password123'),
        findsOneWidget);
  });
}
