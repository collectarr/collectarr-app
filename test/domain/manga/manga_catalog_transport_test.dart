import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a flat Catalog Item payload into typed Manga metadata', () {
    final item = CatalogItemDto.raw(
      id: 'manga-1',
      mediaKind: CatalogMediaKind.manga,
      kindData: const {
        'title': 'Vagabond',
        'sort_title': 'Vagabond',
        'release_date': '1998-09-03T00:00:00.000Z',
        'sort_title': 'Vagabond',
        'description': 'A wandering swordsman searches for meaning.',
        'first_publication_date': '1998-09-03T00:00:00Z',
        'original_language': 'ja',
        'original_publication_date': '1998-09-03T00:00:00Z',
        'status': 'hiatus',
        'subtitle': 'The Definitive Edition',
        'chapters': [
          {'id': 'chapter-1', 'number': 1, 'title': 'The Invincible'},
        ],
        'character_appearances': [
          {'name': 'Miyamoto Musashi', 'role': 'protagonist'},
        ],
        'contributions': [
          {'name': 'Takehiko Inoue', 'role': 'author'},
        ],
        'identifiers': [
          {'type': 'isbn', 'value': '978-1569317075'},
        ],
        'series': [
          {'id': 'series-vagabond', 'title': 'Vagabond'},
        ],
      },
    );

    final media = const MangaCatalogTransportCodec().decode(item);

    expect(media, isA<MangaMedia>());
    expect(media.id, 'manga-1');
    expect(media.title, 'Vagabond');
    expect(media.sortTitle, 'Vagabond');
    expect(media.firstPublicationDate, DateTime.utc(1998, 9, 3));
    expect(media.originalLanguage, 'ja');
    expect(media.originalPublicationDate, DateTime.utc(1998, 9, 3));
    expect(media.status, 'hiatus');
    expect(media.subtitle, 'The Definitive Edition');
    expect(
      Map<String, dynamic>.from(media.chapters.single as Map)['number'],
      1,
    );
    expect(
      Map<String, dynamic>.from(
          media.characterAppearances.single as Map)['name'],
      'Miyamoto Musashi',
    );
    expect(
      Map<String, dynamic>.from(media.contributions.single as Map)['role'],
      'author',
    );
    expect(
      Map<String, dynamic>.from(media.identifiers.single as Map)['value'],
      '978-1569317075',
    );
    expect(
      Map<String, dynamic>.from(media.series.single as Map)['id'],
      'series-vagabond',
    );
  });
}
