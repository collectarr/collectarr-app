import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
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

final _viewState = movieKindModule.viewProfile.defaults();

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
                type: movieKindModule,
                groups: [
                  _group(
                    bucket: 'Batman',
                    presentation: LibraryGroupPresentation.inlineHeaders,
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
    expect(find.text('Alpha'), findsWidgets);

    await tester.tap(find.text('Batman'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets(
      'renders comic series groups with sequence progress without contravariance type errors',
      (tester) async {
    final cat = testCatalogItem(
      id: 'c1',
      kind: 'comic',
      title: 'Batman #1',
      series: const CatalogSeriesDetailsDto(seriesTitle: 'Batman'),
      itemNumber: '1',
    );
    final source = ShelfEntry(itemId: 'c1', catalogItem: cat);
    final node = const LibraryTitleNodeRef(titleItemId: 'c1');
    final item = comicKindModule.project(source: source, node: node);

    final group = GroupShelfEntry(
      groupMode: 'series',
      bucket: 'Batman',
      presentation: LibraryGroupPresentation.folderGrid,
      items: [item as LibraryProjectionItem],
      representativeItem: item,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryGroupedShelfView(
              type: comicKindModule,
              groups: [group],
              viewState: comicKindModule.viewProfile.defaults(),
              selectedId: null,
              selectionEnabled: false,
              selectedIds: const {},
              accent: Colors.blue,
              onSelectGroupBucket: (_) {},
              onOpenGroupDetails: (_) {},
              collapsedGroupBuckets: const {},
              onGroupBucketCollapsedToggled: (_) {},
              onActivateItem: (_) {},
              onToggleSelectionItem: (_) {},
              onOpenItem: (_) {},
              onEditItem: (_) {},
              emptyBuilder: (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Batman'), findsOneWidget);
  });

  testWidgets('renders folderGrid under narrow constraints without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(300, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cat = testCatalogItem(
      id: 'c1',
      kind: 'comic',
      title: 'Batman #1 Very Long Title That Might Wrap Or Overflow',
      series: const CatalogSeriesDetailsDto(seriesTitle: 'Batman'),
      itemNumber: '1',
    );
    final source = ShelfEntry(itemId: 'c1', catalogItem: cat);
    final node = const LibraryTitleNodeRef(titleItemId: 'c1');
    final item = comicKindModule.project(source: source, node: node);

    final group = GroupShelfEntry(
      groupMode: 'series',
      bucket: 'Batman',
      presentation: LibraryGroupPresentation.folderGrid,
      items: [item as LibraryProjectionItem],
      representativeItem: item,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 140,
              height: 180,
              child: LibraryGroupFolderTile(
                group: group,
                accent: Colors.blue,
                showSeasonGroupProgress: false,
                onTap: () {},
                onOpenDetails: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Batman'), findsOneWidget);
  });
}
