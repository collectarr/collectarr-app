import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/inspector_sections.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

void main() {
  testWidgets('movie inspector composes movie-specific sections',
      (tester) async {
    final source = LibraryWorkspaceSource(
      itemId: 'movie-1',
      catalogTransport: testCatalogItem(
        id: 'movie-1',
        title: 'The Matrix',
        synopsis: 'A hacker discovers reality is a simulation.',
        kind: 'movie',
      ).asShelfCatalogItem,
    );

    final node = const LibraryTitleNodeRef(titleItemId: 'movie-1');
    final dto = const MovieWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );

    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    final request = LibraryInspectorRequest(
      type: const MovieRegistration(),
      item: item,
      ownedItem: null,
      trackingLifecycle: null,
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

    expect(sections.whereType<InspectorMetadataFactsSection>(), hasLength(1));
    // InspectorReleasesSection only appears when editions are present — not in this minimal fixture.
    expect(sections.whereType<InspectorReleasesSection>(), isEmpty);
  });
}
