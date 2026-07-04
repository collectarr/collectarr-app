import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
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
                    editions: [
                      CatalogEdition(
                        id: 'release-1',
                        title: 'Blu-ray',
                        format: 'Blu-ray',
                        releaseDate: DateTime.utc(2024, 1, 5),
                      ),
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

    expect(sections.whereType<TvSeriesMetadataSection>(), hasLength(1));
    expect(sections.whereType<TvSeasonsEpisodesSection>(), hasLength(1));
    expect(sections.whereType<TvWatchHistorySection>(), hasLength(1));
    expect(sections.whereType<TvReleasesDiscsSection>(), hasLength(1));
    expect(sections.whereType<TvCastCrewSection>(), hasLength(1));
    expect(sections.whereType<TvSeriesMetadataSection>().first, isA<Widget>());
  });
}
