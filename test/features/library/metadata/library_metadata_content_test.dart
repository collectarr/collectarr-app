import 'package:collectarr_app/features/library/config/planned_library_configs.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music metadata presentation exposes track count without track list', () {
    final presentation = buildLibraryMetadataPresentation(
      type: musicLibraryConfig,
      entry: LibraryWorkspaceEntry(
        id: 'music-1',
        mediaType: 'music',
        title: 'Discovery',
        seriesTitle: 'Daft Punk',
        publisher: 'Virgin',
        trackCount: 14,
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    expect(
      presentation.contextFacts
          .where((fact) => fact.label == 'Tracks')
          .map((fact) => fact.value),
      ['14'],
    );
  });
}