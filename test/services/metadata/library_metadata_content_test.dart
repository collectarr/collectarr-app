import 'package:collectarr_app/core/api/dto/catalog/music_catalog_details_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('music metadata presentation exposes track count without track list',
      () {
    final source = ShelfEntry(
      itemId: 'music-1',
      catalogItem: testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Discovery',
        publisher: 'Virgin',
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

    final presentation = buildLibraryMetadataPresentation(
      type: musicKindModule,
      item: musicItem,
    );

    expect(presentation, isNotNull);
  });

  testWidgets('media presentation builds supplemental inspector sections', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final sourceMusic = ShelfEntry(
      itemId: 'music-1',
      catalogItem: testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Discovery',
        music: const MusicCatalogDetailsDto(trackCount: 10),
      ),
    );
    const nodeMusic = LibraryTitleNodeRef(titleItemId: 'music-1');
    final dtoMusic = const MusicWorkspaceProjector().projectTitle(
      source: sourceMusic,
      node: nodeMusic,
    );
    final musicItem = LibraryProjectionItem(
      source: sourceMusic,
      node: nodeMusic,
      dto: dtoMusic,
    );

    final sourceMovie = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Andor',
        synopsis: 'Rebellion rises.',
      ),
    );
    const nodeMovie = LibraryTitleNodeRef(titleItemId: 'movie-1');
    final dtoMovie = const GenericWorkspaceProjector().projectTitle(
      source: sourceMovie,
      node: nodeMovie,
    );
    final movieItem = LibraryProjectionItem(
      source: sourceMovie,
      node: nodeMovie,
      dto: dtoMovie,
    );

    final musicSections =
        musicKindModule.presentation.builder.buildInspectorSections(
      context: context,
      item: musicItem,
      accent: Colors.cyan,
    );
    final movieSections =
        movieKindModule.presentation.builder.buildInspectorSections(
      context: context,
      item: movieItem,
      accent: Colors.red,
    );

    expect(
        musicSections.whereType<InspectorTrackListUnavailable>(), hasLength(1));
    expect(
      movieSections
          .whereType<LibraryDetailSection>()
          .map((LibraryDetailSection section) => section.title),
      contains('Summary'),
    );
  });

  testWidgets('book inspector sections are explicit about book slices', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final source = ShelfEntry(
      itemId: 'book-1',
      catalogItem: testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'Hyperion',
        publisher: 'Bantam',
        coverImageUrl: 'https://example.com/hyperion.jpg',
        barcode: '9780553283686',
      ),
      ownedItem: OwnedItem(
        id: 'owned-b1',
        catalogRef: const CatalogEntityRef(
          kind: 'book',
          entityType: CatalogEntityType.ownedCopy,
          id: 'book-1',
        ),
        details: const GenericOwnedDetails(),
        updatedAt: DateTime(2026, 1, 1),
        condition: 'Fine',
        grade: '9.0',
        personalNotes: 'Personal note',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'book-1');
    final dto = const BookWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final bookItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    final sections = bookKindModule.presentation.builder.buildInspectorSections(
      context: context,
      item: bookItem,
      accent: Colors.amber,
    );

    expect(
      sections
          .whereType<LibraryDetailSection>()
          .map((section) => section.title),
      containsAll(<String>[
        'Product Details',
        'Contributors',
        'Images',
        'Identifiers',
        'Personal Details',
      ]),
    );
  });
}
