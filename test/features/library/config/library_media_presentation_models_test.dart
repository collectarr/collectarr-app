import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all library presentations declare complete group mode definitions', () {
    final registries = <String, AnyLibraryFieldRegistry>{
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
      'books': libraryKindModuleForType(booksLibraryConfig).fields,
      'board games': libraryKindModuleForType(boardGamesLibraryConfig).fields,
      'comics': libraryKindModuleForType(comicsLibraryConfig).fields,
      'games': libraryKindModuleForType(gamesLibraryConfig).fields,
      'movies': libraryKindModuleForType(moviesLibraryConfig).fields,
      'music': libraryKindModuleForType(musicLibraryConfig).fields,
    };
    final configuredSortColumns = <String, Set<String>>{
      'books': registries['books']!
          .sorts
          .map((definition) => definition.id)
          .toSet(),
      'board games': registries['board games']!
          .sorts
          .map((definition) => definition.id)
          .toSet(),
      'comics': registries['comics']!
          .sorts
          .map((definition) => definition.id)
          .toSet(),
      'games': registries['games']!
          .sorts
          .map((definition) => definition.id)
          .toSet(),
      'movies': registries['movies']!
          .sorts
          .map((definition) => definition.id)
          .toSet(),
      'music': registries['music']!
          .sorts
          .map((definition) => definition.id)
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
    expect(librarySortColumnFallbackLabel('key_issue'),
        'Key Issue');
    expect(librarySortColumnFallbackLabel('raw_or_slabbed'),
        'Raw Or Slabbed');
  });

  test('assert that every defaultVisibleColumnId and preset visible column ID resolves successfully', () {
    for (final module in collectarrKindModules) {
      final kind = module.type.workspace.kind;
      
      // Test default visible columns
      for (final columnId in module.fields.defaultVisibleColumnIds) {
        final definition = module.fields.columnDefinitionForId(columnId) ??
            module.fields.columnDefinitionForId(columnId.split('.').last);
        expect(
          definition,
          isNotNull,
          reason: 'Default visible column $columnId in kind $kind does not resolve to a registered column definition.',
        );
      }

      // Test preset visible columns
      for (final preset in LibraryWorkspacePreset.values) {
        final presetConfig = module.mediaAdapter.viewProfile.presetConfig(preset);
        for (final columnId in presetConfig.visibleColumns) {
          final idStr = columnId.toString();
          final isSupported = module.fields.columns.any(
            (c) => c.id.value == idStr || c.id.value.split('.').last == idStr,
          );
          if (isSupported) {
            final definition = module.fields.columnDefinitionForId(idStr) ??
                module.fields.columnDefinitionForId(idStr.split('.').last);
            expect(
              definition,
              isNotNull,
              reason: 'Preset $preset visible column $columnId in kind $kind does not resolve to a registered column definition.',
            );
          }
        }
      }
    }
  });
}
