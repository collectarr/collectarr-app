import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/empty_state.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('filters without results show the reference banner',
      (tester) async {
    var resets = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LibraryEmptyState(
                type: libraryKindRegistrationForKind(CatalogMediaKind.game),
                icon: Icons.games,
                accent: Colors.red,
                hasActiveFilter: true,
                onAdd: () {},
                onClearFilter: () => resets++))));
    expect(find.text('No results found...'), findsOneWidget);
    expect(find.text('Add from Collectarr Core'), findsNothing);
    await tester.tap(find.text('Reset all filters'));
    expect(resets, 1);
  });
}
