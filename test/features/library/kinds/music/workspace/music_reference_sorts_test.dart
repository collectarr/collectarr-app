import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_contribution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music offers the reference Images, Format and Genre sorts', () {
    final fields = musicKindWorkspace.fields;
    final available = musicKindWorkspace.availableSortColumnIdsForAllTargets;

    for (final (id, label, group) in [
      ('music.has_back', 'Has Back', 'Images'),
      ('music.has_front', 'Has Front', 'Images'),
      ('music.format_summary', 'Format', 'Main'),
      ('music.genre', 'Genre', 'Main'),
    ]) {
      expect(available, contains(id));
      final sort = fields.sortDefinitionForId(fields.decodeSortId(id))!;
      expect(sort.label, label);
      expect(sort.group, group);
    }
  });
}
