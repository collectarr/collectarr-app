import 'music_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_library_entry_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

final musicLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  fields: [
    MusicLibraryEntryWorkspaceFields.title,
    MusicLibraryEntryWorkspaceFields.artist,
    MusicLibraryEntryWorkspaceFields.publisher,
    MusicLibraryEntryWorkspaceFields.condition,
    MusicLibraryEntryWorkspaceFields.grade,
    MusicLibraryEntryWorkspaceFields.location,
    MusicLibraryEntryWorkspaceFields.storage,
    MusicLibraryEntryWorkspaceFields.pricePaid,
    MusicLibraryEntryWorkspaceFields.marketValue,
    MusicLibraryEntryWorkspaceFields.purchaseDate,
    MusicLibraryEntryWorkspaceFields.indexNumber,
    MusicLibraryEntryWorkspaceFields.status,
    MusicLibraryEntryWorkspaceFields.rating,
    MusicLibraryEntryWorkspaceFields.wishlist,
    MusicLibraryEntryWorkspaceFields.updatedAt,
    MusicLibraryEntryWorkspaceFields.addedAt,
    MusicLibraryEntryWorkspaceFields.signedBy,
    MusicLibraryEntryWorkspaceFields.lastCleaned,
  ],
  columns: [
    musicStatusColumn(field: MusicLibraryEntryWorkspaceFields.status),
    musicCoverColumn(field: MusicLibraryEntryWorkspaceFields.cover),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.publisher,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.condition,
      group: 'Personal',
      defaultWidth: 124,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.grade,
      group: 'Personal',
      defaultWidth: 96,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.location,
      group: 'Personal',
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.storage,
      group: 'Personal',
      defaultWidth: 150,
    ),
    musicPricePaidColumn(field: MusicLibraryEntryWorkspaceFields.pricePaid),
    musicMarketValueColumn(field: MusicLibraryEntryWorkspaceFields.marketValue),
    musicPurchaseDateColumn(
        field: MusicLibraryEntryWorkspaceFields.purchaseDate),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicLibraryEntryWorkspaceFields.indexNumber,
      group: 'Personal',
      isNumeric: true,
      defaultWidth: 96,
    ),
    musicRatingColumn(field: MusicLibraryEntryWorkspaceFields.rating),
    musicWishlistColumn(field: MusicLibraryEntryWorkspaceFields.wishlist),
    musicUpdatedAtColumn(field: MusicLibraryEntryWorkspaceFields.updatedAt),
    musicAddedAtColumn(field: MusicLibraryEntryWorkspaceFields.addedAt),
    musicSignedByColumn(field: MusicLibraryEntryWorkspaceFields.signedBy),
    musicLastCleanedColumn(field: MusicLibraryEntryWorkspaceFields.lastCleaned),
  ],
  sorts: [
    musicStatusSort(),
    if (MusicFieldIdentities.artist.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicLibraryEntryWorkspaceFields.artist,
      ),
    if (MusicFieldIdentities.title.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicLibraryEntryWorkspaceFields.title,
      ),
    if (MusicFieldIdentities.publisher.sortable)
      sortFromField<MusicKind, MusicWorkspaceProjection, String>(
        MusicLibraryEntryWorkspaceFields.publisher,
      ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicLibraryEntryWorkspaceFields.condition,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicLibraryEntryWorkspaceFields.grade,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicLibraryEntryWorkspaceFields.location,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicLibraryEntryWorkspaceFields.storage,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicLibraryEntryWorkspaceFields.pricePaid,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicLibraryEntryWorkspaceFields.marketValue,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicLibraryEntryWorkspaceFields.purchaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicLibraryEntryWorkspaceFields.indexNumber,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicLibraryEntryWorkspaceFields.updatedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicLibraryEntryWorkspaceFields.addedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicLibraryEntryWorkspaceFields.lastCleaned,
      defaultAscending: false,
    ),
  ],
  groups: musicWorkspaceGroupDefinitions(includePersonal: true),
  primaryColumn: MusicLibraryEntryWorkspaceFields.title.id,
  defaultVisibleColumns: {
    MusicFieldIds.status,
    MusicFieldIds.cover,
    MusicFieldIds.artist,
    MusicFieldIds.title,
    MusicFieldIds.condition,
    MusicFieldIds.grade,
    MusicFieldIds.location,
    MusicFieldIds.storage,
    MusicFieldIds.pricePaid,
    MusicFieldIds.marketValue,
    MusicFieldIds.purchaseDate,
    MusicFieldIds.indexNumber,
    MusicFieldIds.rating,
    MusicFieldIds.updatedAt,
  },
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
);
