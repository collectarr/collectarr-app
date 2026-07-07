import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/library_dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('library dialog scaffold renders shared header and close button',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryAccentScope(
          kind: 'comic',
          accent: Colors.deepPurple,
          animationsEnabled: false,
          child: Scaffold(
            body: Builder(
              builder: (context) {
                return LibraryDialogScaffold(
                  title: const Text('Inspector'),
                  onClose: () {},
                  child: const Text('Body'),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Inspector'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    final headerContainer = tester.widgetList<Container>(find.byType(Container))
        .firstWhere(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).color ==
                  Colors.deepPurple,
        );
    expect(headerContainer, isNotNull);
  });
}
