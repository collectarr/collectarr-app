import 'package:collectarr_app/features/library/generic/toolbar/toolbar_sections.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_utility_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toolbar divider line renders a divider', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryToolbarDividerLine(),
        ),
      ),
    );

    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('selection toolbar band shows selection controls',
      (tester) async {
    final callbacks = (
      onClearSelection: () {},
      onSelectAll: () {},
      onBulkEdit: () {},
      onPrintToPdf: () {},
      onExportCsvTxt: () {},
      onBulkDuplicate: () {},
      onBulkLoan: () {},
      onTransferFieldData: () {},
      onBulkUpdateValues: null,
      onBulkUpdateKeyInfo: null,
      onBulkMoveToEntry: null,
      onBulkMoveToWishlist: null,
      onBulkRemove: () {},
      onBulkRefreshMetadata: () {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibrarySelectionToolbarBand(
            selectedCount: 3,
            totalSelectableCount: 12,
            callbacks: callbacks,
          ),
        ),
      ),
    );

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('3 of 12 selected'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(find.text('Print to PDF'), findsOneWidget);
    expect(find.text('Duplicate'), findsNothing);
    expect(find.text('Loan'), findsNothing);
    expect(find.text('Move to entry'), findsNothing);
    expect(find.text('Move to wishlist'), findsNothing);
    expect(find.text('Update values'), findsNothing);

    // Verify full-height dividers: 1 after Cancel, 1 before Print to PDF, 1 before More.
    expect(find.byType(LibrarySelectionToolbarDivider), findsNWidgets(3));

    final bandDecoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(LibrarySelectionToolbarBand),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = bandDecoratedBox.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(border.top, isNot(BorderSide.none));
    expect(decoration.gradient, isNotNull);

    // Tap more menu to verify CLZ overflow options
    await tester.ensureVisible(find.byType(LibrarySelectionMoreIcon));
    await tester.tap(find.byType(LibrarySelectionMoreIcon));
    await tester.pumpAndSettle();

    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Merge Albums'), findsOneWidget);
    expect(find.text('Loan'), findsOneWidget);
    expect(find.text('Transfer Field Data'), findsOneWidget);
    expect(find.text('Move to other collection'), findsOneWidget);
    expect(find.text('Update from Core'), findsOneWidget);
  });

  testWidgets('selection toolbar overflow exposes CLZ-like action labels', (
    tester,
  ) async {
    final callbacks = (
      onClearSelection: () {},
      onSelectAll: () {},
      onBulkEdit: () {},
      onPrintToPdf: () {},
      onExportCsvTxt: () {},
      onBulkDuplicate: () {},
      onBulkLoan: () {},
      onTransferFieldData: () {},
      onBulkUpdateValues: null,
      onBulkUpdateKeyInfo: null,
      onBulkMoveToEntry: () {},
      onBulkMoveToWishlist: () {},
      onBulkRemove: null,
      onBulkRefreshMetadata: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibrarySelectionControls(callbacks: callbacks),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    expect(find.text('Export to CSV / TXT'), findsOneWidget);
    expect(find.text('Export to XML'), findsOneWidget);
    expect(find.text('Export for CovrPrice'), findsOneWidget);
    expect(find.text('Transfer Field Data'), findsOneWidget);
    expect(find.text('Update Key Info'), findsOneWidget);
    expect(find.text('Update from Core'), findsOneWidget);
    final duplicateOverflowItem = find.byWidgetPredicate(
      (widget) =>
          widget is PopupMenuItem &&
          widget.child is ListTile &&
          (widget.child as ListTile).title is Text &&
          ((widget.child as ListTile).title as Text).data == 'Duplicate',
    );
    final loanOverflowItem = find.byWidgetPredicate(
      (widget) =>
          widget is PopupMenuItem &&
          widget.child is ListTile &&
          (widget.child as ListTile).title is Text &&
          ((widget.child as ListTile).title as Text).data == 'Loan',
    );
    final moveToEntryOverflowItem = find.byWidgetPredicate(
      (widget) =>
          widget is PopupMenuItem &&
          widget.child is ListTile &&
          (widget.child as ListTile).title is Text &&
          ((widget.child as ListTile).title as Text).data == 'Move to entry',
    );
    final moveToWishlistOverflowItem = find.byWidgetPredicate(
      (widget) =>
          widget is PopupMenuItem &&
          widget.child is ListTile &&
          (widget.child as ListTile).title is Text &&
          ((widget.child as ListTile).title as Text).data == 'Move to wishlist',
    );
    expect(duplicateOverflowItem, findsNothing);
    expect(loanOverflowItem, findsNothing);
    expect(moveToEntryOverflowItem, findsNothing);
    expect(moveToWishlistOverflowItem, findsNothing);
  });

  testWidgets(
      'selection toolbar overflow disables entry-only actions when unavailable',
      (
    tester,
  ) async {
    final callbacks = (
      onClearSelection: () {},
      onSelectAll: () {},
      onBulkEdit: null,
      onPrintToPdf: () {},
      onExportCsvTxt: () {},
      onBulkDuplicate: null,
      onBulkLoan: null,
      onTransferFieldData: null,
      onBulkUpdateValues: null,
      onBulkUpdateKeyInfo: null,
      onBulkMoveToEntry: () {},
      onBulkMoveToWishlist: () {},
      onBulkRemove: null,
      onBulkRefreshMetadata: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibrarySelectionControls(callbacks: callbacks),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    final transferItem = find.byWidgetPredicate(
      (widget) {
        if (widget is! PopupMenuItem || widget.enabled != false) return false;
        final child = widget.child;
        final listTile = child is Material ? child.child : child;
        return listTile is ListTile &&
            listTile.title is Text &&
            (listTile.title as Text).data == 'Transfer Field Data';
      },
    );
    final updateFromCoreItem = find.byWidgetPredicate(
      (widget) {
        if (widget is! PopupMenuItem || widget.enabled != false) return false;
        final child = widget.child;
        final listTile = child is Material ? child.child : child;
        return listTile is ListTile &&
            listTile.title is Text &&
            (listTile.title as Text).data == 'Update from Core';
      },
    );

    final editButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Edit'),
    );
    final removeButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Remove'),
    );
    final duplicateButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Duplicate'),
    );
    final loanButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Loan'),
    );
    final moveToEntryButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Move to entry'),
    );
    final moveToWishlistButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Move to wishlist'),
    );
    expect(editButton.onPressed, isNull);
    expect(removeButton.onPressed, isNull);
    expect(duplicateButton.onPressed, isNull);
    expect(loanButton.onPressed, isNull);
    expect(moveToEntryButton.onPressed, isNotNull);
    expect(moveToWishlistButton.onPressed, isNotNull);
    expect(transferItem, findsOneWidget);
    expect(updateFromCoreItem, findsOneWidget);
  });

  testWidgets('utility menu uses a labeled trigger and section headers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryUtilityMenu<String>(
            tooltip: 'Library tools',
            buttonLabel: 'Tools',
            quickViewsLabel: 'Views',
            quickViews: const [
              LibraryUtilityQuickView(
                value: 'missing-covers',
                label: 'Missing covers',
                icon: Icons.image_not_supported_outlined,
              ),
            ],
            selectedQuickView: 'missing-covers',
            onQuickViewSelected: (_) {},
            badgeCount: 2,
            actions: const [
              LibraryUtilityMenuAction(
                label: 'Statistics',
                icon: Icons.query_stats,
                section: 'Browse',
              ),
              LibraryUtilityMenuAction(
                label: 'Pre-fill settings...',
                icon: Icons.auto_fix_high,
                section: 'Administration',
              ),
              LibraryUtilityMenuAction(
                label: 'Keyboard shortcuts',
                icon: Icons.keyboard_command_key,
                section: 'Help',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Tools'), findsOneWidget);
    expect(find.byTooltip('Library tools'), findsOneWidget);

    await tester.tap(find.byTooltip('Library tools'));
    await tester.pumpAndSettle();

    expect(find.text('VIEWS'), findsOneWidget);
    expect(find.text('BROWSE'), findsOneWidget);
    expect(find.text('ADMINISTRATION'), findsOneWidget);
    expect(find.text('HELP'), findsOneWidget);
    expect(find.text('Keyboard shortcuts'), findsOneWidget);
  });

  testWidgets('selection toolbar band on desktop width uses spaced layout',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final callbacks = (
      onClearSelection: () {},
      onSelectAll: () {},
      onBulkEdit: () {},
      onPrintToPdf: () {},
      onExportCsvTxt: () {},
      onBulkDuplicate: () {},
      onBulkLoan: () {},
      onTransferFieldData: () {},
      onBulkUpdateValues: null,
      onBulkUpdateKeyInfo: null,
      onBulkMoveToEntry: null,
      onBulkMoveToWishlist: null,
      onBulkRemove: () {},
      onBulkRefreshMetadata: () {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibrarySelectionToolbarBand(
            selectedCount: 5,
            totalSelectableCount: 20,
            callbacks: callbacks,
          ),
        ),
      ),
    );

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(find.text('Print to PDF'), findsOneWidget);
    expect(find.text('5 of 20 selected'), findsOneWidget);

    final cancelPos = tester.getTopLeft(find.text('Cancel'));
    final editPos = tester.getTopLeft(find.text('Edit'));
    final countPos = tester.getTopLeft(find.text('5 of 20 selected'));

    // Cancel is at the left, Edit is in the middle, Count is on the right
    expect(cancelPos.dx < editPos.dx, isTrue);
    expect(editPos.dx < countPos.dx, isTrue);
  });
}

