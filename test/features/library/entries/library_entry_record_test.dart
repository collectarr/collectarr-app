import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('snapshots the complete catalog and personal data maps', () {
    final catalog = <String, dynamic>{'title': 'Album'};
    final personal = <String, dynamic>{'notes': 'First pressing'};
    final record = LibraryEntryRecord(
      id: 'entry-1',
      kind: CatalogMediaKind.music,
      catalogData: catalog,
      personalData: personal,
      updatedAt: DateTime.utc(2026, 10, 1),
    );

    catalog['title'] = 'Changed';
    personal['notes'] = 'Changed';

    expect(record.catalogData['title'], 'Album');
    expect(record.personalData['notes'], 'First pressing');
    expect(
      () => record.catalogData['title'] = 'Mutated',
      throwsUnsupportedError,
    );
    expect(
      () => record.personalData['notes'] = 'Mutated',
      throwsUnsupportedError,
    );
  });

  test('rejects obsolete parent references in the v1 entry envelope', () {
    expect(
      () => LibraryEntryRecord.fromJson({
        'id': 'entry-1',
        'kind': 'music',
        'catalog_data': {'title': 'Album'},
        'personal_data': const <String, Object?>{},
        'catalog_ref': {'kind': 'music', 'id': 'album-1'},
        'updated_at': '2026-10-01T00:00:00Z',
      }),
      throwsFormatException,
    );
  });

  test('requires source provenance to use the entry kind', () {
    expect(
      () => LibraryEntryRecord(
        id: 'entry-1',
        kind: CatalogMediaKind.music,
        catalogData: const {'title': 'Album'},
        personalData: const {},
        sourceCatalogRef: const CatalogItemRef(
          kind: CatalogMediaKind.book,
          id: 'book-1',
        ),
        updatedAt: DateTime.utc(2026, 10, 1),
      ),
      throwsArgumentError,
    );
  });
}
