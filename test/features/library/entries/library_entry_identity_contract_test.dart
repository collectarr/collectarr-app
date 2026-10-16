import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('entry identity is local and Core identity is provenance only', () {
    final record = LibraryEntryRecord(
      id: 'local-comic-42',
      kind: CatalogMediaKind.comic,
      catalogData: const {'title': 'The Example Issue'},
      personalData: const {'condition': 'Near Mint'},
      sourceCatalogRef: const CatalogItemRef(
        kind: CatalogMediaKind.comic,
        id: 'core-comic-7',
      ),
      updatedAt: DateTime.utc(2026, 10, 2),
    );

    final payload = record.toJson();
    expect(payload['id'], 'local-comic-42');
    expect(
        payload['source_catalog_ref'], {'kind': 'comic', 'id': 'core-comic-7'});
    expect(payload, isNot(contains('catalog_ref')));
    expect(payload, isNot(contains('target_ref')));
    expect(LibraryEntryRecord.fromJson(payload).id, record.id);
  });

  test('entry decoder rejects a second catalog-parent identity', () {
    expect(
      () => LibraryEntryRecord.fromJson({
        'id': 'local-comic-42',
        'kind': 'comic',
        'catalog_data': {'title': 'The Example Issue'},
        'personal_data': const <String, dynamic>{},
        'catalog_ref': {'kind': 'comic', 'id': 'core-comic-7'},
        'updated_at': '2026-10-02T00:00:00.000Z',
      }),
      throwsFormatException,
    );
  });
}
