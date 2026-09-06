import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/legacy/anime_legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/legacy/boardgame_legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/book/data/legacy/book_legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/legacy/comic_legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/game/data/legacy/game_legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/legacy/manga_legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/legacy/movie_legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/music/data/legacy/music_legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/legacy/tv_legacy_owned_item_writer.dart';

/// Composition-root list of the temporary legacy Owned writers.
List<LegacyOwnedItemWriter> collectarrLegacyOwnedItemWriters(
  LocalDatabase database,
) {
  return [
    ComicLegacyOwnedItemWriter(database),
    MangaLegacyOwnedItemWriter(database),
    BookLegacyOwnedItemWriter(database),
    GameLegacyOwnedItemWriter(database),
    BoardGameLegacyOwnedItemWriter(database),
    MovieLegacyOwnedItemWriter(database),
    TvLegacyOwnedItemWriter(database),
    AnimeLegacyOwnedItemWriter(database),
    MusicLegacyOwnedItemWriter(database),
  ];
}
