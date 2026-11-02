import 'package:collectarr_app/features/library/kinds/music/integrations/collection_csv/music_collection_csv_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music CSV imports existing edition fields without inferring disc data',
      () {
    const projection = MusicCollectionCsvProjection();
    final header = projection.v1Header;
    final values = List<String>.filled(header.length, '');

    void setCell(String name, String value) {
      values[header.indexOf(name)] = value;
    }

    setCell('item_id', 'album-1');
    setCell('kind', 'music');
    setCell('title', 'Deluxe Edition');
    setCell('item_number', 'CAT-1');
    setCell('physical_format', 'CD');
    setCell('publisher', 'Example Records');
    setCell('release_date', '2025');

    final catalogCells = projection.importCatalogCells(
      header: header,
      values: values,
    );
    expect(catalogCells, isNotNull);

    final transport =
        projection.catalogTransportFromImportCells(catalogCells!)!;
    final payload = transport.payload;
    final disc = Map<String, Object?>.from(
      (payload['discs'] as List).single as Map,
    );

    expect(payload['catalog_number'], 'CAT-1');
    expect(payload['label'], 'Example Records');
    expect(payload['release_date'], '2025');
    expect(disc, {
      'id': 'csv-disc-album-1',
      'disc_number': 1,
      'format': 'CD',
      'tracks': <Map<String, dynamic>>[],
    });
    expect(disc, isNot(contains('format_family')));
    expect(disc, isNot(contains('recording_date')));
    expect(disc, isNot(contains('recording_locations')));
    expect(disc, isNot(contains('is_live')));
    expect(disc, isNot(contains('spars_code')));
    expect(disc, isNot(contains('credits')));
  });
}
