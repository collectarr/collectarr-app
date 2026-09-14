import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workspaces = [
    ('Book', bookKindWorkspace),
    ('Comic', comicKindWorkspace),
    ('BoardGame', boardGameKindWorkspace),
    ('Game', gameKindWorkspace),
    ('Music', musicKindWorkspace),
    ('Movie', movieKindWorkspace),
    ('Tv', tvKindWorkspace),
    ('Anime', animeKindWorkspace),
    ('Manga', mangaKindWorkspace),
  ];

  for (final (name, workspace) in workspaces) {
    group('$name Kind Schema Resolution', () {
      test('default visible columns resolve to valid columns', () {
        final registry = workspace.fields;
        final columnIds = registry.columns.map((c) => c.id.value).toSet();

        for (final defaultId in registry.defaultVisibleColumns) {
          final definition = registry.columnDefinitionForId(defaultId);
          expect(
            definition,
            isNotNull,
            reason:
                '$name default visible column ID "$defaultId" must resolve.',
          );
          expect(
            columnIds.contains(definition!.id.value),
            isTrue,
            reason:
                '$name resolved column ID "${definition.id.value}" for "$defaultId" must exist in columns list.',
          );
        }
      });

      test('default sort resolves to valid sort definition', () {
        final registry = workspace.fields;
        final defaultSortId = registry.defaultSort;
        final sort = registry.findSortDefinition(defaultSortId);
        expect(
          sort,
          isNotNull,
          reason:
              '$name defaultSortId "$defaultSortId" must resolve to a valid sort definition.',
        );
      });

      test('default group resolves to valid group definition', () {
        final registry = workspace.fields;
        final defaultGroupId = registry.defaultGroup;
        if (defaultGroupId != null) {
          final group = registry.findGroupDefinition(defaultGroupId);
          expect(
            group,
            isNotNull,
            reason:
                '$name default group ID "$defaultGroupId" must resolve to a valid group definition.',
          );
        }
      });
    });
  }
}
