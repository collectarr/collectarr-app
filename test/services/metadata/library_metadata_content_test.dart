import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music metadata presentation exposes track count without track list',
      () {
    final presentation = buildLibraryMetadataPresentation(
      type: musicLibraryConfig,
      entry: LibraryWorkspaceEntry(
        id: 'music-1',
        mediaType: 'music',
        title: 'Discovery',
        series: const CatalogSeriesDetails(seriesTitle: 'Daft Punk'),
        publisher: 'Virgin',
        music: const MusicCatalogDetails(trackCount: 14),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    expect(
      presentation.contextFacts
          .where((fact) => fact.label == 'Tracks')
          .map((fact) => fact.value),
      ['14'],
    );
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

    final musicSections =
        musicLibraryConfig.presentation.builder.buildInspectorSections(
      context: context,
      entry: LibraryWorkspaceEntry(
        id: 'music-1',
        mediaType: 'music',
        title: 'Discovery',
        music: const MusicCatalogDetails(trackCount: 10),
        updatedAt: DateTime(2026, 1, 1),
      ),
      accent: Colors.cyan,
    );
    final movieSections =
        moviesLibraryConfig.presentation.builder.buildInspectorSections(
      context: context,
      entry: LibraryWorkspaceEntry(
        id: 'movie-1',
        mediaType: 'movie',
        title: 'Andor',
        synopsis: 'Rebellion rises.',
        updatedAt: DateTime(2026, 1, 1),
      ),
      accent: Colors.red,
    );

    expect(
        musicSections.whereType<InspectorTrackListUnavailable>(), hasLength(1));
    expect(
      movieSections
          .whereType<LibraryInspectorSection>()
          .map((section) => section.title),
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

    final sections =
        booksLibraryConfig.presentation.builder.buildInspectorSections(
      context: context,
      entry: LibraryWorkspaceEntry(
        id: 'book-1',
        mediaType: 'book',
        title: 'Hyperion',
        series: const CatalogSeriesDetails(seriesTitle: 'Hyperion Cantos'),
        publisher: 'Bantam',
        coverImageUrl: 'https://example.com/hyperion.jpg',
        barcode: '9780553283686',
        condition: 'Fine',
        grade: '9.0',
        notes: 'Personal note',
        updatedAt: DateTime(2026, 1, 1),
      ),
      accent: Colors.purple,
    );

    expect(
      sections
          .whereType<LibraryInspectorSection>()
          .map((section) => section.title),
      containsAll(<String>[
        'Original Details',
        'Product Details',
        'Images',
        'Personal Details',
      ]),
    );
    expect(
      sections
          .whereType<LibraryInspectorChipSection>()
          .map((section) => section.title),
      containsAll(<String>['Identifiers']),
    );
  });
}
