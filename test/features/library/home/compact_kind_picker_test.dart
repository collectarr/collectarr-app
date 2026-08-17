import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/home/compact_kind_picker.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final types = [
    const CatalogMediaType(
      kind: 'comic',
      singularLabel: 'Comic',
      pluralLabel: 'Comics',
    ),
    const CatalogMediaType(
      kind: 'manga',
      singularLabel: 'Manga',
      pluralLabel: 'Manga',
    ),
    const CatalogMediaType(
      kind: 'movie',
      singularLabel: 'Movie',
      pluralLabel: 'Movies',
    ),
    const CatalogMediaType(
      kind: 'book',
      singularLabel: 'Book',
      pluralLabel: 'Books',
    ),
  ];

  final counts = {
    'comic': const LibraryKindCount(owned: 42, wishlist: 5),
    'manga': const LibraryKindCount(owned: 12, wishlist: 0),
    'movie': const LibraryKindCount(owned: 8, wishlist: 2),
    'book': const LibraryKindCount(owned: 0, wishlist: 0),
  };

  testWidgets('CompactLibraryKindPicker renders active kind and count',
      (tester) async {
    CatalogMediaType? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryAccentScope(
            kind: 'comic',
            accent: Colors.deepOrange,
            animationsEnabled: true,
            child: CompactLibraryKindPicker(
              types: types,
              counts: counts,
              registry: LibraryTypeRegistry(const []),
              selectedKind: 'comic',
              onSelected: (type) => selected = type,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Comics'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    // Tap to open sheet
    await tester.tap(find.byType(CompactLibraryKindPicker));
    await tester.pumpAndSettle();

    expect(find.text('Switch Library'), findsOneWidget);
    expect(find.text('Manga'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);

    // Tap Movies
    await tester.tap(find.byKey(const ValueKey('kind_picker_item_movie')));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.kind, 'movie');
  });

  testWidgets(
      'MediaLibraryNav renders CompactLibraryKindPicker on compact screens',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryAccentScope(
              kind: 'comic',
              accent: Colors.deepOrange,
              animationsEnabled: true,
              child: MediaLibraryNav(
                types: types,
                counts: counts,
                selectedLabel: 'Comics',
                registry: LibraryTypeRegistry(const []),
                selectedKind: 'comic',
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CompactLibraryKindPicker), findsOneWidget);
    expect(find.byType(MediaLibraryNavStrip), findsNothing);
  });
}
