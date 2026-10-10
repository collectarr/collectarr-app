import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resizing an open dialog to compact keeps interactive Material',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (context) {
        return TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => LibraryDialogScaffold(
              title: const Text('Add Albums'),
              contextBar: LibraryAddModeTab(
                icon: Icons.search,
                label: 'Search',
                onTap: () => taps++,
              ),
              body: const Text('Search results'),
            ),
          ),
          child: const Text('Open'),
        );
      })),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    for (final size in [const Size(900, 700), const Size(480, 650)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(taps, 2);
  });

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
                  body: const Text('Body'),
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

    final headerBox =
        tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).firstWhere(
              (box) =>
                  box.decoration is BoxDecoration &&
                  (box.decoration as BoxDecoration).gradient != null,
            );
    expect(headerBox, isNotNull);
  });
}
