import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flat Comic Catalog Item fields map into the Comic domain', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'comic-1',
      'kind': 'comic',
      'title': 'Saga #1',
      'series_title': 'Saga',
      'issue_number': '1',
      'synopsis': 'A family caught in an interstellar war.',
      'release_date': '2012-03-14T00:00:00Z',
      'language': 'en',
      'contributors': [
        {'name': 'Brian K. Vaughan', 'role': 'writer'},
        {'name': 'Fiona Staples', 'role': 'artist'},
      ],
      'sort_title': 'Saga',
    });

    final comic = ComicCoreMapper.fromCatalogItem(dto);

    expect(comic.id, const ComicMediaId('comic-1'));
    expect(comic.title, 'Saga #1');
    expect(comic.seriesTitle, 'Saga');
    expect(comic.issueNumber, '1');
    expect(comic.sortTitle, 'Saga');
    expect(comic.synopsis, 'A family caught in an interstellar war.');
    expect(comic.releaseDate, DateTime.utc(2012, 3, 14));
    expect(comic.language, 'en');
    expect(comic.creatorCredits, hasLength(2));
    expect(comic.creatorCredits.first.role, 'writer');
    expect(comic.creatorCredits.last.name, 'Fiona Staples');
  });
}
