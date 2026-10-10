import 'columns/music_catalog_workspace_columns.dart';
import 'music_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/columns/music_workspace_columns.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/presentation/music_workspace_formatting.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/sorts/music_workspace_sorts.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

final musicLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  fields: [
    ...MusicCatalogWorkspaceFields.all,
    ...MusicPersonalWorkspaceFields.all,
    MusicWorkspaceFields.status,
    MusicWorkspaceFields.cover,
  ],
  columns: [
    ...musicCatalogWorkspaceColumns,
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicPersonalWorkspaceFields.condition,
      group: 'Personal',
      defaultWidth: 124,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicPersonalWorkspaceFields.grade,
      group: 'Personal',
      defaultWidth: 96,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicPersonalWorkspaceFields.location,
      group: 'Personal',
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicPersonalWorkspaceFields.storageSummary,
      group: 'Personal',
      defaultWidth: 150,
    ),
    musicPricePaidColumn(field: MusicPersonalWorkspaceFields.pricePaid),
    musicMarketValueColumn(field: MusicPersonalWorkspaceFields.marketValue),
    musicPurchaseDateColumn(field: MusicPersonalWorkspaceFields.purchaseDate),
    columnFromField<MusicKind, MusicWorkspaceProjection, int?>(
      MusicPersonalWorkspaceFields.listenCount,
      group: 'Activity',
      isNumeric: true,
      defaultWidth: 96,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
      MusicPersonalWorkspaceFields.lastListened,
      cellValue: (context) => Text(
        formatMusicDate(
          MusicPersonalWorkspaceFields.lastListened.getValue(context),
        ),
      ),
      group: 'Activity',
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicPersonalWorkspaceFields.indexNumber,
      group: 'Personal',
      isNumeric: true,
      defaultWidth: 96,
    ),
    musicRatingColumn(field: MusicPersonalWorkspaceFields.rating),
    musicWishlistColumn(field: MusicPersonalWorkspaceFields.wishlist),
    musicUpdatedAtColumn(field: MusicPersonalWorkspaceFields.updatedAt),
    musicAddedAtColumn(field: MusicPersonalWorkspaceFields.addedAt),
    musicSignedByColumn(field: MusicPersonalWorkspaceFields.signedBy),
    musicLastCleanedColumn(field: MusicPersonalWorkspaceFields.lastCleaned),
  ],
  sorts: [
    musicStatusSort(),
    if (MusicFieldIdentities.artistSummary.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicCatalogWorkspaceFields.artistSummary,
      ),
    if (MusicFieldIdentities.title.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicCatalogWorkspaceFields.title,
      ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCatalogWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
    musicEarliestDiscRecordingDateSort(),
    musicLatestDiscRecordingDateSort(),
    if (MusicFieldIdentities.publisher.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicCatalogWorkspaceFields.publisher,
      ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicPersonalWorkspaceFields.condition,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicPersonalWorkspaceFields.grade,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicPersonalWorkspaceFields.location,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicPersonalWorkspaceFields.storageSummary,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicPersonalWorkspaceFields.pricePaid,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicPersonalWorkspaceFields.marketValue,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicPersonalWorkspaceFields.purchaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicPersonalWorkspaceFields.indexNumber,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicPersonalWorkspaceFields.updatedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicPersonalWorkspaceFields.addedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicPersonalWorkspaceFields.lastCleaned,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicPersonalWorkspaceFields.listenCount,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicPersonalWorkspaceFields.lastListened,
      defaultAscending: false,
    ),
  ],
  groups: musicWorkspaceGroupDefinitions(includePersonal: true),
  primaryColumn: MusicCatalogWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artistSummary,
    MusicFieldIds.title,
    MusicFieldIds.condition,
    MusicFieldIds.grade,
    MusicFieldIds.location,
    MusicFieldIds.storageSummary,
    MusicFieldIds.pricePaid,
    MusicFieldIds.marketValue,
    MusicFieldIds.purchaseDate,
    MusicFieldIds.indexNumber,
    MusicFieldIds.listenCount,
    MusicFieldIds.lastListened,
    MusicFieldIds.rating,
    MusicFieldIds.updatedAt,
  },
  defaultSort: LibrarySortId<MusicKind>(
    MusicCatalogWorkspaceFields.artistSummary.id.value,
  ),
  defaultGroup: LibraryGroupId<MusicKind, Object?>(
    MusicCatalogWorkspaceFields.artist.id.value,
  ),
);
