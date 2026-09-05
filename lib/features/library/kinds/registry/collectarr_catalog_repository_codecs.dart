import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/remote/boardgame_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/remote/book_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/remote/game_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/remote/manga_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/remote/movie_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';

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
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return ComicRepository(db).updateMedia(
      ComicCoreMapper.fromWorkDto(
        ComicWorkDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await ComicRepository(db).search();
    return [
      for (final item in media)
        _projection('comic', item.id?.value, item.title, item.rawPayload),
    ];
  }
}

final class MangaCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MangaCatalogRepositoryCodec();

  @override
  String get kind => 'manga';

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return MangaRepository(db).updateMedia(
      MangaCoreMapper.fromWorkDto(
        MangaWorkDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await MangaRepository(db).search();
    return [
      for (final item in media)
        _projection('manga', item.id, item.title, item.rawPayload),
    ];
  }
}

final class BookCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const BookCatalogRepositoryCodec();

  @override
  String get kind => 'book';

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return BookRepository(db).updateMedia(
      BookCoreMapper.fromWorkDto(
        BookWorkDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await BookRepository(db).search();
    return [
      for (final item in media)
        _projection('book', item.id.value, item.title, item.rawPayload),
    ];
  }
}

final class GameCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const GameCatalogRepositoryCodec();

  @override
  String get kind => 'game';

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return GameRepository(db).updateMedia(
      GameCoreMapper.fromWorkDto(
        GameWorkDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await GameRepository(db).search();
    return [
      for (final item in media)
        _projection('game', item.id.value, item.title, item.rawPayload),
    ];
  }
}

final class BoardGameCatalogRepositoryCodec
    implements CatalogKindRepositoryCodec {
  const BoardGameCatalogRepositoryCodec();

  @override
  String get kind => 'boardgame';

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return BoardGameRepository(db).updateMedia(
      BoardGameCoreMapper.fromWorkDto(
        BoardGameWorkDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await BoardGameRepository(db).search();
    return [
      for (final item in media)
        _projection('boardgame', item.id.value, item.title, item.rawPayload),
    ];
  }
}

final class MovieCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MovieCatalogRepositoryCodec();

  @override
  String get kind => 'movie';

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return MovieRepository(db).updateMedia(
      MovieCoreMapper.fromWorkDto(
        MovieWorkDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await MovieRepository(db).search();
    return [
      for (final item in media)
        _projection('movie', item.id.value, item.title, item.rawPayload),
    ];
  }
}

final class TvCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const TvCatalogRepositoryCodec();

  @override
  String get kind => 'tv';

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return TvRepository(db).updateSeries(
      TvCoreMapper.fromSeriesDto(
        TvSeriesDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await TvRepository(db).search();
    return [
      for (final item in media)
        _projection('tv', item.id, item.title, item.rawPayload),
    ];
  }
}

final class AnimeCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const AnimeCatalogRepositoryCodec();

  @override
  String get kind => 'anime';

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return AnimeRepository(db).updateMedia(
      AnimeCoreMapper.fromSeriesDto(
        AnimeSeriesDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await AnimeRepository(db).search();
    return [
      for (final item in media)
        _projection('anime', item.id.value, item.title, item.rawPayload),
    ];
  }
}

final class MusicCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MusicCatalogRepositoryCodec();

  @override
  String get kind => 'music';

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return MusicRepository(db).updateRelease(
      MusicCoreMapper.fromReleaseDto(
        MusicReleaseDto.fromJson(_payloadFor(item)),
      ),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final releases = await MusicRepository(db).search();
    return [
      for (final item in releases)
        _projection('music', item.id.value, item.title, item.rawPayload),
    ];
  }
}

Map<String, dynamic> _payloadFor(CatalogItem item) => {
      'id': item.id,
      'kind': item.kind,
      ...item.toSyncPayload(),
    };

CatalogItem _projection(
  String kind,
  String? id,
  String title,
  Object? rawPayload,
) {
  final payload = rawPayload is Map
      ? Map<String, dynamic>.from(rawPayload)
      : <String, dynamic>{};
  payload['id'] ??= id ?? '';
  payload['kind'] ??= kind;
  payload['title'] ??= title;
  return typedCatalogItemFromMap(payload);
}
