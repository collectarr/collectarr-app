import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('movie inspector composes movie-specific sections',
      (tester) async {
    const source = ShelfEntry(
      catalogItem: CatalogItemDto(
        id: 'movie-1',
        title: 'The Matrix',
        description: 'A hacker discovers reality is a simulation.',
        runtimeMinutes: 136,
        kind: 'movie',
      ),
    );
    final item = const MovieWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'movie-1'),
    ).toItem();

    final request = LibraryInspectorRequest(
      type: moviesLibraryConfig,
      item: item,
      ownedItem: null,
      trackingEntry: null,
      accent: Colors.green,
    );

    late List<Widget> sections;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            sections = buildMovieInspectorSections(context, request);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      sections.whereType<InspectorMetadataFactsSection>(),
      hasLength(1),
    );
    final factsSection = sections.whereType<InspectorMetadataFactsSection>().single;
    expect(
      factsSection.facts.map((fact) => (fact as LibraryDetailField).label),
      containsAll(['Runtime', 'Releases']),
    );
    expect(sections.whereType<InspectorReleasesSection>(), hasLength(1));
    expect(sections.whereType<InspectorContributorsSection>(), isEmpty);
  });
}
