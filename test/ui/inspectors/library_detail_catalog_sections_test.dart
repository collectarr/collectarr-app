import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  testWidgets('detail context section renders metadata and genres', (
    tester,
  ) async {
    final source = ShelfEntry(
      itemId: 'music-1',
      catalogItem: testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Discovery',
        publisher: 'Virgin',
        genres: ['House', 'Electronic'],
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'music-1');
    final dto = const MusicWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final musicItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryDetailContextSection(
            type: musicLibraryConfig,
            accent: Colors.cyan,
            item: musicItem,
          ),
        ),
      ),
    );

    expect(find.text('Album context'), findsOneWidget);
    expect(find.text('Genres'), findsOneWidget);
    expect(find.text('House'), findsOneWidget);
  });

  testWidgets('detail credits section renders discovery groups', (
    tester,
  ) async {
    final source = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Saga #1',
        creators: [
          {'name': 'Brian K. Vaughan', 'role': 'Writer'},
        ],
        characters: ['Alana'],
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
    final dto = const ComicWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final comicItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryDetailCreditsSection(
            type: comicsLibraryConfig,
            accent: Colors.purple,
            item: comicItem,
          ),
        ),
      ),
    );

    expect(find.text('Creators & cast'), findsOneWidget);
    expect(find.text('Brian K. Vaughan'), findsOneWidget);
  });
}