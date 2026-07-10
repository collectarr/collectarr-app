import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/config/common_fields.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all library presentations declare complete group mode definitions', () {
    final registries = <String, AnyLibraryFieldRegistry>{
      'generic': const AnyLibraryFieldRegistry(),
      'books': libraryKindModuleForType(booksLibraryConfig).fields,
      'board games': libraryKindModuleForType(boardGamesLibraryConfig).fields,
      'comics': libraryKindModuleForType(comicsLibraryConfig).fields,
      'games': libraryKindModuleForType(gamesLibraryConfig).fields,
      'movies': libraryKindModuleForType(moviesLibraryConfig).fields,
      'music': libraryKindModuleForType(musicLibraryConfig).fields,
    };

    for (final entry in registries.entries) {
      final definitionModes = [
        for (final definition in entry.value.groups) definition.id.value,
      ];
      final uniqueDefinitionModes = definitionModes.toSet();

      expect(
        definitionModes.length,
        uniqueDefinitionModes.length,
        reason:
            '${entry.key} registry has duplicate group mode definitions.',
      );

      for (final mode in uniqueDefinitionModes) {
        expect(
          () => entry.value.groupDefinitionFor(mode),
          returnsNormally,
          reason:
              '${entry.key} registry is missing a definition for $mode.',
        );
      }
    }
  });

  test('all library presentations declare complete sort column definitions',
      () {
    final registries = <String, AnyLibraryFieldRegistry>{
      'generic': const AnyLibraryFieldRegistry(),
      'books': libraryKindModuleForType(booksLibraryConfig).fields,
      'board games': libraryKindModuleForType(boardGamesLibraryConfig).fields,
      'comics': libraryKindModuleForType(comicsLibraryConfig).fields,
      'games': libraryKindModuleForType(gamesLibraryConfig).fields,
      'movies': libraryKindModuleForType(moviesLibraryConfig).fields,
      'music': libraryKindModuleForType(musicLibraryConfig).fields,
    };
    final configuredSortColumns = <String, Set<String>>{
      'generic': commonSortDefinitions
          .map((definition) => definition.id)
          .toSet(),
      'books': booksLibraryConfig.availableSortColumns
          .map((c) => definitionIdFor(c))
          .toSet(),
      'board games': boardGamesLibraryConfig.availableSortColumns
          .map((c) => definitionIdFor(c))
          .toSet(),
      'comics': comicsLibraryConfig.availableSortColumns
          .map((c) => definitionIdFor(c))
          .toSet(),
      'games': gamesLibraryConfig.availableSortColumns
          .map((c) => definitionIdFor(c))
          .toSet(),
      'movies': moviesLibraryConfig.availableSortColumns
          .map((c) => definitionIdFor(c))
          .toSet(),
      'music': musicLibraryConfig.availableSortColumns
          .map((c) => definitionIdFor(c))
          .toSet(),
    };

    for (final entry in registries.entries) {
      final definitionColumns = [
        for (final definition in entry.value.sorts) definition.id,
      ];
      final uniqueDefinitionColumns = definitionColumns.toSet();
      final expectedColumns = configuredSortColumns[entry.key]!;

      expect(
        definitionColumns.length,
        uniqueDefinitionColumns.length,
        reason:
            '${entry.key} registry has duplicate sort column definitions.',
      );

      for (final column in expectedColumns) {
        expect(
          entry.value.sortDefinitionForId(column),
          isNotNull,
          reason:
              '${entry.key} registry is missing a sort definition for $column.',
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
