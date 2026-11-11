import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/toolbar/auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/workspace/chrome/controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final compact in [true, false]) {
    testWidgets('sorting favorites span the whole split button ($compact)',
        (tester) async {
      final type = libraryKindRegistrationForKind(CatalogMediaKind.game);
      final favorites = librarySortFavoritesForType(type);
      final favorite = favorites.single;
      expect(libraryDefaultPinnedSortFavoriteIdsForType(type), {favorite.id});
      var editCount = 0;
      LibrarySortFavorite? selected;
      await tester.pumpWidget(MaterialApp(
        theme: buildAppShellTheme(palette: kDefaultAppThemePalette),
        home: Scaffold(
            body: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 40, top: 20),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const LibraryWorkspaceSeparator(key: ValueKey('sort.spacer')),
              LibraryToolbarSortButton(
                onPressed: () => editCount++,
                sortFavorites: favorites,
                activeSortFavoriteId: favorite.id,
                pinnedSortFavoriteIds: {favorite.id},
                iconOnly: compact,
                onSortFavoriteSelected: (value) => selected = value,
                fieldLabel: (id) {
                  final fields =
                      libraryKindWorkspaceForKind(type.kind).workspaceFields;
                  return fields
                      .sortDefinitionFor(fields.decodeSortId(id))
                      .label;
                },
              ),
            ]),
          ),
        )),
      ));
      await tester.tap(find.byIcon(AppIcons.sortAlpha));
      await tester.pumpAndSettle();
      expect(editCount, 1);
      expect(find.text('Manage Favorites'), findsNothing);
      await tester.tap(find.byIcon(AppIcons.chevronDown));
      await tester.pumpAndSettle();
      final trigger =
          find.byKey(const ValueKey('library-sort-split-button-menu'));
      final rows = find.byType(PopupMenuItem<Object>);
      expect(tester.getTopLeft(rows.first).dx,
          closeTo(tester.getTopLeft(trigger).dx - 4, 0.01));
      final spacerLine = find.descendant(
          of: find.byKey(const ValueKey('sort.spacer')),
          matching: find.byType(Container));
      expect(tester.getTopLeft(rows.first).dx,
          closeTo(tester.getTopRight(spacerLine).dx, 0.01));
      expect(tester.getTopLeft(rows.first).dy,
          closeTo(tester.getBottomLeft(trigger).dy + 4, 0.01));
      expect(
          tester.widget<Text>(find.text('Manage Favorites')).style!.fontWeight,
          FontWeight.w700);
      expect(find.text('Platform'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      await tester.tap(find.text('Platform'));
      await tester.pumpAndSettle();
      expect(selected?.id, 'platform_title');
      expect(tester.takeException(), isNull);
    });
  }

}
