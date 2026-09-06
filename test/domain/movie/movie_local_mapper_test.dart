import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips a fully populated Movie media, release, and disc',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = MovieMedia(
      id: const MovieMediaId('movie-1'),
      title: 'The Matrix',
      sortTitle: 'Matrix, The',
      description: 'A hacker discovers the nature of reality.',
      releaseDate: DateTime.utc(1999, 3, 31),
      originalLanguage: 'en',
      ageRating: 'R',
      audienceRating: '8.7',
      runtimeMinutes: 136,
      subtitle: 'The One',
      characterAppearances: const [
        MovieCharacterAppearance(
          id: 'appearance-1',
          characterId: 'character-1',
          characterName: 'Neo',
          role: 'protagonist',
        ),
      ],
      contributions: const [
        MovieContributor(
          id: 'contribution-1',
          name: 'Lana Wachowski',
          role: 'director',
        ),
      ],
      externalLinks: const [
        MovieExternalLink(id: 'link-1', url: 'https://example.com/matrix'),
      ],
      identifiers: const [
        MovieIdentifier(
          id: 'identifier-1',
          identifierType: 'tmdb',
          value: '603',
          isPrimary: true,
        ),
      ],
      trailerUrls: const [
        MovieTrailerLink(
          id: 'trailer-1',
          url: 'https://example.com/trailer',
        ),
      ],
      rawPayload: const {'source': 'core', 'cover_image_url': 'cover.jpg'},
    );
    final release = MovieRelease(
      id: const MovieReleaseId('release-1'),
      title: '4K Collector Edition',
      workId: 'movie-1',
      coverImageKey: 'cover-key',
      coverImageUrl: 'release.jpg',
      description: 'Collector release.',
      distributor: 'Warner Home Video',
      externalLinks: const [
        MovieExternalLink(url: 'https://example.com/release'),
      ],
      format: '4K UHD',
      language: 'en',
      media: const [
        MovieReleaseMedia(
          id: MovieReleaseMediaId('media-1'),
          releaseId: 'release-1',
          mediaNumber: 1,
          mediaType: 'disc',
          numDiscs: 2,
          audioTracks: 'Dolby Atmos',
          subtitles: 'English, Spanish',
        ),
      ],
      region: 'US',
      releaseDate: DateTime.utc(2018, 5, 22),
      trailerUrls: const [MovieTrailerLink(url: 'release-trailer')],
      rawPayload: const {'source': 'core'},
    );

    await db.into(db.movieMediaRows).insert(MovieLocalMapper.toMediaRow(media));
    await db.into(db.movieReleaseRows).insert(
          MovieLocalMapper.toReleaseRow(media.id, release),
        );

    final restored = MovieLocalMapper.fromMediaRow(
      await db.select(db.movieMediaRows).getSingle(),
      releases: [
        MovieLocalMapper.fromReleaseRow(
          await db.select(db.movieReleaseRows).getSingle(),
        ),
      ],
    );

    expect(restored.id, media.id);
    expect(restored.title, media.title);
    expect(restored.sortTitle, media.sortTitle);
    expect(restored.description, media.description);
    expect(restored.releaseDate?.toUtc(), media.releaseDate);
    expect(restored.originalLanguage, media.originalLanguage);
    expect(restored.ageRating, media.ageRating);
    expect(restored.audienceRating, media.audienceRating);
    expect(restored.runtimeMinutes, media.runtimeMinutes);
    expect(restored.characterAppearances.single.characterName, 'Neo');
    expect(restored.contributions.single.name, 'Lana Wachowski');
    expect(restored.externalLinks.single.url, 'https://example.com/matrix');
    expect(restored.identifiers.single.value, '603');
    expect(restored.trailerUrls.single.url, 'https://example.com/trailer');
    expect(restored.rawPayload, media.rawPayload);
    expect(restored.releases, hasLength(1));

    final restoredRelease = restored.releases.single;
    expect(restoredRelease.typedId, release.typedId);
    expect(restoredRelease.title, release.title);
    expect(restoredRelease.workId, release.workId);
    expect(restoredRelease.coverImageKey, release.coverImageKey);
    expect(restoredRelease.coverImageUrl, release.coverImageUrl);
    expect(restoredRelease.distributor, release.distributor);
    expect(restoredRelease.externalLinks.single.url,
        'https://example.com/release');
    expect(restoredRelease.format, release.format);
    expect(restoredRelease.media.single.typedId,
        const MovieReleaseMediaId('media-1'));
    expect(restoredRelease.media.single.numDiscs, 2);
    expect(restoredRelease.rawPayload, release.rawPayload);
  });

  test('round trips all Movie owned details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const details = MovieOwnedDetails(
      features: 'Director commentary',
      hdrFormats: ['HDR10', 'Dolby Vision'],
      boxSetId: 'box-1',
      boxSetName: 'The Matrix Collection',
      region: 'A',
      packaging: 'SteelBook',
      distributor: 'Warner Home Video',
    );

    await db.into(db.movieOwnedDetailsRows).insert(
          MovieLocalMapper.toOwnedDetailsRow('owned-1', details),
        );
    final restored = MovieLocalMapper.fromOwnedDetailsRow(
      await db.select(db.movieOwnedDetailsRows).getSingle(),
    );

    expect(restored, details);
    expect(restored.features, details.features);
    expect(restored.hdrFormats, details.hdrFormats);
    expect(restored.boxSetId, details.boxSetId);
    expect(restored.boxSetName, details.boxSetName);
    expect(restored.region, details.region);
    expect(restored.packaging, details.packaging);
    expect(restored.distributor, details.distributor);
  });

  test('round trips the complete Movie owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MovieOwnedItem(
      id: const MovieOwnedItemId('owned-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'movie',
        entityType: CatalogEntityType.work,
        id: 'movie-1',
      ),
      createdAt: DateTime.utc(2026, 1, 2),
      isDigital: false,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: 'variant',
        editionId: 'release-1',
        variantId: 'variant-1',
      ),
      condition: 'Near Mint',
      grade: '9.8',
      purchaseDate: DateTime.utc(2026, 1, 3),
      pricePaidCents: 2499,
      currency: 'USD',
      personalNotes: 'Collector copy',
      quantity: 2,
      indexNumber: 1,
      tags: 'favorite,4k',
      updatedAt: DateTime.utc(2026, 1, 4),
      soldAt: DateTime.utc(2026, 2, 1),
      sellPriceCents: 2999,
      soldTo: 'buyer@example.com',
      ownerUserId: 'user-1',
      ownerLabel: 'Collector',
      locationId: 'shelf-1',
      purchaseStore: 'Local shop',
      collectionStatus: 'owned',
      marketValueCents: 3500,
      details: const MovieOwnedDetails(
        features: 'Director commentary',
        hdrFormats: ['HDR10', 'Dolby Vision'],
        boxSetId: 'box-1',
        boxSetName: 'The Matrix Collection',
        region: 'A',
        packaging: 'SteelBook',
        distributor: 'Warner Home Video',
      ),
    );

    await db.into(db.movieOwnedItemsRows).insert(
          MovieLocalMapper.toOwnedItemRow(item),
        );
    final restored = MovieLocalMapper.fromOwnedItemRow(
      await db.select(db.movieOwnedItemsRows).getSingle(),
    );

    expect(restored.id, item.id);
    expect(restored.catalogRef.kind, 'movie');
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.anchor?.apiValue, 'variant');
    expect(restored.anchor?.editionId, 'release-1');
    expect(restored.anchor?.variantId, 'variant-1');
    expect(restored.condition, item.condition);
    expect(restored.grade, item.grade);
    expect(restored.purchaseDate?.toUtc(), item.purchaseDate);
    expect(restored.pricePaidCents, item.pricePaidCents);
    expect(restored.currency, item.currency);
    expect(restored.personalNotes, item.personalNotes);
    expect(restored.quantity, item.quantity);
    expect(restored.indexNumber, item.indexNumber);
    expect(restored.tags, item.tags);
    expect(restored.updatedAt.toUtc(), item.updatedAt);
    expect(restored.soldAt?.toUtc(), item.soldAt);
    expect(restored.sellPriceCents, item.sellPriceCents);
    expect(restored.soldTo, item.soldTo);
    expect(restored.ownerUserId, item.ownerUserId);
    expect(restored.ownerLabel, item.ownerLabel);
    expect(restored.locationId, item.locationId);
    expect(restored.purchaseStore, item.purchaseStore);
    expect(restored.collectionStatus, item.collectionStatus);
    expect(restored.marketValueCents, item.marketValueCents);
    expect(restored.details, item.details);
  });

  test('requires persisted Movie identities', () {
    expect(
      () => MovieLocalMapper.toMediaRow(
        const MovieMedia(id: MovieMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => MovieLocalMapper.toReleaseRow(
        const MovieMediaId('movie-1'),
        const MovieRelease(id: MovieReleaseId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => MovieLocalMapper.toOwnedDetailsRow('', const MovieOwnedDetails()),
      throwsStateError,
    );
    expect(
      () => MovieLocalMapper.toOwnedItemRow(
        MovieOwnedItem(
          id: MovieOwnedItemId(''),
          catalogRef: CatalogEntityRef(
            kind: 'movie',
            entityType: CatalogEntityType.work,
            id: 'movie-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
