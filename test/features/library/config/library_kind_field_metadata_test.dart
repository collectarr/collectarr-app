import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/config/anime_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/tv/config/tv_field_identities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fields = <LibraryKindFieldMetadata>[
    ...AnimeFieldIdentities.all,
    ...BoardGameFieldIdentities.all,
    ...BookFieldIdentities.all,
    ...ComicFieldIdentities.all,
    ...GameFieldIdentities.all,
    ...MangaFieldIdentities.all,
    ...MovieFieldIdentities.all,
    ...MusicFieldIdentities.all,
    ...TvFieldIdentities.all,
  ];

  test('all registered kind fields have complete, unique semantic identity',
      () {
    final ids = fields.map((field) => field.id).toSet();

    expect(ids, hasLength(fields.length));
    for (final field in fields) {
      expect(field.id, isNotEmpty, reason: 'field ID');
      expect(field.label, isNotEmpty, reason: field.id);
      expect(field.sourcePath, isNotEmpty, reason: field.id);
    }
  });

  test('text cardinality is represented independently from value type', () {
    expect(MusicFieldIdentities.artist.valueType, LibraryFieldValueType.text);
    expect(
      MusicFieldIdentities.artist.cardinality,
      LibraryFieldCardinality.many,
    );
    expect(MusicFieldIdentities.genre.valueType, LibraryFieldValueType.text);
    expect(
      MusicFieldIdentities.genre.cardinality,
      LibraryFieldCardinality.many,
    );
    expect(MovieFieldIdentities.genre.valueType, LibraryFieldValueType.text);
    expect(
      MovieFieldIdentities.genre.cardinality,
      LibraryFieldCardinality.many,
    );
  });

  test('source and semantic path remain explicit for derived fields', () {
    expect(MusicFieldIdentities.format.source, LibraryFieldSource.derived);
    expect(MusicFieldIdentities.format.sourcePath, 'discs[].format');
    expect(BookFieldIdentities.releaseDate.source, LibraryFieldSource.derived);
    expect(BookFieldIdentities.releaseDate.sourcePath, 'release_date');
  });
}
