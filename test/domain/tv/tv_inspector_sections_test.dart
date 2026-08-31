import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector/episode_grid_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector/session_history_section.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_external_links_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tv inspector builds tv-specific sections', (tester) async {
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.tv)!;
    late List<Widget> sections;
    final source = ShelfEntry(
      itemId: 'series-1',
      catalogItem: testCatalogItem(
        id: 'series-1',
        kind: 'tv',
        title: 'Cowboy Bebop',
        video: const {
          'runtime_minutes': 24,
          'audio_tracks': 'Stereo',
          'subtitles': 'English',
          'layers': 'Dual layer',
        },
        editions: [
          CatalogEdition(
            id: 'release-1',
            title: 'Blu-ray',
            physicalFormat: 'Blu-ray',
            physicalFormatLabel: 'Blu-ray',
            releaseDate: DateTime.utc(2024, 1, 5),
          ),
        ],
        trailerUrls: const [
          TrailerLink(url: 'https://example.com/trailer'),
        ],
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'series-1');
    final dto =
        const TvWorkspaceProjector().projectTitle(source: source, node: node);
    final item = LibraryProjectionItem(source: source, node: node, dto: dto);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              sections = buildTvInspectorSections(
                context,
                LibraryInspectorRequest(
                  type: type,
                  item: item,
                  ownedItem: null,
                  trackingEntry: null,
                  accent: Colors.teal,
                ),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(sections, isNotEmpty);

    expect(sections.whereType<InspectorMetadataFactsSection>(), hasLength(1));
    final factsSection =
        sections.whereType<InspectorMetadataFactsSection>().single;
    expect(
      factsSection.facts.map((fact) => fact.label),
      contains('Trailers'),
    );
    expect(sections.whereType<InspectorEpisodeGridSection>(), hasLength(1));
    expect(sections.whereType<InspectorSessionHistorySection>(), hasLength(1));
    expect(sections.whereType<InspectorReleasesSection>(), hasLength(1));
    expect(sections.whereType<InspectorContributorsSection>(), hasLength(1));
    expect(sections.whereType<VideoExternalLinksSection>(), hasLength(1));
  });
}
