import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/empty_state.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
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
                hasActiveFilter: true,
                onClearFilter: () => resets++))));
    expect(find.text('No results found...'), findsOneWidget);
    expect(find.text('Add from Collectarr Core'), findsNothing);
    await tester.tap(find.text('Reset all filters'));
    expect(resets, 1);
  });

  testWidgets('an empty collection shows the reference banner', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LibraryEmptyState(
                type: libraryKindRegistrationForKind(CatalogMediaKind.comic),
                hasActiveFilter: false,
                onClearFilter: () {}))));
    expect(find.text('No comics yet.'), findsOneWidget);
    expect(
        find.textContaining('To start adding your comics, use the blue',
            findRichText: true),
        findsOneWidget);
    expect(
        find.textContaining(
            defaultTargetPlatform == TargetPlatform.android
                ? 'button at the bottom right'
                : 'Add Comics',
            findRichText: true),
        findsOneWidget);
    expect(find.text('Add from Collectarr Core'), findsNothing);
  },
      variant: TargetPlatformVariant(
          {TargetPlatform.android, TargetPlatform.windows}));
}
