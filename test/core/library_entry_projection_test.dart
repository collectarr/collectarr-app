import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LibraryEntryRef round-trips as a small typed cross-kind reference', () {
    const ref = LibraryEntryRef(
      kind: CatalogMediaKind.book,
      id: LibraryEntryId('entry-book-1'),
    );

    final decoded = LibraryEntryRef.fromJson(ref.toJson());

    expect(decoded, ref);
    expect(decoded.key, 'book:entry-book-1');
  });

  test('LibraryEntrySummary contains projection fields only', () {
    const summary = LibraryEntrySummary(
      ref: LibraryEntryRef(
        kind: CatalogMediaKind.comic,
        id: LibraryEntryId('entry-comic-1'),
      ),
      title: 'Batman #1',
      subtitle: 'Detective Comics',
      ownerLabel: 'Alex',
      locationLabel: 'Shelf A',
    );

    expect(summary.title, 'Batman #1');
    expect(summary.ref.kind, CatalogMediaKind.comic);
    expect(summary.ownerLabel, 'Alex');
  });

  test('LibraryEntryRef rejects an empty identifier', () {
    expect(
      () => LibraryEntryRef.fromJson({'kind': 'comic', 'id': ' '}),
      throwsFormatException,
    );
  });

  test('LibraryEntryRef rejects an unknown kind at the boundary', () {
    expect(
      () => LibraryEntryRef.fromJson({'kind': 'future-kind', 'id': 'entry-1'}),
      throwsFormatException,
    );
  });
}
