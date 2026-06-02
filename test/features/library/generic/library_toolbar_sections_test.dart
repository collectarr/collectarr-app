import 'package:collectarr_app/features/library/generic/toolbar/toolbar_sections.dart';
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

  testWidgets('selection toolbar band shows selection controls', (tester) async {
    final callbacks = (
      onClearSelection: () {},
      onSelectAll: () {},
      onBulkEdit: () {},
      onPrintToPdf: () {},
      onBulkMoveToOwned: () {},
      onBulkMoveToWishlist: () {},
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
    expect(find.text('Update values'), findsOneWidget);
  });
}