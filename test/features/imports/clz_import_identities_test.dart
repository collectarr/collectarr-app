import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('CLZ import IDs number repeated copies and stay stable', () {
    String expected(CatalogMediaKind kind, String identity, int copy) =>
        const Uuid().v5(Namespace.url.value,
            'collectarr/import/${kind.apiValue}/clzweb/$identity/$copy');

    final ids = ClzImportIdentities(CatalogMediaKind.game);
    final first = ids.next('csv/Fictional/PC/');
    final second = ids.next('csv/Fictional/PC/');
    final other = ids.next('csv/Other/PC/');

    // Existing local entries were created with this derivation; a repeated
    // import must update them rather than add copies.
    expect(first, expected(CatalogMediaKind.game, 'csv/Fictional/PC/', 1));
    expect(second, expected(CatalogMediaKind.game, 'csv/Fictional/PC/', 2));
    expect(other, expected(CatalogMediaKind.game, 'csv/Other/PC/', 1));
    expect(ClzImportIdentities(CatalogMediaKind.game).next('csv/Fictional/PC/'),
        first);
    expect(
        ClzImportIdentities(CatalogMediaKind.gameToy).next('csv/Fictional/PC/'),
        isNot(first));
  });
}
