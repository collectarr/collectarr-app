import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

LibraryProjectionItem _itemFixture() {
  final cat = CatalogItemDto(
    id: 'comic-hero-fixture',
    kind: 'comic',
    title: 'The Last Ronin',
    synopsis: 'The final turtle seeks justice in a ruined future.',
    series: const CatalogSeriesDetails(
      seriesTitle: 'Teenage Mutant Ninja Turtles: The Last Ronin',
    ),
    publishing: const CatalogPublishingDetails(
      imprint: 'IDW',
      subtitle: 'Director Cut',
      seriesGroup: 'TMNT Event',
    ),
    genres: const ['Action', 'Dystopian'],
  );
  final source = ShelfEntry(itemId: 'comic-hero-fixture', catalogItem: cat);
  return LibraryProjectionItem.fromShelf(source, comicsLibraryConfig);
}

Widget _heroHost(OwnedItem ownedItem) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: ComicInspectorHero(
          request: LibraryInspectorRequest(
            type: comicsLibraryConfig,
            item: _itemFixture(),
            ownedItem: ownedItem,
            trackingEntry: null,
            accent: Colors.red,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders key comic metadata block', (tester) async {
    await tester.pumpWidget(
      _heroHost(
        testOwnedItem(
          id: 'owned-comic-hero-metadata',
          itemId: 'comic-hero-fixture',
          isDigital: false,
          condition: 'Near Mint',
          grade: '9.8',
          updatedAt: DateTime.utc(2026, 5, 23),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Director Cut'), findsOneWidget);
    expect(find.text('Plot'), findsOneWidget);
  });

  testWidgets('shows slab overlay for slabbed copies', (tester) async {
    await tester.pumpWidget(
      _heroHost(
        testOwnedItem(
          id: 'owned-comic-hero-slabbed',
          itemId: 'comic-hero-fixture',
          isDigital: false,
          rawOrSlabbed: 'Slabbed',
          gradingCompany: 'CGC',
          grade: '9.8',
          updatedAt: DateTime.utc(2026, 5, 23),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('comic-inspector-slab-overlay')),
        findsOneWidget);
  });
}
