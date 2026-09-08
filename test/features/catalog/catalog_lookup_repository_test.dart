import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_lookup_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late CatalogLookupRepository lookup;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    lookup = CatalogLookupRepository(db);
  });

  tearDown(() => db.close());

  test('dispatches barcode lookup to every typed kind', () async {
    const kinds = <CatalogMediaKind>[
      CatalogMediaKind.comic,
      CatalogMediaKind.manga,
      CatalogMediaKind.book,
      CatalogMediaKind.game,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
      CatalogMediaKind.anime,
      CatalogMediaKind.music,
    ];

    for (final kind in kinds) {
      await _seedTypedItem(
        db,
        kind: kind,
        id: '${kind.apiValue}-barcode',
        barcode: '978-0-306-40615-${kinds.indexOf(kind)}',
        itemNumber: '42',
      );
    }

    for (final kind in kinds) {
      final hit = await lookup.resolve(
        CatalogLookupQuery(
          value: '978 0 306 40615 ${kinds.indexOf(kind)}',
        ),
        kind: kind.apiValue,
      );
      expect(hit, isNotNull, reason: kind.apiValue);
      expect(hit!.ref.id, '${kind.apiValue}-barcode');
      expect(hit.kind, kind);
    }
  });

  test('dispatches title and item number lookup to every typed kind', () async {
    const kinds = <CatalogMediaKind>[
      CatalogMediaKind.comic,
      CatalogMediaKind.manga,
      CatalogMediaKind.book,
      CatalogMediaKind.game,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
      CatalogMediaKind.anime,
      CatalogMediaKind.music,
    ];

    for (final kind in kinds) {
      await _seedTypedItem(
        db,
        kind: kind,
        id: '${kind.apiValue}-title',
        itemNumber: '42',
      );
    }

    for (final kind in kinds) {
      final hit = await lookup.resolve(
        CatalogLookupQuery(title: '  ${kind.apiValue}   title ', value: '42'),
        kind: kind.apiValue,
      );
      expect(hit, isNotNull, reason: kind.apiValue);
      expect(hit!.ref.id, '${kind.apiValue}-title');
      expect(hit.subtitle, '42');
    }
  });

  test('unknown kind and empty identifiers return no match', () async {
    expect(
      await lookup.resolve(const CatalogLookupQuery(value: '---')),
      isNull,
    );
    expect(
      await lookup.resolve(
        const CatalogLookupQuery(value: '123'),
        kind: CatalogMediaKind.unknown.apiValue,
      ),
      isNull,
    );
    expect(
      await lookup.resolve(const CatalogLookupQuery(title: '   ')),
      isNull,
    );
  });
}

Future<void> _seedTypedItem(
  LocalDatabase db, {
  required CatalogMediaKind kind,
  required String id,
  String? barcode,
  required String itemNumber,
}) async {
  final rawPayload = <String, dynamic>{
    if (barcode != null) 'barcode': barcode,
    'item_number': itemNumber,
    'edition': itemNumber,
  };
  final seeders = <CatalogMediaKind, Future<void> Function()>{
    CatalogMediaKind.comic: () => ComicRepository(db).updateMedia(
          ComicMedia(
            id: ComicMediaId(id),
            title: '${kind.apiValue} title',
            issueNumber: itemNumber,
            barcode: barcode,
          ),
        ),
    CatalogMediaKind.manga: () => MangaRepository(db).updateMedia(
          MangaMedia(
              id: id, title: '${kind.apiValue} title', rawPayload: rawPayload),
        ),
    CatalogMediaKind.book: () => BookRepository(db).updateMedia(
          BookMedia(
            id: BookMediaId(id),
            title: '${kind.apiValue} title',
            rawPayload: rawPayload,
          ),
        ),
    CatalogMediaKind.game: () => GameRepository(db).updateMedia(
          GameMedia(
              id: GameMediaId(id),
              title: '${kind.apiValue} title',
              rawPayload: rawPayload),
        ),
    CatalogMediaKind.boardgame: () => BoardGameRepository(db).updateMedia(
          BoardGameMedia(
            id: BoardGameMediaId(id),
            title: '${kind.apiValue} title',
            rawPayload: rawPayload,
          ),
        ),
    CatalogMediaKind.movie: () => MovieRepository(db).updateMedia(
          MovieMedia(
            id: MovieMediaId(id),
            title: '${kind.apiValue} title',
            rawPayload: rawPayload,
          ),
        ),
    CatalogMediaKind.tv: () => TvRepository(db).updateSeries(
          TvSeries(
              id: id, title: '${kind.apiValue} title', rawPayload: rawPayload),
        ),
    CatalogMediaKind.anime: () => AnimeRepository(db).updateMedia(
          AnimeMedia(
            id: AnimeMediaId(id),
            title: '${kind.apiValue} title',
            rawPayload: rawPayload,
          ),
        ),
    CatalogMediaKind.music: () => MusicRepository(db).updateRelease(
          MusicRelease(
            id: MusicReleaseId(id),
            title: '${kind.apiValue} title',
            catalogNumber: itemNumber,
            barcode: barcode,
          ),
        ),
  };
  final seed = seeders[kind];
  if (seed == null) {
    throw ArgumentError('Unknown test kind: ${kind.apiValue}');
  }
  await seed();
}
