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
      onBulkEdit: () {},
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
            callbacks: callbacks,
          ),
        ),
      ),
    );

    expect(find.text('3 selected'), findsOneWidget);
    expect(find.text('Clear selection'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
  });
}