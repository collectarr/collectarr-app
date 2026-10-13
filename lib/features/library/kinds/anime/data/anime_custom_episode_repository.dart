import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:drift/drift.dart';

/// Stores user-created episode details attached to an Anime library entry.
final class AnimeCustomEpisodeRepository {
  AnimeCustomEpisodeRepository(this._db);

  final LocalDatabase _db;

  Future<void> upsert(AnimeCustomEpisode episode) {
    if (episode.libraryEntryRef.kind != CatalogMediaKind.anime) {
      throw ArgumentError.value(
        episode.libraryEntryRef.kind,
        'episode.libraryEntryRef.kind',
        'Anime custom episodes must belong to an Anime library entry.',
      );
    }
    return _db.into(_db.animeCustomEpisodeRows).insertOnConflictUpdate(
          AnimeCustomEpisodeRowsCompanion.insert(
            id: episode.id.value,
            libraryEntryId: episode.libraryEntryRef.id.value,
            seasonNumber: episode.seasonNumber,
            episodeNumber: episode.episodeNumber,
            title: episode.title,
            description: Value(episode.description),
            airDate: Value(episode.airDate),
            runtimeMinutes: Value(episode.runtimeMinutes),
            stillImageUrl: Value(episode.stillImageUrl),
            localImagePath: Value(episode.localImagePath),
            thumbnailImageUrl: Value(episode.thumbnailImageUrl),
            updatedAt: episode.updatedAt,
            deletedAt: Value(episode.deletedAt),
          ),
        );
  }

  Future<AnimeCustomEpisode?> findById(AnimeEpisodeId id) async {
    final row = await (_db.select(_db.animeCustomEpisodeRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row == null) return null;
    return AnimeCustomEpisode(
      id: AnimeEpisodeId(row.id),
      libraryEntryRef: LibraryEntryRef(
        kind: CatalogMediaKind.anime,
        id: LibraryEntryId(row.libraryEntryId),
      ),
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      title: row.title,
      description: row.description,
      airDate: row.airDate,
      runtimeMinutes: row.runtimeMinutes,
      stillImageUrl: row.stillImageUrl,
      localImagePath: row.localImagePath,
      thumbnailImageUrl: row.thumbnailImageUrl,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
