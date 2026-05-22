import 'package:collectarr_app/features/library/config/planned_library_configs.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/features/library/seasons_section.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music metadata presentation exposes track count without track list', () {
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

    final musicSections = musicLibraryConfig.presentation.builder.buildInspectorSections(
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
    final tvSections = tvLibraryConfig.presentation.builder.buildInspectorSections(
      context: context,
      entry: LibraryWorkspaceEntry(
        id: 'tv-1',
        mediaType: 'tv',
        title: 'Andor',
        synopsis: 'Rebellion rises.',
        updatedAt: DateTime(2026, 1, 1),
      ),
      accent: Colors.red,
    );

    expect(musicSections.whereType<InspectorTrackListUnavailable>(), hasLength(1));
    expect(tvSections.whereType<SeasonsSection>(), hasLength(1));
    expect(
      tvSections.whereType<LibraryInspectorSection>().map((section) => section.title),
      contains('Summary'),
    );
  });
}