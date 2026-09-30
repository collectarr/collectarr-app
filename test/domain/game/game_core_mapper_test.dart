import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flat Game Catalog Item preserves kind-owned fields', () {
    final item = CatalogItemDto.fromJson({
      'id': 'game-1',
      'kind': 'game',
      'title': 'Zelda',
      'platforms': ['Switch'],
      'identifiers': ['IGDB:1'],
      'developers': ['Nintendo'],
      'genres': ['Adventure'],
      'age_rating': 'E10+',
      'release_date': '2026-01-02',
      'barcode': '1234567890123',
      'edition_title': 'Launch Edition',
    });
    final metadata = GameCatalogMetadata.fromJson(item.payload);

    expect(item.identity.id, 'game-1');
    expect(item.mediaKind, CatalogMediaKind.game);
    expect(metadata.title, 'Zelda');
    expect(metadata.platforms, ['Switch']);
    expect(metadata.developers, ['Nintendo']);
    expect(metadata.genres, ['Adventure']);
    expect(metadata.ageRating, 'E10+');
    expect(metadata.releaseDate, DateTime(2026, 1, 2));
    expect(metadata.barcode, '1234567890123');
    expect(metadata.edition, 'Launch Edition');
  });

  test('flat catalog identity keeps a non-Game kind explicit', () {
    final item = CatalogItemDto.fromJson({
      'id': 'book-1',
      'kind': 'book',
      'title': 'The Hobbit',
    });

    expect(item.mediaKind, CatalogMediaKind.book);
  });
}
