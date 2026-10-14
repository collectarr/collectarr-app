import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/app/shell/app_navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sections retain content while closing and can reverse mid-slide',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: AppNavigationDrawer(
        selectedAction: null,
        isAdmin: false,
        accent: Colors.orange,
        type: defaultLibraryKindRegistry.require(CatalogMediaKind.music),
        addLabel: 'Add Albums from Core',
        onSelected: (_, action) {},
      )),
    ));
    await tester.pumpAndSettle();
    final nextSection = find.text('Import / Export');
    final expandedY = tester.getTopLeft(nextSection).dy;

    await tester.tap(find.text('Maintenance'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final closingY = tester.getTopLeft(nextSection).dy;
    expect(find.text('Backup / Restore'), findsOneWidget);
    expect(closingY, lessThan(expandedY));
    await tester.pumpAndSettle();
    final collapsedY = tester.getTopLeft(nextSection).dy;
    expect(collapsedY, lessThan(closingY));
    expect(find.text('Backup / Restore'), findsNothing);

    await tester.tap(find.text('Maintenance'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final openingY = tester.getTopLeft(nextSection).dy;
    expect(openingY, greaterThan(collapsedY));
    expect(openingY, lessThan(expandedY));
    await tester.tap(find.text('Maintenance'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(nextSection).dy, closeTo(collapsedY, .1));
    expect(find.text('Backup / Restore'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation closes with a 200ms linear slide', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showAppNavigationDrawer(
          context: context,
          type: defaultLibraryKindRegistry.require(CatalogMediaKind.music),
          selectedAction: null,
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
