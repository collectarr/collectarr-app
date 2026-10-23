import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_kind_menu.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogMediaType _type(String kind, String plural) =>
    CatalogMediaType(kind: kind, singularLabel: plural, pluralLabel: plural);

void main() {
  testWidgets('the library menu lists a collection family once',
      (tester) async {
    CatalogMediaType? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MediaLibraryKindMenu(
          types: [
            _type('game', 'Games'),
            _type('game_hardware', 'Hardware'),
            _type('game_toy', 'Toys'),
            _type('music', 'Albums'),
          ],
          registry: defaultLibraryKindRegistry,
          onSelected: (type) => selected = type,
        ),
      ),
    ));

    await tester.tap(find.byTooltip('Switch library'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('library-kind-picker-item-game')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('library-kind-picker-item-game_hardware')),
        findsNothing);
    expect(find.byKey(const ValueKey('library-kind-picker-item-game_toy')),
        findsNothing);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);

    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();
    expect(selected?.kind, 'game');
  });
}
