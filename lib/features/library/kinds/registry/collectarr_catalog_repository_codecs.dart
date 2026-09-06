import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

/// Composition-root registrations for the typed catalog repositories.
const List<CatalogKindRepositoryCodec> collectarrCatalogRepositoryCodecs = [
  ComicCatalogRepositoryCodec(),
  MangaCatalogRepositoryCodec(),
  BookCatalogRepositoryCodec(),
  GameCatalogRepositoryCodec(),
  BoardGameCatalogRepositoryCodec(),
  MovieCatalogRepositoryCodec(),
  TvCatalogRepositoryCodec(),
  AnimeCatalogRepositoryCodec(),
  MusicCatalogRepositoryCodec(),
];

final class ComicCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const ComicCatalogRepositoryCodec();

  @override
  String get kind => 'comic';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, ComicMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return ComicRepository(db).updateMedia(
      ComicMedia.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await ComicRepository(db).search();
    return [
      for (final item in media)
        _projection(
          'comic',
          item.id?.value,
          item.title,
          item.rawPayload,
          ComicMedia.fromJson,
        ),
    ];
  }
}

final class MangaCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MangaCatalogRepositoryCodec();

  @override
  String get kind => 'manga';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, MangaMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return MangaRepository(db).updateMedia(
      MangaMedia.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await MangaRepository(db).search();
    return [
      for (final item in media)
        _projection(
          'manga',
          item.id,
          item.title,
          item.rawPayload,
          MangaMedia.fromJson,
        ),
    ];
  }
}

final class BookCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const BookCatalogRepositoryCodec();

  @override
  String get kind => 'book';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, BookMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return BookRepository(db).updateMedia(
      BookMedia.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await BookRepository(db).search();
    return [
      for (final item in media)
        _projection(
          'book',
          item.id.value,
          item.title,
          item.rawPayload,
          BookMedia.fromJson,
        ),
    ];
  }
}

final class GameCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const GameCatalogRepositoryCodec();

  @override
  String get kind => 'game';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, GameMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return GameRepository(db).updateMedia(
      GameMedia.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await GameRepository(db).search();
    return [
      for (final item in media)
        _projection(
          'game',
          item.id.value,
          item.title,
          item.rawPayload,
          GameMedia.fromJson,
        ),
    ];
  }
}

final class BoardGameCatalogRepositoryCodec
    implements CatalogKindRepositoryCodec {
  const BoardGameCatalogRepositoryCodec();

  @override
  String get kind => 'boardgame';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, BoardGameMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return BoardGameRepository(db).updateMedia(
      BoardGameMedia.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await BoardGameRepository(db).search();
    return [
      for (final item in media)
        _projection(
          'boardgame',
          item.id.value,
          item.title,
          item.rawPayload,
          BoardGameMedia.fromJson,
        ),
    ];
  }
}

final class MovieCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MovieCatalogRepositoryCodec();

  @override
  String get kind => 'movie';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, MovieMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return MovieRepository(db).updateMedia(
      MovieMedia.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await MovieRepository(db).search();
    return [
      for (final item in media)
        _projection(
          'movie',
          item.id.value,
          item.title,
          item.rawPayload,
          MovieMedia.fromJson,
        ),
    ];
  }
}

final class TvCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const TvCatalogRepositoryCodec();

  @override
  String get kind => 'tv';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, TvSeries.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return TvRepository(db).updateSeries(
      TvSeries.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await TvRepository(db).search();
    return [
      for (final item in media)
        _projection(
          'tv',
          item.id,
          item.title,
          item.rawPayload,
          TvSeries.fromJson,
        ),
    ];
  }
}

final class AnimeCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const AnimeCatalogRepositoryCodec();

  @override
  String get kind => 'anime';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, AnimeMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return AnimeRepository(db).updateMedia(
      AnimeMedia.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await AnimeRepository(db).search();
    return [
      for (final item in media)
        _projection(
          'anime',
          item.id.value,
          item.title,
          item.rawPayload,
          AnimeMedia.fromJson,
        ),
    ];
  }
}

final class MusicCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MusicCatalogRepositoryCodec();

  @override
  String get kind => 'music';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      _withTypedMetadata(item, MusicRelease.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return MusicRepository(db).updateRelease(
      MusicRelease.fromJson(_payloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final releases = await MusicRepository(db).search();
    return [
      for (final item in releases)
        _projection(
          'music',
          item.id.value,
          item.title,
          item.rawPayload,
          MusicRelease.fromJson,
        ),
    ];
  }
}

Map<String, dynamic> _payloadFor(CatalogItem item) => {
      ...item.toSyncPayload(),
      // The envelope identity is authoritative. A persisted raw payload may
      // contain an absent/stale id, but typed repositories must always receive
      // the identity that the catalog repository is upserting.
      'id': item.id,
      'kind': item.kind,
};

CatalogItem _withTypedMetadata(
  CatalogItem item,
  Object? Function(Map<String, dynamic>) decode,
) {
  if (item.kindMetadata is! Map) return item;
  return item.withKindMetadata(decode(item.payload));
}

CatalogItem _projection(
  String kind,
  String? id,
  String title,
  Object? rawPayload,
  Object? Function(Map<String, dynamic>) decode,
) {
  final payload = rawPayload is Map
      ? Map<String, dynamic>.from(rawPayload)
      : <String, dynamic>{};
  payload['id'] ??= id ?? '';
  payload['kind'] ??= kind;
  payload['title'] ??= title;
  final item = CatalogItem.fromJson(payload);
  return item.withKindMetadata(decode(item.payload));
}
