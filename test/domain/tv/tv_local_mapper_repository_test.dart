import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TvRepository reads contained TV catalog data from shared cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final expected = _series();
    final repository = TvRepository(db);

    await repository.updateSeries(expected);
    final first = await repository.getSeries(const TvSeriesId('series-1'));
    final second = await repository.getSeries(const TvSeriesId('series-1'));

    expect(first?.id, expected.id);
    expect(second?.releases.single.id, expected.releases.single.id);
    expect(
      (await repository.seasonsFor(const TvSeriesId('series-1')))
          .single
          .episodes
          .single
          .title,
      'Dulcinea',
    );
  });

  test('TvLocalMapper round-trips the complete collection item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = TvLibraryEntry(
      id: const LibraryEntryId('entry-tv-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.tv,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'tv-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      condition: 'Near Mint',
      grade: '9.5',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 3999,
      currency: 'EUR',
      personalNotes: 'Complete season set',
      indexNumber: 3,
      tags: 'favorite,complete',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'TV collector',
      locationId: 'shelf-tv',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'entry',
      marketValueCents: 4500,
      details: const TvEntryDetails(
        features: 'Commentary',
        hdrFormats: ['HDR10'],
        boxSetId: 'box-1',
        boxSetName: 'Complete Collection',
        region: 'B',
        packaging: 'Amaray',
        distributor: 'BBC Studios',
      ),
    );

    await db.into(db.tvLibraryEntriesRows).insert(
          TvLocalMapper.toLibraryEntryRow(item),
        );
    final row = await db.select(db.tvLibraryEntriesRows).getSingle();
    final restored = TvLocalMapper.fromLibraryEntryRow(row);

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.condition, item.condition);
    expect(restored.grade, item.grade);
    expect(restored.purchaseDate?.toUtc(), item.purchaseDate);
    expect(restored.pricePaidCents, item.pricePaidCents);
    expect(restored.currency, item.currency);
    expect(restored.personalNotes, item.personalNotes);
    expect(restored.indexNumber, item.indexNumber);
    expect(restored.tags, item.tags);
    expect(restored.updatedAt.toUtc(), item.updatedAt);
    expect(restored.ownerUserId, item.ownerUserId);
    expect(restored.ownerLabel, item.ownerLabel);
    expect(restored.locationId, item.locationId);
    expect(restored.purchaseStore, item.purchaseStore);
    expect(restored.collectionStatus, item.collectionStatus);
    expect(restored.marketValueCents, item.marketValueCents);
    expect(restored.details, item.details);
  });

  test('TV schema remains on the clean v1 baseline', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 1);
  });
}

TvSeries _series() {
  const episode = TvEpisode(
    id: 'episode-1',
    seriesId: 'series-1',
    seasonId: 'season-1',
    seasonNumber: 1,
    episodeNumber: 1,
    title: 'Dulcinea',
    runtimeMinutes: 43,
  );
  const season = TvSeason(
    id: 'season-1',
    seriesId: 'series-1',
    seasonNumber: 1,
    title: 'Season 1',
    episodes: [episode],
  );
  const media = TvReleaseMedia(
    id: 'media-1',
    releaseId: 'release-1',
    mediaNumber: 1,
    mediaType: 'disc',
    title: 'Disc 1',
  );
  const release = TvRelease(
    id: 'release-1',
    seriesId: 'series-1',
    title: 'Season One Blu-ray',
    format: 'Blu-ray',
    media: [media],
    episodeMappings: [
      TvReleaseEpisodeMap(
        id: 'map-1',
        releaseId: 'release-1',
        mediaId: 'media-1',
        episodeId: 'episode-1',
        discNumber: 1,
        sequenceNumber: 1,
      ),
    ],
  );
  return const TvSeries(
    id: 'series-1',
    title: 'The Expanse',
    network: 'Syfy',
    seasons: [season],
    releases: [release],
    contributions: [TvContributor(name: 'Mark Fergus', role: 'Creator')],
    rawPayload: {'provider': 'core'},
  );
}
