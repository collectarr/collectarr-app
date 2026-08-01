import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/episode_grid_section.dart';
import 'package:collectarr_app/features/library/media/video/video_external_links_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/session_history_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/shared/video_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tv inspector builds tv-specific sections', (tester) async {
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.tv)!;
    late List<Widget> sections;
    final item = VideoLibraryWorkspaceProjector(kind: 'tv').project(
      source: ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'series-1',
          kind: 'tv',
          title: 'Cowboy Bebop',
          displayTitle: 'Cowboy Bebop',
          video: const CatalogVideoDetails(
            runtimeMinutes: 24,
            discCount: 2,
            audioTracks: 'Stereo',
            subtitles: 'English',
            layers: 'Dual layer',
          ),
          editions: const [
            CatalogEdition(
              id: 'release-1',
              name: 'Blu-ray',
              physicalFormat: 'Blu-ray',
              physicalFormatLabel: 'Blu-ray',
              releaseDate: DateTime.utc(2024, 1, 5),
            ),
          ],
          trailerUrls: const [
            TrailerLink(url: 'https://example.com/trailer'),
          ],
        ),
      ),
      node: const LibraryTitleNodeRef('series-1'),
    );

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

    final detailSections = sections.where((w) => w is! SizedBox).toList();
    expect(detailSections, hasLength(6));

    // Extract all children from the detail section wrappers
    final allChildren = <Widget>[];
    for (final section in detailSections) {
      if (section is LibraryDetailSection) {
        allChildren.addAll(section.children);
      }
    }

    expect(allChildren.whereType<InspectorMetadataFactsSection>(), hasLength(1));
    final factsSection = allChildren.whereType<InspectorMetadataFactsSection>().single;
    expect(
      factsSection.facts.map((fact) => (fact as LibraryDetailField).label),
      containsAll(['Discs', 'Runtime', 'Audio', 'Subtitles', 'Layers', 'Trailers']),
    );
    expect(allChildren.whereType<InspectorEpisodeGridSection>(), hasLength(1));
    expect(allChildren.whereType<InspectorSessionHistorySection>(), hasLength(1));
    expect(allChildren.whereType<InspectorReleasesSection>(), hasLength(1));
    expect(allChildren.whereType<InspectorContributorsSection>(), hasLength(1));
    expect(allChildren.whereType<VideoExternalLinksSection>(), hasLength(1));
  });
}
