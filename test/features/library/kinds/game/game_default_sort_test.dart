import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (kind, namespace) in [
    (CatalogMediaKind.game, 'game'),
    (CatalogMediaKind.gameHardware, 'game_hardware'),
  ]) {
    test('$namespace starts sorted by its built-in Platform / Title favorite',
        () {
      final type = libraryKindRegistrationForKind(kind);
      final expected = [
        ('$namespace.platform', true),
        ('$namespace.title', true)
      ];
      expect(
          libraryViewProfileForKind(kind)
              .defaults()
              .sortRules
              .map((rule) => (rule.sortId.value, rule.ascending)),
          expected);
      final favorite = librarySortFavoritesForType(type).single;
      expect(favorite.rules.map((rule) => (rule.column, rule.ascending)),
          expected);
      expect(libraryDefaultPinnedSortFavoriteIdsForType(type), {favorite.id});
    });
  }
}
