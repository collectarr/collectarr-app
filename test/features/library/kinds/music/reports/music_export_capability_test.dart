import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
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

  test('Live / Studio export preserves the canonical boolean values', () {
    final album = MusicAlbum(
      title: 'Mixed Recording',
      discs: [
        MusicDisc(
            id: const MusicDiscId('studio'), discNumber: 1, isLive: false),
        MusicDisc(id: const MusicDiscId('live'), discNumber: 2, isLive: true),
      ],
    );
    final source = LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: const CatalogTargetRef(
          CatalogItemRef(kind: CatalogMediaKind.music, id: 'mixed-recording'),
        ),
        kindPresentationData: MusicWorkspaceData.fromMusic(album),
      ),
      personal: const PersonalOverlay(),
    );
    final item = LibraryProjectionItem.fromShelf(
      source,
      const MusicRegistration(),
    );
    final column = musicExportCapability.itemColumns.singleWhere(
      (column) => column.id == MusicWorkspaceFieldMetadata.isLive.id,
    );

    expect(
      MusicCatalogWorkspaceFields.liveStudio.getValue(
        LibraryProjectionContext(
          item: source.item,
          personal: source.personal,
          dto: item.dto as MusicWorkspaceProjection,
        ),
      ),
      {true, false},
    );
    expect(column.getValue(item), 'true | false');
  });
}
