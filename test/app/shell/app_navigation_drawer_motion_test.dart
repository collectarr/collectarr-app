import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/app/shell/app_navigation_drawer.dart';
import 'package:collectarr_app/app/shell/app_navigation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigation closes with a 200ms linear slide', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showAppNavigationDrawer(
          context: context,
          type: defaultLibraryKindRegistry.require(CatalogMediaKind.music),
          selectedAction: DrawerAction.libraries,
          isAdmin: false,
          accent: Colors.orange,
          addLabel: 'Add Albums from Core',
          animationsEnabled: true,
          onSelected: (context, _) => Navigator.of(context).pop(),
        ),
        child: const Text('Open'),
      ),
    ))));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final header = find.byKey(const Key('drawer.header'));
    expect(tester.getTopLeft(header).dx, 0);
    await tester.tap(find.byTooltip('Close navigation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getTopLeft(header).dx, closeTo(-160, 1));
    await tester.pumpAndSettle();
    expect(header, findsNothing);
    expect(tester.takeException(), isNull);
  });

}
