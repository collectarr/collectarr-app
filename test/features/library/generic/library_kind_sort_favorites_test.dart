import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kind sort favorites resolve every field label from the active schema',
      () {
    for (final kind in [CatalogMediaKind.music]) {
      final type = libraryKindRegistrationForKind(kind);
      final fields = libraryKindWorkspaceForKind(kind).workspaceFields;
      for (final favorite in librarySortFavoritesForType(type)) {
        for (final rule in favorite.rules) {
          expect(
              fields.sortDefinitionFor(fields.decodeSortId(rule.column)).label,
              isNotEmpty,
              reason: '${kind.apiValue}: ${favorite.id}');
        }
      }
    }
  });
}
