import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

/// Seeds only vocabulary definitions owned by a concrete kind.
///
/// Kind values are captured rather than replaced so checked-in built-ins and
/// values discovered from the seeded catalog are both available.
Future<void> seedPickLists(PickListRepository repo) async {
  await _seedKindVocabularies(repo, 'anime', AnimeVocabularies.all);
  await _seedKindVocabularies(
    repo,
    'boardgame',
    BoardGameVocabularies.all,
  );
  await _seedKindVocabularies(repo, 'book', BookVocabularies.all);
  await _seedKindVocabularies(repo, 'comic', ComicVocabularies.all);
  await _seedKindVocabularies(repo, 'game', GameVocabularies.all);
  await _seedKindVocabularies(repo, 'manga', MangaVocabularies.all);
  await _seedKindVocabularies(repo, 'movie', MovieVocabularies.all);
  await _seedKindVocabularies(repo, 'music', MusicVocabularies.all);
  await _seedKindVocabularies(repo, 'tv', TvVocabularies.all);
}

/// Returns the number of built-in values that every kind-owned vocabulary
/// must contain after seeding. Empty definitions are intentionally omitted:
/// they are populated only from catalog data or user input.
Map<String, int> devSeedVocabularyMinimumCounts() {
  final result = <String, int>{};

  void add(Iterable<VocabularyDefinition<dynamic>> definitions) {
    for (final definition in definitions) {
      final count = definition.builtIns.length;
      if (count > 0) {
        result[definition.key] = count;
      }
    }
  }

  add(AnimeVocabularies.all);
  add(BoardGameVocabularies.all);
  add(BookVocabularies.all);
  add(ComicVocabularies.all);
  add(GameVocabularies.all);
  add(MangaVocabularies.all);
  add(MovieVocabularies.all);
  add(MusicVocabularies.all);
  add(TvVocabularies.all);
  return result;
}

Future<void> _seedKindVocabularies(
  PickListRepository repo,
  String mediaKind,
  Iterable<VocabularyDefinition<dynamic>> definitions,
) async {
  for (final definition in definitions) {
    final builtIns = [
      for (final value in definition.builtIns) value.toString(),
    ];
    if (builtIns.isEmpty) {
      continue;
    }
    await repo.captureValues(
      definition.key,
      builtIns,
      mediaKind: mediaKind,
    );
  }
}
