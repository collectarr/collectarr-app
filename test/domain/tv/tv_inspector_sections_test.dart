import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/video_catalog_details_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/media/video/video_external_links_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tv inspector builds tv-specific sections', (tester) async {
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.tv)!;
    late List<Widget> sections;
    final source = ShelfEntry(
      itemId: 'series-1',
      catalogItem: CatalogItemDto(
        id: 'series-1',
        kind: 'tv',
        title: 'Cowboy Bebop',
        video: const VideoCatalogDetailsDto(
          runtimeMinutes: 24,
          audioTracks: 'Stereo',
          subtitles: 'English',
          layers: 'Dual layer',
        ),
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

    expect(sections.whereType<InspectorMetadataFactsSection>(), hasLength(1));
    expect(sections.whereType<InspectorReleasesSection>(), hasLength(1));
    expect(sections.whereType<VideoExternalLinksSection>(), hasLength(1));
  });
}
