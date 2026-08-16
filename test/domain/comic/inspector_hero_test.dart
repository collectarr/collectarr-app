import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
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
  final db = LocalDatabase(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      localDatabaseProvider.overrideWithValue(db),
    ],
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
          id: 'owned-comic-hero-fixture',
          itemId: 'comic-hero-fixture',
          kind: 'comic',
          grade: '9.8 CGC',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The Last Ronin'), findsWidgets);
    expect(find.text('9.8 CGC'), findsWidgets);
  });
}
