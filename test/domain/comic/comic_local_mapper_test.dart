import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/contracts/comic_contracts.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips a fully populated Comic media row', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = ComicMedia(
      id: const ComicMediaId('comic-1'),
      title: 'Saga: "The Long Way"',
      sortTitle: 'Saga',
      seriesTitle: 'Saga',
      issueNumber: '001',
      publisher: 'Image Comics',
      imprint: 'Skybound',
      releaseDate: DateTime.utc(2012, 3, 14),
      coverDate: DateTime.utc(2012, 3, 1),
      pageCount: 32,
      country: 'RO',
      language: 'ro',
      ageRating: 'T+',
      crossover: 'A story with a cross-over',
      synopsis: 'O poveste cu diacritice: ăîșț.',
      genres: const ['Science Fiction', 'Drama'],
      searchAliases: const ['The Saga', 'Sága'],
      writers: const ['Brian K. Vaughan'],
      artists: const ['Fiona Staples'],
      inkers: const ['Inker Name'],
      colorists: const ['Colorist Name'],
      letterers: const ['Letterer Name'],
      editors: const ['Editor Name'],
      coverArtists: const ['Cover Artist'],
      creatorCredits: const [
        ComicCreatorCredit(name: 'Brian K. Vaughan', role: 'writer'),
      ],
      characters: const ['Alana', 'Marko'],
      characterDetails: const [
        {
          'name': 'Alana',
          'aliases': ['Ață']
        },
      ],
      creators: const [
        {'id': 'creator-1', 'name': 'Brian K. Vaughan'},
      ],
      storyArcs: const ['The Beginning'],
      keyEvents: const [
        ComicKeyEvent(
          type: ComicKeyEventType.firstIssue,
          characterOrSubject: 'Saga',
          description: 'First issue',
        ),
      ],
      isKeyComic: true,
      keyReason: 'First issue of the series',
      variant: 'Regular Cover',
      variantDescription: 'Standard cover',
      barcode: '1234567890',
      series: const CatalogSeriesDetailsDto(
        seriesId: 'series-1',
        seriesTitle: 'Saga',
        volumeName: 'Volume One',
        volumeNumber: '1',
        volumeStartYear: 2012,
      ),
      publishing: CatalogPublishingDetailsDto(
        pageCount: 32,
        imprint: 'Skybound',
        originalPublicationDate: DateTime.utc(2012, 3, 14),
        subjects: const ['Space opera'],
        dewey: 'Fiction',
      ),
      editionTitle: 'Saga #1',
      titleExtension: 'The Beginning',
      physicalFormat: 'single-issue',
      physicalFormatLabel: 'Single Issue',
      links: const [
        ComicLink(
          url: 'https://example.test/trailer',
          title: 'Trailer',
          kind: 'trailer',
        ),
        ComicLink(
          url: 'https://example.test/wiki',
          title: 'Wiki',
          kind: 'external',
        ),
      ],
      rawPayload: const {
        'source': 'fixture',
        'nested': {'label': 'Șșț'},
      },
    );

    await db.into(db.comicMediaRows).insert(ComicLocalMapper.toMediaRow(media));
    final row = await db.select(db.comicMediaRows).getSingle();
    final restored = ComicLocalMapper.fromMediaRow(row);

    expect(restored.id, media.id);
    expect(restored.title, media.title);
    expect(restored.sortTitle, media.sortTitle);
    expect(restored.seriesTitle, media.seriesTitle);
    expect(restored.issueNumber, media.issueNumber);
    expect(restored.publisher, media.publisher);
    expect(restored.imprint, media.imprint);
    expect(restored.releaseDate?.toUtc(), media.releaseDate);
    expect(restored.coverDate?.toUtc(), media.coverDate);
    expect(restored.pageCount, media.pageCount);
    expect(restored.country, media.country);
    expect(restored.language, media.language);
    expect(restored.ageRating, media.ageRating);
    expect(restored.crossover, media.crossover);
    expect(restored.synopsis, media.synopsis);
    expect(restored.genres, media.genres);
    expect(restored.searchAliases, media.searchAliases);
    expect(restored.writers, media.writers);
    expect(restored.artists, media.artists);
    expect(restored.inkers, media.inkers);
    expect(restored.colorists, media.colorists);
    expect(restored.letterers, media.letterers);
    expect(restored.editors, media.editors);
    expect(restored.coverArtists, media.coverArtists);
    expect(restored.creatorCredits.single.name, 'Brian K. Vaughan');
    expect(restored.creatorCredits.single.role, 'writer');
    expect(restored.characters, media.characters);
    expect(restored.characterDetails, media.characterDetails);
    expect(restored.creators, media.creators);
    expect(restored.storyArcs, media.storyArcs);
    expect(restored.keyEvents.single.type, ComicKeyEventType.firstIssue);
    expect(restored.keyEvents.single.characterOrSubject, 'Saga');
    expect(restored.isKeyComic, media.isKeyComic);
    expect(restored.keyReason, media.keyReason);
    expect(restored.variant, media.variant);
    expect(restored.variantDescription, media.variantDescription);
    expect(restored.barcode, media.barcode);
    expect(restored.series?.seriesId, media.series?.seriesId);
    expect(restored.series?.volumeName, media.series?.volumeName);
    expect(restored.publishing?.pageCount, media.publishing?.pageCount);
    expect(restored.publishing?.subjects, media.publishing?.subjects);
    expect(restored.editionTitle, media.editionTitle);
    expect(restored.titleExtension, media.titleExtension);
    expect(restored.physicalFormat, media.physicalFormat);
    expect(restored.physicalFormatLabel, media.physicalFormatLabel);
    expect(restored.links.map((link) => link.url), [
      'https://example.test/trailer',
      'https://example.test/wiki',
    ]);
    expect(restored.links.map((link) => link.kind), ['trailer', 'external']);
    expect(restored.rawPayload, media.rawPayload);
  });

  test('round trips releases, variants, and their parent media identity',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const mediaId = ComicMediaId('comic-1');
    final release = ComicRelease(
      id: 'release-1',
      title: 'Saga #1 Hardcover',
      publisher: 'Image Comics',
      imprint: 'Skybound',
      isbn: '978-1-23456-789-0',
      upc: '123456789',
      releaseDate: DateTime.utc(2013, 1, 10),
      coverImageUrl: 'https://example.test/cover.jpg',
      variants: const [
        CatalogVariantDto(
          id: 'variant-1',
          name: 'Signed variant',
          variantType: 'signed',
          barcode: '987654321',
          isPrimary: true,
        ),
      ],
    );

    await db.into(db.comicReleaseRows).insert(
          ComicLocalMapper.toReleaseRow(mediaId, release),
        );
    final row = await db.select(db.comicReleaseRows).getSingle();
    final restored = ComicLocalMapper.fromReleaseRow(row);

    expect(row.mediaId, mediaId.value);
    expect(restored.id, release.id);
    expect(restored.title, release.title);
    expect(restored.publisher, release.publisher);
    expect(restored.imprint, release.imprint);
    expect(restored.isbn, release.isbn);
    expect(restored.upc, release.upc);
    expect(restored.releaseDate?.toUtc(), release.releaseDate);
    expect(restored.coverImageUrl, release.coverImageUrl);
    expect(restored.variants.single.id, 'variant-1');
    expect(restored.variants.single.variantType, 'signed');
    expect(restored.variants.single.isPrimary, isTrue);
  });

  test('restores supplied releases when assembling a media aggregate',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = ComicMedia(
      id: const ComicMediaId('comic-1'),
      title: 'Saga',
    );
    final release = ComicRelease(id: 'release-1', title: 'Saga #1');

    await db.into(db.comicMediaRows).insert(ComicLocalMapper.toMediaRow(media));
    final restored = ComicLocalMapper.fromMediaRow(
      await db.select(db.comicMediaRows).getSingle(),
      releases: [release],
    );

    expect(restored.releases, [release]);
  });

  test('preserves nullable Comic fields and table defaults', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const media = ComicMedia(
      id: ComicMediaId('comic-1'),
      title: 'Minimal Comic',
    );

    await db.into(db.comicMediaRows).insert(ComicLocalMapper.toMediaRow(media));
    final restored = ComicLocalMapper.fromMediaRow(
      await db.select(db.comicMediaRows).getSingle(),
    );

    expect(restored.id, media.id);
    expect(restored.title, media.title);
    expect(restored.sortTitle, isNull);
    expect(restored.releaseDate, isNull);
    expect(restored.pageCount, isNull);
    expect(restored.country, 'US');
    expect(restored.language, 'en');
    expect(restored.isKeyComic, isFalse);
    expect(restored.genres, isEmpty);
    expect(restored.creatorCredits, isEmpty);
    expect(restored.series, isNull);
    expect(restored.publishing, isNull);
    expect(restored.links, isEmpty);
    expect(restored.rawPayload, isEmpty);
  });

  test('requires persisted Comic media and release identities', () {
    expect(
      () => ComicLocalMapper.toMediaRow(const ComicMedia(title: 'Draft')),
      throwsStateError,
    );
    expect(
      () => ComicLocalMapper.toReleaseRow(
        const ComicMediaId('comic-1'),
        const ComicRelease(id: '', title: 'Invalid'),
      ),
      throwsStateError,
    );
  });
}
