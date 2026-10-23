import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
        kind: 'music', singularLabel: 'Album', pluralLabel: 'Albums')
  ];
  final counts = {'music': const LibraryKindCount(entry: 42, wishlist: 5)};

  testWidgets('CompactLibraryKindPicker renders active kind and count',
      (tester) async {
    CatalogMediaType? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryAccentScope(
            kind: 'music',
            accent: Colors.deepOrange,
            animationsEnabled: true,
            child: CompactLibraryKindPicker(
              types: types,
              counts: counts,
              registry: defaultLibraryKindRegistry,
              selectedKind: 'music',
              onSelected: (type) => selected = type,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Music'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    // Tap to open sheet
    await tester.tap(find.byType(CompactLibraryKindPicker));
    await tester.pumpAndSettle();

    expect(find.text('Switch Library'), findsOneWidget);
    expect(find.text('Book'), findsNothing);
    expect(find.text('Movies'), findsNothing);
    expect(find.text('Books'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('kind_picker_item_music')));
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.text('Switch Library'), findsNothing);
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
              kind: 'music',
              accent: Colors.deepOrange,
              animationsEnabled: true,
              child: MediaLibraryNav(
                types: types,
                counts: counts,
                selectedLabel: 'Comics',
                registry: defaultLibraryKindRegistry,
                selectedKind: 'music',
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
