import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_media_adapter.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_shelf_entry.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_grouped_shelf_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_factories.dart';

LibraryProjectionItem _item({
  required String id,
  required String title,
  required String bucket,
}) {
  final cat = testCatalogItem(
    id: id,
    kind: 'movie',
    title: title,
    publisher: bucket,
  );
  final source = ShelfEntry(itemId: id, catalogItem: cat);
  final node = LibraryTitleNodeRef(titleItemId: id);
  final dto = const GenericWorkspaceProjector().projectTitle(
    source: source,
    node: node,
  );
  return LibraryProjectionItem(
    source: source,
    node: node,
    dto: dto,
  );
}

GroupShelfEntry _group({
  required String bucket,
  required LibraryGroupPresentation presentation,
  required List<LibraryProjectionItem> items,
}) {
  return GroupShelfEntry(
    groupMode: 'publisher',
    bucket: bucket,
    presentation: presentation,
    items: items,
    representativeItem: items.first,
  );
}

final _viewState = moviesMediaAdapter.viewProfile.defaults();

void main() {
  testWidgets('inline headers collapse and expand in place', (tester) async {
    var collapsed = <String>{};

    final items = [
      _item(id: 'm1', title: 'Alpha', bucket: 'Batman'),
      _item(id: 'm2', title: 'Beta', bucket: 'Batman'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return LibraryGroupedShelfView(
                type: moviesLibraryConfig,
                adapter: moviesMediaAdapter,
                groups: [
                  _group(
                    bucket: 'Batman',
                    presentation: const LibraryGroupPresentation(
                      icon: Icons.folder,
                    ),
                    items: items,
                  ),
                ],
                viewState: _viewState,
                selectedId: null,
                selectionEnabled: false,
                selectedIds: const {},
                accent: Colors.blue,
                onSelectGroupBucket: (_) {},
                onOpenGroupDetails: (_) {},
                collapsedGroupBuckets: collapsed,
                onGroupBucketCollapsedToggled: (bucket) {
                  setState(() {
                    if (collapsed.contains(bucket)) {
                      collapsed.remove(bucket);
                    } else {
                      collapsed.add(bucket);
                    }
                  });
                },
                onActivateItem: (_) {},
                onToggleSelectionItem: (_) {},
                onOpenItem: (_) {},
                onEditItem: (_) {},
                emptyBuilder: (_) => const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Batman'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);

    await tester.tap(find.text('Batman'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsNothing);
  });
}
