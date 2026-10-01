import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_transport_codec.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores a flat Board Game Catalog Item in the shared cache', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const codec = BoardGameCatalogTransportCodec();
    final item = CatalogItemDto.raw(
      id: 'boardgame-edition-1',
      mediaKind: CatalogMediaKind.boardgame,
      common: CatalogCommonDto(
        title: 'Brass: Birmingham — Deluxe Edition',
        releaseDate: DateTime.utc(2018, 10, 1),
      ),
      payload: const {
        'barcode': '123456789',
        'publisher': 'Roxley',
        'mechanics': ['Network Building'],
        'min_players': 2,
        'max_players': 4,
        'playing_time_minutes': 120,
        'edition_title': 'Deluxe Edition',
      },
    );

    await codec.upsertTransport(db, item);
    final stored = await codec.listTransport(db);
    final catalogItem = codec.decode(stored.single);

    expect(stored, hasLength(1));
    expect(catalogItem.id, 'boardgame-edition-1');
    expect(catalogItem.title, 'Brass: Birmingham — Deluxe Edition');
    expect(catalogItem.barcode, '123456789');
    expect(catalogItem.publisher, 'Roxley');
    expect(catalogItem.mechanics, ['Network Building']);
    expect(catalogItem.metadata.minPlayers, 2);
    expect(catalogItem.metadata.maxPlayers, 4);
    expect(catalogItem.metadata.rawPayload['edition_title'], 'Deluxe Edition');
  });
}
