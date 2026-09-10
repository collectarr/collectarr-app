import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('synthetic import snapshots expose only structural catalog identity',
      () {
    final snapshot = CatalogImportSnapshot.synthetic(
      id: 'anilist-local:42',
      kind: CatalogMediaKind.anime,
      title: 'A Place Further Than the Universe',
      releaseDate: DateTime.utc(2018, 1, 6),
    );

    expect(snapshot.catalogRef.kind, CatalogMediaKind.anime);
    expect(snapshot.catalogRef.id, 'anilist-local:42');
    expect(snapshot.title, 'A Place Further Than the Universe');
    expect(snapshot.kind, CatalogMediaKind.anime);
  });
}
