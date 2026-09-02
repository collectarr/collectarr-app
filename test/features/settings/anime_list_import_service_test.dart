import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/settings/anime_list_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'parses MAL-style anime and manga XML exports into ProviderPersonalEntry',
      () {
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
    final entries = service.parseFileBytes(
      Uint8List.fromList(utf8.encode(xml)),
      fileName: 'mal.xml',
      provider: ProviderId.myAnimeList,
    );

    expect(entries, hasLength(2));
    expect(entries[0].remoteItemId, '1');
    expect(entries[0].title, 'Cowboy Bebop');
    expect(entries[0].kind, CatalogMediaKind.anime);
    expect(entries[0].status, ProviderEntryStatus.completed);
    expect(entries[0].rating, 90.0);
    expect(entries[0].progress, 26);
    expect(entries[0].startedAt?.toIso8601String(), '2020-01-01T00:00:00.000');
    expect(
        entries[0].completedAt?.toIso8601String(), '2020-01-10T00:00:00.000');
    expect(entries[0].externalIds['myanimelist'], '1');

    expect(entries[1].remoteItemId, '2');
    expect(entries[1].title, 'Death Note');
    expect(entries[1].kind, CatalogMediaKind.manga);
    expect(entries[1].status, ProviderEntryStatus.current);
    expect(entries[1].rating, 80.0);
    expect(entries[1].progress, 12);
  });
}
