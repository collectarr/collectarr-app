import 'groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/dto.dart';
import 'columns/catalog_columns.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/sorts/sorts.dart';
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
    MusicWorkspaceFields.backCover,
    MusicWorkspaceFields.coreId,
  ],
  columns: musicCatalogWorkspaceColumns,
  sorts: [
    if (MusicFieldIdentities.artistSummary.sortable) musicArtistSort(),
    if (MusicFieldIdentities.title.sortable) musicTitleSort(),
    if (MusicFieldIdentities.releaseDate.sortable)
      musicPartialDateSort(
        MusicCatalogWorkspaceFields.releaseDate,
        (dto) => dto.music.releaseDateParts,
        defaultAscending: false,
      ),
    musicEarliestDiscRecordingDateSort(),
    musicLatestDiscRecordingDateSort(),
    ...musicImageSorts(),
    musicFormatSort(),
    musicGenreSort(),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.coreId,
    ),
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
