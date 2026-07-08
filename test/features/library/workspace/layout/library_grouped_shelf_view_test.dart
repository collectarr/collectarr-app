import 'package:collectarr_app/core/models/catalog_item.dart';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';

import 'package:collectarr_app/features/library/generic/projection.dart';

import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_media_adapter.dart'
    show moviesMediaAdapter;

import 'package:collectarr_app/features/library/workspace/entry/library_browser_node.dart';

import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';

import 'package:collectarr_app/features/library/workspace/entry/library_shelf_entry.dart';

import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

import 'package:collectarr_app/features/library/workspace/layout/library_grouped_shelf_view.dart';

import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_test/flutter_test.dart';



LibraryProjectionItem _item({

  required String id,

  required String title,

  required String bucket,

}) {

  final entry = LibraryWorkspaceEntry(

    id: id,

    mediaType: 'movie',

    title: title,

    updatedAt: DateTime.utc(2026, 1, 1),

  );

  return LibraryProjectionItem(

    source: ShelfEntry(

      itemId: id,

      catalogItem: CatalogItem(

        id: id,

        kind: 'movie',

        title: title,

      ),

    ),

    entry: entry,

    node: LibraryBrowserNode(

      id: id,

      scope: LibraryBrowserScope.title,

      titleItemId: id,

      entry: entry,

    ),

  );

}



GroupShelfEntry _group({

  required String bucket,

  required LibraryGroupPresentation presentation,

  required List<LibraryProjectionItem> items,

}) {

  return GroupShelfEntry(

    groupMode: LibraryGroupMode.publisher,

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

              return Scaffold(

                body: LibraryGroupedShelfView(

                  type: moviesLibraryConfig,

                  adapter: moviesMediaAdapter,

                  groups: [_group(

                    bucket: 'Batman',

                    presentation: LibraryGroupPresentation.inlineHeaders,

                    items: items,

                  )],

                  viewState: _viewState,

                  selectedId: null,

                  selectionEnabled: false,

                  selectedIds: const {},

                  accent: moviesLibraryConfig.workspace.accent,

                  collapsedGroupBuckets: collapsed,

                  onGroupBucketCollapsedToggled: (bucket) {

                    setState(() {

                      if (collapsed.contains(bucket)) {

                        collapsed.clear();

                      } else {

                        collapsed.add(bucket);

                      }

                    });

                  },

                  onSelectGroupBucket: (_) {},

                  onOpenGroupDetails: (_) {},

                  onActivateItem: (_) {},

                  onToggleSelectionItem: (_) {},

                  onOpenItem: (_) {},

                  onEditItem: (_) {},

                  emptyBuilder: (_) => const SizedBox.shrink(),

                ),

              );

            },

          ),

        ),

      ),

    );



    expect(find.byType(LibraryCoverTile), findsNWidgets(2));

    await tester.tap(find.text('Batman'));

    await tester.pump();



    expect(find.byType(LibraryCoverTile), findsNothing);

  });



  testWidgets('collapse all and expand all toggle every group', (tester) async {

    var collapsed = <String>{};

    final items1 = [_item(id: 'm1', title: 'Alpha', bucket: 'Batman')];

    final items2 = [_item(id: 'm2', title: 'Beta', bucket: 'Superman')];



    await tester.pumpWidget(

      ProviderScope(

        child: MaterialApp(

          home: StatefulBuilder(

            builder: (context, setState) {

              return Scaffold(

                body: LibraryGroupedShelfView(

                  type: moviesLibraryConfig,

                  adapter: moviesMediaAdapter,

                  groups: [

                    _group(

                      bucket: 'Batman',

                      presentation: LibraryGroupPresentation.inlineHeaders,

                      items: items1,

                    ),

                    _group(

                      bucket: 'Superman',

                      presentation: LibraryGroupPresentation.inlineHeaders,

                      items: items2,

                    ),

                  ],

                  viewState: _viewState,

                  selectedId: null,

                  selectionEnabled: false,

                  selectedIds: const {},

                  accent: moviesLibraryConfig.workspace.accent,

                  collapsedGroupBuckets: collapsed,

                  onGroupBucketCollapsedToggled: (_) {},

                  onSetCollapsedGroupBuckets: (buckets) {

                    setState(() => collapsed = buckets.toSet());

                  },

                  onSelectGroupBucket: (_) {},

                  onOpenGroupDetails: (_) {},

                  onActivateItem: (_) {},

                  onToggleSelectionItem: (_) {},

                  onOpenItem: (_) {},

                  onEditItem: (_) {},

                  emptyBuilder: (_) => const SizedBox.shrink(),

                ),

              );

            },

          ),

        ),

      ),

    );



    expect(find.byType(LibraryCoverTile), findsNWidgets(2));



    await tester.tap(find.text('Collapse all'));

    await tester.pump();

    expect(collapsed, {'Batman', 'Superman'});

    expect(find.byType(LibraryCoverTile), findsNothing);



    await tester.tap(find.text('Expand all'));

    await tester.pump();

    expect(collapsed, isEmpty);

    expect(find.byType(LibraryCoverTile), findsNWidgets(2));

  });



  testWidgets('folder grid still activates navigation on tap', (tester) async {

    String? selectedBucket;



    final items = [

      _item(id: 'm1', title: 'Alpha', bucket: 'Batman'),

    ];



    await tester.pumpWidget(

      ProviderScope(

        child: MaterialApp(

          home: Scaffold(

            body: LibraryGroupedShelfView(

              type: moviesLibraryConfig,

              adapter: moviesMediaAdapter,

              groups: [_group(

                bucket: 'Batman',

                presentation: LibraryGroupPresentation.folderGrid,

                items: items,

              )],

              viewState: _viewState,

              selectedId: null,

              selectionEnabled: false,

              selectedIds: const {},

              accent: moviesLibraryConfig.workspace.accent,

              collapsedGroupBuckets: const {},

              onGroupBucketCollapsedToggled: (_) {},

              onSelectGroupBucket: (bucket) => selectedBucket = bucket,

              onOpenGroupDetails: (_) {},

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



    await tester.tap(find.byType(LibraryGroupFolderTile));

    await tester.pump();



    expect(selectedBucket, 'Batman');

  });

}

