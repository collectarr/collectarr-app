import 'package:collectarr_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app shows auth screen first', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CollectarrApp()));

    expect(find.text('Collectarr'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
