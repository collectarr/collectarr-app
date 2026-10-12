import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/app/shell/app_navigation_drawer.dart';
import 'package:collectarr_app/app/shell/app_navigation_model.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';
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

  testWidgets('app shell drawer renders semantic icons, headers, and dividers',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    DrawerAction? selectedAction;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: AppNavigationDrawer(
            type: defaultLibraryKindRegistry.require(CatalogMediaKind.music),
            selectedAction: DrawerAction.libraries,
            isAdmin: true,
            accent: const Color(0xFFF2932F),
            addLabel: 'Add Albums from Core',
            onSelected: (context, action) {
              selectedAction = action;
            },
          ),
          body: const SizedBox(),
        ),
      ),
    );

    // Open drawer
    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('COLLECTARR MUSIC'), findsOneWidget);
    final header =
        tester.widget<Material>(find.byKey(const Key('drawer.header')));
    expect(header.color, Colors.transparent);
    final kindIcon =
        tester.widget<Icon>(find.byKey(const Key('drawer.kind-icon')));
    expect(
        kindIcon.icon,
        defaultLibraryKindRegistry
            .require(CatalogMediaKind.music)
            .identity
            .icon);
    expect(kindIcon.color, Colors.white);

    // Verify headers exist
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Administration'), findsOneWidget);
    expect(find.text('Customization'), findsOneWidget);
    expect(find.text('Maintenance'), findsOneWidget);
    expect(find.text('Import / Export'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);

    // Verify items
    expect(find.text('Add Albums from Core'), findsOneWidget);
    expect(find.text('Manage Collections'), findsOneWidget);
    expect(find.text('Print to PDF'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Backup / Restore'), findsOneWidget);

    // Verify semantic glyphs from the shared icon catalog.
    expect(find.byIcon(AppIcons.print), findsOneWidget);
    expect(find.byIcon(AppIcons.settings), findsOneWidget);

    // Test tapping an action
    await tester.tap(find.text('Manage Collections'));
    await tester.pump();
    expect(selectedAction, DrawerAction.manageCollections);

    await tester.tap(find.text('Export to CSV / TXT'));
    await tester.pump();
    expect(selectedAction, DrawerAction.exportCsv);

    // Test collapsible toggle animation for Maintenance
    await tester.tap(find.text('Maintenance'));
    await tester.pump();
    await tester
        .pump(const Duration(milliseconds: 150)); // halfway through 300ms
    await tester.pumpAndSettle();

    // Maintenance items should be collapsed
    expect(find.text('Backup / Restore'), findsNothing);

    // Expand Maintenance back
    await tester.tap(find.text('Maintenance'));
    await tester.pump();
    await tester
        .pump(const Duration(milliseconds: 150)); // halfway through 300ms
    await tester.pumpAndSettle();
    expect(find.text('Backup / Restore'), findsOneWidget);
  });
}
