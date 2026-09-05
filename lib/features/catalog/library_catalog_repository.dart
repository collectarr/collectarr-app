import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/library_catalog_derived_data_service.dart';
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
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';

/// Reads and writes the kind-owned catalog graphs.
///
/// This is the migration boundary for callers that still need a common
/// [CatalogItem] projection. No catalog payload is stored by this class; the
/// typed kind repositories own the durable representation.
final class LibraryCatalogRepository {
  const LibraryCatalogRepository(this._db);

  final LocalDatabase _db;

  Future<void> upsertMetadataItems(List<CatalogItem> items) => upsertAll(items);

  Future<void> upsertAll(
    Iterable<dynamic> items, {
    bool captureDerivedData = true,
  }) async {
    final catalogItems = [
      for (final item in items)
        if (item is CatalogItem) typedCatalogItemFromCatalogItem(item),
    ];
    if (catalogItems.isEmpty) return;

    for (final item in catalogItems) {
      await _upsertItem(item);
    }
    if (captureDerivedData) {
      await LibraryCatalogDerivedDataService(
        _db,
        contributors: defaultPickListDefinitionContributors,
      ).capture(catalogItems);
    }
  }

  Future<Map<String, CatalogItem>> findByIds(Iterable<String> ids) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return const {};
    final result = <String, CatalogItem>{};
    for (final item in await _allItems()) {
      if (wanted.contains(item.id)) result[item.id] = item;
    }
    return result;
  }

  Future<List<CatalogItem>> findAll({String? kind}) async {
    final normalizedKind = kind?.trim().toLowerCase();
    return [
      for (final item in await _allItems())
        if (normalizedKind == null ||
            normalizedKind.isEmpty ||
            item.kind == normalizedKind)
          item,
    ];
  }

  Future<CatalogItem?> findById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    return (await findByIds([normalized]))[normalized];
  }

  Future<CatalogItem?> findByBarcode(String barcode, {String? kind}) async {
    final compact = _compactBarcode(barcode);
    if (compact.isEmpty) return null;
    final normalizedKind = kind?.trim().toLowerCase();
    for (final item in await _allItems()) {
      if (normalizedKind != null &&
          normalizedKind.isNotEmpty &&
          item.kind != normalizedKind) {
        continue;
      }
      if (_compactBarcode(item.barcode ?? '') == compact) return item;
    }
    return null;
  }

  Future<CatalogItem?> findByTitleAndIssue({
    required String title,
    required String? itemNumber,
    String? kind,
  }) async {
    final normalizedTitle = title.trim().toLowerCase();
    if (normalizedTitle.isEmpty) return null;
    final normalizedKind = kind?.trim().toLowerCase();
    final normalizedItemNumber = itemNumber?.trim();
    for (final item in await _allItems()) {
      if (normalizedKind != null &&
          normalizedKind.isNotEmpty &&
          item.kind != normalizedKind) {
        continue;
      }
      if (item.title.trim().toLowerCase() != normalizedTitle) continue;
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          item.itemNumber?.trim() != normalizedItemNumber) {
        continue;
      }
      return item;
    }
    return null;
  }

  Future<void> _upsertItem(CatalogItem item) async {
    final payload = {
      'id': item.id,
      'kind': item.kind,
      ...item.toSyncPayload(),
    };
    switch (item.mediaKind) {
      case CatalogMediaKind.comic:
        await ComicRepository(_db).updateMedia(
          ComicCoreMapper.fromWorkDto(ComicWorkDto.fromJson(payload)),
        );
      case CatalogMediaKind.manga:
        await MangaRepository(_db).updateMedia(
          MangaCoreMapper.fromWorkDto(MangaWorkDto.fromJson(payload)),
        );
      case CatalogMediaKind.book:
        await BookRepository(_db).updateMedia(
          BookCoreMapper.fromWorkDto(BookWorkDto.fromJson(payload)),
        );
      case CatalogMediaKind.game:
        await GameRepository(_db).updateMedia(
          GameCoreMapper.fromWorkDto(GameWorkDto.fromJson(payload)),
        );
      case CatalogMediaKind.boardgame:
        await BoardGameRepository(_db).updateMedia(
          BoardGameCoreMapper.fromWorkDto(BoardGameWorkDto.fromJson(payload)),
        );
      case CatalogMediaKind.movie:
        await MovieRepository(_db).updateMedia(
          MovieCoreMapper.fromWorkDto(MovieWorkDto.fromJson(payload)),
        );
      case CatalogMediaKind.tv:
        await TvRepository(_db).updateSeries(
          TvCoreMapper.fromSeriesDto(TvSeriesDto.fromJson(payload)),
        );
      case CatalogMediaKind.anime:
        await AnimeRepository(_db).updateMedia(
          AnimeCoreMapper.fromSeriesDto(AnimeSeriesDto.fromJson(payload)),
        );
      case CatalogMediaKind.music:
        await MusicRepository(_db).updateRelease(
          MusicCoreMapper.fromReleaseDto(MusicReleaseDto.fromJson(payload)),
        );
      case CatalogMediaKind.unknown:
        break;
    }
  }

  Future<List<CatalogItem>> _allItems() async {
    final result = <CatalogItem>[];

    for (final media in await ComicRepository(_db).search()) {
      result.add(
          _fromDomain('comic', media.id?.value, media.title, media.rawPayload));
    }
    for (final media in await MangaRepository(_db).search()) {
      result.add(_fromDomain('manga', media.id, media.title, media.rawPayload));
    }
    for (final media in await BookRepository(_db).search()) {
      result.add(
          _fromDomain('book', media.id.value, media.title, media.rawPayload));
    }
    for (final media in await GameRepository(_db).search()) {
      result.add(
          _fromDomain('game', media.id.value, media.title, media.rawPayload));
    }
    for (final media in await BoardGameRepository(_db).search()) {
      result.add(_fromDomain(
          'boardgame', media.id.value, media.title, media.rawPayload));
    }
    for (final media in await MovieRepository(_db).search()) {
      result.add(
          _fromDomain('movie', media.id.value, media.title, media.rawPayload));
    }
    for (final media in await TvRepository(_db).search()) {
      result.add(_fromDomain('tv', media.id, media.title, media.rawPayload));
    }
    for (final media in await AnimeRepository(_db).search()) {
      result.add(
          _fromDomain('anime', media.id.value, media.title, media.rawPayload));
    }
    for (final release in await MusicRepository(_db).search()) {
      result.add(_fromDomain(
          'music', release.id.value, release.title, release.rawPayload));
    }
    return result;
  }

  CatalogItem _fromDomain(
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

  static String _compactBarcode(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
