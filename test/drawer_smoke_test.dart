import 'package:collectarr_app/app/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell drawer renders vector icons, headers, and dividers',
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
            currentBranch: 0,
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

    // Verify vector SVGs are rendered
    expect(find.byType(SvgPicture), findsWidgets);

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
    await tester.pump(const Duration(milliseconds: 175)); // halfway through 350ms
    await tester.pumpAndSettle();

    // Maintenance items should be collapsed
    expect(find.text('Backup / Restore'), findsNothing);

    // Expand Maintenance back
    await tester.tap(find.text('Maintenance'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 175)); // halfway through 350ms
    await tester.pumpAndSettle();
    expect(find.text('Backup / Restore'), findsOneWidget);
  });
}
