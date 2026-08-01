import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_item_context_menu.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_constants.dart';

void main() {
  testWidgets('context menu shows bulk actions for multi-selection', (
    tester,
  ) async {
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'movie-1',
          kind: 'movie',
          title: 'Arrival',
          barcode: '1234567890',
        ),
      ),
      node: const LibraryTitleNodeRef('movie-1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await showLibraryItemContextMenu(
                    context: context,
                    position: const Offset(120, 120),
                    item: item,
                    accent: const Color(0xFF7BCFA6),
                    selectedCount: 3,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await pumpUntilSettled(tester);

    expect(find.text('Bulk edit selected'), findsOneWidget);
    expect(find.text('Move selected to owned'), findsOneWidget);
    expect(find.text('Move selected to wishlist'), findsOneWidget);
    expect(find.text('Remove selected'), findsOneWidget);
    expect(find.text('Copy title'), findsNothing);
    expect(find.text('Copy barcode'), findsNothing);
  });
}
