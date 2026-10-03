import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_library_entry_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final musicLibraryEntryWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.libraryEntry,
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
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicLibraryEntryWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicLibraryEntryWorkspaceFields.title,
    ),
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
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.condition,
      sidebarTitle: 'Conditions',
      icon: Icons.verified_outlined,
      supportsBucketManagement: true,
      entryBucketValueMutator:
          MusicLibraryEntryWorkspaceFields.conditionBucketValueMutator(),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.grade,
      sidebarTitle: 'Grades',
      icon: Icons.stars_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.location,
      sidebarTitle: 'Locations',
      icon: Icons.place_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicLibraryEntryWorkspaceFields.storage,
      sidebarTitle: 'Storage',
      icon: Icons.shelves,
    ),
  ],
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
  preferenceCodec: const IdentityLibraryWorkspacePreferenceCodec<MusicKind>(),
);
