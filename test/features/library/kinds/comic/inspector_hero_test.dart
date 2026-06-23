import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryWorkspaceEntry _entryFixture() {
  return LibraryWorkspaceEntry(
    id: 'comic-hero-fixture',
    mediaType: 'comic',
    title: 'The Last Ronin',
    itemNumber: '1',
    publisher: 'IDW Publishing',
    releaseYear: 2020,
    barcode: '82771402051700111',
    synopsis: 'The final turtle seeks justice in a ruined future.',
    series: CatalogSeriesDetails(
      seriesTitle: 'Teenage Mutant Ninja Turtles: The Last Ronin',
    ),
    publishing: CatalogPublishingDetails(
      imprint: 'IDW',
      subtitle: 'Director Cut',
      seriesGroup: 'TMNT Event',
    ),
    genres: const ['Action', 'Dystopian'],
    updatedAt: DateTime.utc(2026, 5, 23),
  );
}

Widget _heroHost(OwnedItem ownedItem) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: ComicInspectorHero(
          request: LibraryInspectorRequest(
            type: comicsLibraryConfig,
            entry: _entryFixture(),
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
        OwnedItem(
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
    expect(find.text('82771402051700111'), findsOneWidget);
    expect(find.text('Plot'), findsOneWidget);
  });

  testWidgets('shows slab overlay for slabbed copies', (tester) async {
    await tester.pumpWidget(
      _heroHost(
        OwnedItem(
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
