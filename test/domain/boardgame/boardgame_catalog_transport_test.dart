import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores and decodes BoardGame catalog payloads through the shared cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const codec = BoardGameCatalogTransportCodec();
    final item = CatalogItemDto.raw(
      id: 'boardgame-1',
      mediaKind: CatalogMediaKind.boardgame,
      common: CatalogCommonDto(
        title: 'Brass: Birmingham',
        releaseDate: DateTime.utc(2018, 10, 1),
      ),
      payload: const {
        'barcode': '123456789',
        'publisher': 'Roxley',
        'mechanics': ['Network Building'],
        'editions': [
          {
            'id': 'edition-1',
            'title': 'Deluxe Edition',
            'work_id': 'boardgame-1',
            'min_players': 2,
            'max_players': 4,
            'playing_time_minutes': 120,
          },
        ],
      },
    );

    await codec.upsertTransport(db, item);
    final stored = await codec.listTransport(db);
    final media = codec.decode(stored.single);

    expect(stored, hasLength(1));
    expect(media.id, const BoardGameMediaId('boardgame-1'));
    expect(media.title, 'Brass: Birmingham');
    expect(media.barcode, '123456789');
    expect(media.mechanics, ['Network Building']);
    expect(media.editions, hasLength(1));
    expect(media.editions.single.id, 'edition-1');
    expect(media.editions.single.minPlayers, 2);
    expect(media.editions.single.maxPlayers, 4);
    expect(media.editions.single.playingTimeMinutes, 120);
  });
}
