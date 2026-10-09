import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/reports/music_export_capability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music export exposes summaries separately from contained fields', () {
    final columns = {
      for (final column in musicExportCapability.itemColumns) column.id: column,
    };

    expect(columns, contains(MusicFieldIdentities.formatSummary.id));
    expect(columns, contains(MusicFieldIdentities.discFormat.id));
    expect(
      columns[MusicFieldIdentities.formatSummary.id]!.label,
      'Format Summary',
    );
    expect(columns[MusicFieldIdentities.discFormat.id]!.label, 'Disc Format');
    expect(columns, contains(MusicWorkspaceFieldMetadata.recordingYear.id));
    expect(
      columns[MusicWorkspaceFieldMetadata.recordingYear.id]!.label,
      'Disc Recording Year',
    );
  });

  test('every exportable contained Music field has a semantic export column',
      () {
    final columns = {
      for (final column in musicExportCapability.itemColumns) column.id: column,
    };
    final containedFields = [
      MusicWorkspaceFieldMetadata.discFormatFamily,
      MusicWorkspaceFieldMetadata.recordingDate,
      MusicWorkspaceFieldMetadata.recordingMonth,
      MusicWorkspaceFieldMetadata.recordingYear,
      MusicWorkspaceFieldMetadata.earliestDiscRecordingDate,
      MusicWorkspaceFieldMetadata.latestDiscRecordingDate,
      MusicWorkspaceFieldMetadata.isLive,
      MusicWorkspaceFieldMetadata.recordingLocations,
      MusicWorkspaceFieldMetadata.spars,
      MusicWorkspaceFieldMetadata.sound,
      MusicWorkspaceFieldMetadata.vinylColor,
      MusicWorkspaceFieldMetadata.rpm,
      MusicWorkspaceFieldMetadata.creditContributor,
      MusicWorkspaceFieldMetadata.creditRole,
      MusicWorkspaceFieldMetadata.creditInstrument,
      MusicWorkspaceFieldMetadata.trackComposition,
    ];

    for (final field in containedFields) {
      expect(field.exportable, isTrue, reason: field.id);
      expect(columns, contains(field.id), reason: field.id);
      expect(columns[field.id]!.defaultVisible, isFalse, reason: field.id);
    }
  });
}
