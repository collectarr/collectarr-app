import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all library presentations declare complete group mode definitions', () {
    final presentations = <String, LibraryMediaPresentation>{
      'generic': genericLibraryMediaPresentation,
      'books': booksLibraryMediaPresentation,
      'board games': boardGamesLibraryMediaPresentation,
      'comics': comicsLibraryMediaPresentation,
      'games': gamesLibraryMediaPresentation,
      'movies': moviesLibraryMediaPresentation,
      'music': musicLibraryMediaPresentation,
    };

    for (final entry in presentations.entries) {
      final definitionModes = [
        for (final definition in entry.value.groupModeDefinitions)
          definition.mode,
      ];
      final uniqueDefinitionModes = definitionModes.toSet();
      final configuredModes = entry.value.groupModes.toSet();

      expect(
        definitionModes.length,
        uniqueDefinitionModes.length,
        reason:
            '${entry.key} presentation has duplicate group mode definitions.',
      );
      expect(
        uniqueDefinitionModes,
        configuredModes,
        reason:
            '${entry.key} presentation groupModeDefinitions must match groupModes exactly.',
      );

      for (final mode in entry.value.groupModes) {
        expect(
          () => entry.value.groupModeDefinitionFor(mode),
          returnsNormally,
          reason:
              '${entry.key} presentation is missing a definition for $mode.',
        );
      }
    }
  });

  test('all library presentations declare complete sort column definitions',
      () {
    final presentations = <String, LibraryMediaPresentation>{
      'generic': genericLibraryMediaPresentation,
      'books': booksLibraryMediaPresentation,
      'board games': boardGamesLibraryMediaPresentation,
      'comics': comicsLibraryMediaPresentation,
      'games': gamesLibraryMediaPresentation,
      'movies': moviesLibraryMediaPresentation,
      'music': musicLibraryMediaPresentation,
    };
    final configuredSortColumns = <String, Set<LibrarySortColumn>>{
      'generic': kAllLibrarySortColumns.toSet(),
      'books': kPlannedLibrarySortColumns.toSet(),
      'board games': kPlannedLibrarySortColumns.toSet(),
      'comics': kComicLibrarySortColumns.toSet(),
      'games': kPlannedLibrarySortColumns.toSet(),
      'movies': kPlannedLibrarySortColumns.toSet(),
      'music': kPlannedLibrarySortColumns.toSet(),
    };

    for (final entry in presentations.entries) {
      final definitionColumns = [
        for (final definition in entry.value.sortColumnDefinitions)
          definition.column,
      ];
      final uniqueDefinitionColumns = definitionColumns.toSet();
      final expectedColumns = configuredSortColumns[entry.key]!;

      expect(
        definitionColumns.length,
        uniqueDefinitionColumns.length,
        reason:
            '${entry.key} presentation has duplicate sort column definitions.',
      );
      expect(
        uniqueDefinitionColumns,
        expectedColumns,
        reason:
            '${entry.key} presentation sortColumnDefinitions must match available sort columns exactly.',
      );

      for (final column in expectedColumns) {
        expect(
          () => entry.value.sortColumnDefinitionFor(column),
          returnsNormally,
          reason:
              '${entry.key} presentation is missing a sort definition for $column.',
        );
      }
    }
  });

  test('fallback sort column labels stay readable for unknown columns', () {
    expect(librarySortColumnFallbackLabel(LibrarySortColumn.keyComic),
        'Key Comic');
    expect(librarySortColumnFallbackLabel(LibrarySortColumn.rawOrSlabbed),
        'Raw Or Slabbed');
  });
}
