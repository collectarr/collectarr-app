import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/app/shell/app_navigation_drawer.dart';
import 'package:collectarr_app/app/shell/app_navigation_model.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
            selectedAction: null,
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
    final sectionText = tester.widget<Text>(find.text('Maintenance'));
    expect(sectionText.style?.fontSize, 14);
    expect(sectionText.style?.fontWeight, FontWeight.w700);
    final entryText = tester.widget<Text>(find.text('Manage Collections'));
    expect(entryText.style?.fontWeight, FontWeight.w400);
    expect(entryText.style?.fontSize, 14);
    expect(sectionText.style?.color?.a, closeTo(0.4, 0.01));
    expect(
        tester
            .getSize(find
                .ancestor(
                    of: find.text('Maintenance'),
                    matching: find.byType(InkWell))
                .first)
            .height,
        30);

    // Optional sections start collapsed; open them to verify their items.
    expect(find.text('Backup / Restore'), findsNothing);
    for (final section in ['Maintenance', 'Import / Export', 'Help']) {
      await tester.ensureVisible(find.text(section));
      await tester.tap(find.text(section));
      await tester.pumpAndSettle();
    }

    // Verify items
    expect(find.text('Add Albums from Core'), findsOneWidget);
    expect(find.text('Manage Collections'), findsOneWidget);
    expect(find.text('Print to PDF'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Backup / Restore'), findsOneWidget);
    expect(find.text('Link Albums'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.byIcon(AppIcons.userManual), findsOneWidget);

    await tester.ensureVisible(find.text('Manual'));
    await tester.tap(find.text('Manual'));
    await tester.pump();
    expect(selectedAction, DrawerAction.userManual);

    for (final action in [
      DrawerAction.community,
      DrawerAction.contactSupport,
      DrawerAction.whatsNew,
    ]) {
      final label = appDrawerDestination(action).label;
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
      expect(selectedAction, action);
    }

    await tester.ensureVisible(find.text('Manage Collections'));

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
    await tester.pumpAndSettle();

    // Maintenance items should be collapsed
    expect(find.text('Backup / Restore'), findsNothing);

    // Expand Maintenance back
    await tester.tap(find.text('Maintenance'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Backup / Restore'), findsOneWidget);
  });

  testWidgets('the link entry names the active library items', (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppNavigationDrawer(
            type: defaultLibraryKindRegistry.require(CatalogMediaKind.game),
            selectedAction: null,
            isAdmin: false,
            accent: const Color(0xFFE23149),
            addLabel: 'Add Games from Core',
            onSelected: (_, __) {},
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Import / Export'));
    await tester.tap(find.text('Import / Export'));
    await tester.pumpAndSettle();

    expect(find.text('Link Games'), findsOneWidget);
    expect(find.text('Link Albums'), findsNothing);
  });
}
