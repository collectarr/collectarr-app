import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/episode_grid_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/links_trailers_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/session_history_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tv inspector builds tv-specific sections', (tester) async {
    final type = collectarrLibraryTypes.byKind('tv')!;
    late List<Widget> sections;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              sections = buildTvInspectorSections(
                context,
                LibraryInspectorRequest(
                  type: type,
                  entry: LibraryWorkspaceEntry(
                    id: 'series-1',
                    mediaType: 'tv',
                    title: 'Cowboy Bebop',
                    displayTitle: 'Cowboy Bebop',
                    video: const VideoCatalogDetails(
                      runtimeMinutes: 24,
                      nrDiscs: 2,
                      audioTracks: 'Stereo',
                      subtitles: 'English',
                      layers: 'Dual layer',
                    ),
                    editions: [
                      CatalogEdition(
                        id: 'release-1',
                        title: 'Blu-ray',
                        format: 'Blu-ray',
                        releaseDate: DateTime.utc(2024, 1, 5),
                      ),
                    ],
                    trailerUrls: const [
                      TrailerLink(url: 'https://example.com/trailer'),
                    ],
                    updatedAt: DateTime.utc(2026, 7, 5),
                  ),
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

    expect(sections, hasLength(6));
    expect(sections.whereType<InspectorMetadataFactsSection>(), hasLength(1));
    final factsSection = sections.whereType<InspectorMetadataFactsSection>().single;
    expect(
      factsSection.facts.map((fact) => fact.label),
      containsAll(['Discs', 'Runtime', 'Audio', 'Subtitles', 'Layers', 'Trailers']),
    );
    expect(sections.whereType<InspectorEpisodeGridSection>(), hasLength(1));
    expect(sections.whereType<InspectorSessionHistorySection>(), hasLength(1));
    expect(sections.whereType<InspectorReleasesSection>(), hasLength(1));
    expect(sections.whereType<InspectorContributorsSection>(), hasLength(1));
    expect(sections.whereType<InspectorLinksTrailersSection>(), hasLength(1));
  });
}
