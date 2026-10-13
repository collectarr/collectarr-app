import 'music_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'columns/music_catalog_workspace_columns.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/sorts/music_workspace_sorts.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

final musicCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  containedSearchValues: (dto) => dto.facts.trackSearchValues,
  fields: [
    ...MusicCatalogWorkspaceFields.all,
    MusicWorkspaceFields.status,
    MusicWorkspaceFields.cover,
  ],
  columns: musicCatalogWorkspaceColumns,
  sorts: [
    if (MusicFieldIdentities.artistSummary.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicCatalogWorkspaceFields.artistSummary,
      ),
    if (MusicFieldIdentities.title.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicCatalogWorkspaceFields.title,
      ),
    if (MusicFieldIdentities.releaseDate.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
        MusicCatalogWorkspaceFields.releaseDate,
        defaultAscending: false,
      ),
    musicEarliestDiscRecordingDateSort(),
    musicLatestDiscRecordingDateSort(),
    sortFromField<MusicKind, MusicWorkspaceProjection, num>(
      MusicCatalogWorkspaceFields.trackCount,
      defaultAscending: false,
    ),
  ],
  groups: musicWorkspaceGroupDefinitions(includePersonal: false),
  primaryColumn: MusicCatalogWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.artistSummary,
    MusicFieldIds.title,
    MusicFieldIds.releaseDate,
    MusicFieldIds.discCount,
    MusicFieldIds.trackCount,
    MusicFieldIds.length,
    MusicFieldIds.genre,
    MusicFieldIds.publisher,
  },
  defaultSort: LibrarySortId<MusicKind>(
    MusicCatalogWorkspaceFields.artistSummary.id.value,
  ),
  defaultGroup: LibraryGroupId<MusicKind, Object?>(
    MusicCatalogWorkspaceFields.artist.id.value,
  ),
);
