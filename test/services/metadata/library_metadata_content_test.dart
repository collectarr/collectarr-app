import 'package:collectarr_app/core/api/dto/catalog/music_catalog_details_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('music metadata presentation exposes track count without track list',
      () {
    final source = LibraryWorkspaceSource(
      itemId: 'music-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Discovery',
        publisher: 'Virgin',
      ).asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'music-1');
    final dto = const MusicWorkspaceProjector().project(
      source: source,
      entity: node,
    );
    final musicItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    final presentation = buildLibraryMetadataPresentation(
      type: const MusicRegistration(),
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

    final sourceMusic = LibraryWorkspaceSource(
      itemId: 'music-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Discovery',
        music: const MusicCatalogDetailsDto(trackCount: 10),
      ).asShelfCatalogItem),
    );
    const nodeMusic = LibraryWorkRef(workId: 'music-1');
    final dtoMusic = const MusicWorkspaceProjector().project(
      source: sourceMusic,
      entity: nodeMusic,
    );
    final musicItem = LibraryProjectionItem(
      source: sourceMusic,
      node: nodeMusic,
      dto: dtoMusic,
    );

    final sourceMovie = LibraryWorkspaceSource(
      itemId: 'movie-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Andor',
        synopsis: 'Rebellion rises.',
      ).asShelfCatalogItem),
    );
    const nodeMovie = LibraryWorkRef(workId: 'movie-1');
    final dtoMovie = const GenericWorkspaceProjector().project(
      source: sourceMovie,
      entity: nodeMovie,
    );
    final movieItem = LibraryProjectionItem(
      source: sourceMovie,
      node: nodeMovie,
      dto: dtoMovie,
    );

    final musicSections = musicKindPresentation.builder.buildInspectorSections(
      context: context,
      item: musicItem,
      accent: Colors.cyan,
    );
    final movieSections = movieKindPresentation.builder.buildInspectorSections(
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

    final source = LibraryWorkspaceSource(
      itemId: 'book-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'Hyperion',
        publisher: 'Bantam',
        coverImageUrl: 'https://example.com/hyperion.jpg',
        barcode: '9780553283686',
      ).asShelfCatalogItem),
      ownedSummary: testOwnedSummary(testOwnedItem(
        id: 'owned-b1',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId('owned_copy'),
          id: 'book-1',
        ),
        updatedAt: DateTime(2026, 1, 1),
        condition: 'Fine',
        grade: '9.0',
        personalNotes: 'Personal note',
      )),
    );
    const node = LibraryWorkRef(workId: 'book-1');
    final dto = const BookWorkspaceProjector().project(
      source: source,
      entity: node,
    );
    final bookItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    final sections = bookKindPresentation.builder.buildInspectorSections(
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
      ]),
    );
  });
}
