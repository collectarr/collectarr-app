import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_library_entry_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music favorites reference canonical registered fields and sorts', () {
    final schema = musicLibraryEntryWorkspaceSchema;
    final sorts = schema.sorts.map((definition) => definition.id.value).toSet();
    final columns =
        schema.columns.map((definition) => definition.id.value).toSet();
    for (final preset in musicLibraryMediaPresentation.sortFavorites) {
      expect(preset.rules, isNotEmpty);
      for (final rule in preset.rules) {
        expect(sorts, contains(rule.column), reason: preset.label);
      }
    }
    for (final preset in musicLibraryMediaPresentation.columnFavorites) {
      expect(preset.columns, isNotEmpty);
      expect(columns.containsAll(preset.columns), isTrue, reason: preset.label);
      expect(preset.columns, contains(MusicFieldIds.title.value));
    }
    final recent = musicLibraryMediaPresentation.sortFavorites
        .singleWhere((preset) => preset.id == 'recent');
    expect(recent.rules.first.column, MusicFieldIds.addedAt.value);
    expect(recent.rules.first.ascending, isFalse);
    final value = musicLibraryMediaPresentation.sortFavorites
        .singleWhere((preset) => preset.id == 'value_desc');
    expect(value.rules.first.column, MusicFieldIds.marketValue.value);
  });
}
