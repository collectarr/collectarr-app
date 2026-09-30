import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/catalog_lookup_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
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
        kind: kind,
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
        kind: kind,
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
        kind: CatalogMediaKind.unknown,
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
  switch (kind) {
    case CatalogMediaKind.comic:
      await ComicRepository(db).updateMedia(
        ComicMedia(
          id: ComicMediaId(id),
          title: '${kind.apiValue} title',
          issueNumber: itemNumber,
          barcode: barcode,
        ),
      );
    case CatalogMediaKind.manga:
      await CatalogTransportRepository(db).upsertTransportItems([
        CatalogItemDto.fromJson({
          'id': id,
          'kind': kind.apiValue,
          'title': '${kind.apiValue} title',
          ...rawPayload,
        }),
      ]);
    case CatalogMediaKind.book:
      await CatalogTransportRepository(db).upsertTransportItems([
        CatalogItemDto.fromJson({
          'id': id,
          'kind': kind.apiValue,
          'title': '${kind.apiValue} title',
          ...rawPayload,
        }),
      ]);
    case CatalogMediaKind.game:
      await CatalogTransportRepository(db).upsertTransportItems([
        CatalogItemDto.fromJson({
          'id': id,
          'kind': kind.apiValue,
          'title': '${kind.apiValue} title',
          ...rawPayload,
        }),
      ]);
    case CatalogMediaKind.boardgame:
      await CatalogTransportRepository(db).upsertTransportItems([
        CatalogItemDto.fromJson({
          'id': id,
          'kind': kind.apiValue,
          'title': '${kind.apiValue} title',
          ...rawPayload,
        }),
      ]);
    case CatalogMediaKind.movie:
      await CatalogTransportRepository(db).upsertTransportItems([
        CatalogItemDto.fromJson({
          'id': id,
          'kind': kind.apiValue,
          'title': '${kind.apiValue} title',
          'item_number': itemNumber,
          if (barcode != null) 'barcode': barcode,
        }),
      ]);
    case CatalogMediaKind.tv:
      await TvRepository(db).updateSeries(
        TvSeries(
            id: id, title: '${kind.apiValue} title', rawPayload: rawPayload),
      );
    case CatalogMediaKind.anime:
      await AnimeRepository(db).updateMedia(
        AnimeMedia(
          id: AnimeMediaId(id),
          title: '${kind.apiValue} title',
          rawPayload: rawPayload,
        ),
      );
    case CatalogMediaKind.music:
      await CatalogTransportRepository(db).upsertTransportItems([
        CatalogItemDto.fromJson({
          'id': id,
          'kind': kind.apiValue,
          'title': '${kind.apiValue} title',
          'catalog_number': itemNumber,
          if (barcode != null) 'barcode': barcode,
        }),
      ]);
    case CatalogMediaKind.unknown:
      throw ArgumentError('Unknown test kind: ${kind.apiValue}');
  }
}
