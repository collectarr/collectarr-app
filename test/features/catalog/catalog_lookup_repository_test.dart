import 'package:collectarr_app/core/db/local_database.dart';
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
    const kinds = [
      'comic',
      'manga',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'anime',
      'music',
    ];

    for (final kind in kinds) {
      await _seedTypedItem(
        db,
        kind: kind,
        id: '$kind-barcode',
        barcode: '978-0-306-40615-${kinds.indexOf(kind)}',
        itemNumber: '42',
      );
    }

    for (final kind in kinds) {
      final hit = await lookup.findByBarcode(
        '978 0 306 40615 ${kinds.indexOf(kind)}',
        kind: kind,
      );
      expect(hit, isNotNull, reason: kind);
      expect(hit!.ref.id, '$kind-barcode');
      expect(hit.kind.apiValue, kind);
    }
  });

  test('dispatches title and item number lookup to every typed kind', () async {
    const kinds = [
      'comic',
      'manga',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'anime',
      'music',
    ];

    for (final kind in kinds) {
      await _seedTypedItem(
        db,
        kind: kind,
        id: '$kind-title',
        itemNumber: '42',
      );
    }

    for (final kind in kinds) {
      final hit = await lookup.findByTitleAndItemNumber(
        title: '  $kind   title ',
        itemNumber: '42',
        kind: kind,
      );
      expect(hit, isNotNull, reason: kind);
      expect(hit!.ref.id, '$kind-title');
      expect(hit.subtitle, '42');
    }
  });

  test('unknown kind and empty identifiers return no match', () async {
    expect(await lookup.findByBarcode('---'), isNull);
    expect(await lookup.findByBarcode('123', kind: 'unknown'), isNull);
    expect(
      await lookup.findByTitleAndItemNumber(
        title: '   ',
        itemNumber: null,
      ),
      isNull,
    );
  });
}

Future<void> _seedTypedItem(
  LocalDatabase db, {
  required String kind,
  required String id,
  String? barcode,
  required String itemNumber,
}) async {
  final rawPayload = <String, dynamic>{
    if (barcode != null) 'barcode': barcode,
    'item_number': itemNumber,
    'edition': itemNumber,
  };
  switch (kind) {
    case 'comic':
      await ComicRepository(db).updateMedia(
        ComicMedia(
          id: ComicMediaId(id),
          title: '$kind title',
          issueNumber: itemNumber,
          barcode: barcode,
        ),
      );
    case 'manga':
      await MangaRepository(db).updateMedia(
        MangaMedia(id: id, title: '$kind title', rawPayload: rawPayload),
      );
    case 'book':
      await BookRepository(db).updateMedia(
        BookMedia(
          id: BookMediaId(id),
          title: '$kind title',
          rawPayload: rawPayload,
        ),
      );
    case 'game':
      await GameRepository(db).updateMedia(
        GameMedia(
            id: GameMediaId(id), title: '$kind title', rawPayload: rawPayload),
      );
    case 'boardgame':
      await BoardGameRepository(db).updateMedia(
        BoardGameMedia(
          id: BoardGameMediaId(id),
          title: '$kind title',
          rawPayload: rawPayload,
        ),
      );
    case 'movie':
      await MovieRepository(db).updateMedia(
        MovieMedia(
          id: MovieMediaId(id),
          title: '$kind title',
          rawPayload: rawPayload,
        ),
      );
    case 'tv':
      await TvRepository(db).updateSeries(
        TvSeries(id: id, title: '$kind title', rawPayload: rawPayload),
      );
    case 'anime':
      await AnimeRepository(db).updateMedia(
        AnimeMedia(
          id: AnimeMediaId(id),
          title: '$kind title',
          rawPayload: rawPayload,
        ),
      );
    case 'music':
      await MusicRepository(db).updateRelease(
        MusicRelease(
          id: MusicReleaseId(id),
          title: '$kind title',
          catalogNumber: itemNumber,
          barcode: barcode,
        ),
      );
  }
}
