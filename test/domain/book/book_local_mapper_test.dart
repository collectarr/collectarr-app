import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips a fully populated Book media and edition', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = BookMedia(
      id: const BookMediaId('book-1'),
      title: 'The Left Hand of Darkness',
      sortTitle: 'Left Hand of Darkness, The',
      description: 'A diplomatic mission on a winter world.',
      firstPublicationDate: DateTime.utc(1969, 3, 1),
      originalLanguage: 'en',
      originalPublicationDate: DateTime.utc(1969, 3, 1),
      subtitle: 'A Novel',
      searchAliases: const ['Left Hand of Darkness'],
      genres: const ['Science fiction'],
      contributors: const [
        {'name': 'Ursula K. Le Guin', 'role': 'author'},
      ],
      series: const [
        {'id': 'series-hainish', 'title': 'Hainish Cycle'},
      ],
      rawPayload: const {'source': 'core'},
    );
    final edition = BookRelease(
      id: 'edition-1',
      title: 'Paperback Edition',
      workId: 'book-1',
      titleValue: 'Paperback',
      displayTitle: 'Paperback Edition',
      ageRating: 'Adult',
      audioLengthMinutes: 420,
      binding: 'perfect-bound',
      contributors: [
        {'name': 'Narrator', 'role': 'narrator'},
      ],
      coverImageKey: 'cover-key',
      publisher: 'Ace',
      distributor: 'Penguin Random House',
      description: 'Edition description',
      editionStatement: 'Reissue',
      isbn: '9780441478125',
      identifiers: [
        {'type': 'isbn13', 'value': '9780441478125'},
      ],
      imprint: 'Ace Books',
      upc: '123456789012',
      pageCount: 304,
      language: 'en',
      region: 'US',
      releaseDate: DateTime.utc(1976, 3, 1),
      releaseStatus: 'published',
      physicalFormat: 'paperback',
      physicalFormatLabel: 'Paperback',
      coverImageUrl: 'https://example.com/book.jpg',
      thumbnailImageUrl: 'https://example.com/book-small.jpg',
      dimensions: '178 x 108 mm',
      firstEdition: false,
      variants: [
        BookVariantRef(
          id: 'variant-1',
          name: 'Cover A',
          variantType: 'cover',
          sku: 'SKU-1',
          barcode: '987654321098',
          isbn: '9780441478125',
          region: 'US',
          coverImageUrl: 'https://example.com/variant.jpg',
          thumbnailImageUrl: 'https://example.com/variant-small.jpg',
          physicalFormat: 'paperback',
          physicalFormatLabel: 'Paperback',
          isPrimary: true,
        ),
      ],
    );

    await db.into(db.bookMediaRows).insert(BookLocalMapper.toMediaRow(media));
    await db.into(db.bookReleaseRows).insert(
          BookLocalMapper.toReleaseRow(media.id, edition),
        );
    final restored = BookLocalMapper.fromMediaRow(
      await db.select(db.bookMediaRows).getSingle(),
      editions: [
        BookLocalMapper.fromReleaseRow(
          await db.select(db.bookReleaseRows).getSingle(),
        ),
      ],
    );

    expect(restored.id, media.id);
    expect(restored.title, media.title);
    expect(restored.sortTitle, media.sortTitle);
    expect(restored.description, media.description);
    expect(restored.firstPublicationDate?.toUtc(), media.firstPublicationDate);
    expect(restored.originalLanguage, media.originalLanguage);
    expect(
      restored.originalPublicationDate?.toUtc(),
      media.originalPublicationDate,
    );
    expect(restored.subtitle, media.subtitle);
    expect(restored.searchAliases, media.searchAliases);
    expect(restored.genres, media.genres);
    expect(restored.contributors, media.contributors);
    expect(restored.series, media.series);
    expect(restored.rawPayload, media.rawPayload);
    expect(restored.editions, hasLength(1));
    final restoredEdition = restored.editions.single;
    expect(restoredEdition.typedId, const BookReleaseId('edition-1'));
    expect(restoredEdition.title, edition.title);
    expect(restoredEdition.workId, edition.workId);
    expect(restoredEdition.displayTitle, edition.displayTitle);
    expect(restoredEdition.audioLengthMinutes, edition.audioLengthMinutes);
    expect(restoredEdition.contributors, edition.contributors);
    expect(restoredEdition.publisher, edition.publisher);
    expect(restoredEdition.distributor, edition.distributor);
    expect(restoredEdition.identifiers, edition.identifiers);
    expect(restoredEdition.releaseDate?.toUtc(), edition.releaseDate);
    expect(restoredEdition.physicalFormat, edition.physicalFormat);
    expect(restoredEdition.coverImageUrl, edition.coverImageUrl);
    expect(restoredEdition.firstEdition, edition.firstEdition);
    expect(restoredEdition.variants, hasLength(1));
    expect(restoredEdition.variants.single.id, edition.variants.single.id);
    expect(
      restoredEdition.variants.single.variantType,
      edition.variants.single.variantType,
    );
    expect(restoredEdition.variants.single.sku, edition.variants.single.sku);
    expect(
      restoredEdition.variants.single.coverImageUrl,
      edition.variants.single.coverImageUrl,
    );
    expect(
      restoredEdition.variants.single.isPrimary,
      edition.variants.single.isPrimary,
    );
  });

  test('round trips all Book owned details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const details = BookOwnedDetails(
      signedBy: 'Ursula K. Le Guin',
      dustJacketPresent: true,
      dustJacketCondition: 'Very good',
    );

    await db.into(db.bookOwnedDetailsRows).insert(
          BookLocalMapper.toOwnedDetailsRow('owned-1', details),
        );
    final restored = BookLocalMapper.fromOwnedDetailsRow(
      await db.select(db.bookOwnedDetailsRows).getSingle(),
    );

    expect(restored, details);
    expect(restored.signedBy, details.signedBy);
    expect(restored.dustJacketPresent, details.dustJacketPresent);
    expect(restored.dustJacketCondition, details.dustJacketCondition);
  });

  test('requires persisted Book identities', () {
    expect(
      () => BookLocalMapper.toMediaRow(
        const BookMedia(id: BookMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => BookLocalMapper.toReleaseRow(
        const BookMediaId('book-1'),
        const BookRelease(id: '', title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => BookLocalMapper.toOwnedDetailsRow('', const BookOwnedDetails()),
      throwsStateError,
    );
  });
}
