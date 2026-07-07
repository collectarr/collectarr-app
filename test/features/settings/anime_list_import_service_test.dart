import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/features/settings/anime_list_import_service.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses MAL-style anime and manga XML exports', () {
    const xml = '''
<myanimelist>
  <anime>
    <series_animedb_id>1</series_animedb_id>
    <series_title>Cowboy Bebop</series_title>
    <my_status>2</my_status>
    <my_score>9</my_score>
    <my_watched_episodes>26</my_watched_episodes>
    <my_start_date>2020-01-01</my_start_date>
    <my_finish_date>2020-01-10</my_finish_date>
  </anime>
  <manga>
    <series_mangadb_id>2</series_mangadb_id>
    <series_title>Death Note</series_title>
    <my_status>watching</my_status>
    <my_score>8</my_score>
    <my_read_chapters>12</my_read_chapters>
  </manga>
</myanimelist>
''';

    final service = AnimeListImportService();
    final rows = service.parseFileBytes(
      Uint8List.fromList(utf8.encode(xml)),
      fileName: 'mal.xml',
      provider: ProviderImportId.myAnimeList,
    );

    expect(rows, hasLength(2));
    expect(rows[0].sourceId, 'myanimelist:1');
    expect(rows[0].title, 'Cowboy Bebop');
    expect(rows[0].mediaKind, 'anime');
    expect(rows[0].status, ImportItemStatus.completed);
    expect(rows[0].rating, 90);
    expect(rows[0].progress, 26);
    expect(rows[0].startedAt?.toIso8601String(), '2020-01-01T00:00:00.000');
    expect(rows[0].finishedAt?.toIso8601String(), '2020-01-10T00:00:00.000');
    expect(rows[0].externalIds['myanimelist'], '1');

    expect(rows[1].sourceId, 'myanimelist:2');
    expect(rows[1].title, 'Death Note');
    expect(rows[1].mediaKind, 'manga');
    expect(rows[1].status, ImportItemStatus.inProgress);
    expect(rows[1].rating, 80);
    expect(rows[1].progress, 12);
  });
}
