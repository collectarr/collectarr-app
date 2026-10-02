import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_collection_item_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final musicCollectionItemWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.collectionItem,
  fields: [
    MusicCollectionItemWorkspaceFields.title,
    MusicCollectionItemWorkspaceFields.artist,
    MusicCollectionItemWorkspaceFields.publisher,
    MusicCollectionItemWorkspaceFields.condition,
    MusicCollectionItemWorkspaceFields.grade,
    MusicCollectionItemWorkspaceFields.location,
    MusicCollectionItemWorkspaceFields.storage,
    MusicCollectionItemWorkspaceFields.pricePaid,
    MusicCollectionItemWorkspaceFields.marketValue,
    MusicCollectionItemWorkspaceFields.purchaseDate,
    MusicCollectionItemWorkspaceFields.indexNumber,
    MusicCollectionItemWorkspaceFields.status,
    MusicCollectionItemWorkspaceFields.rating,
    MusicCollectionItemWorkspaceFields.wishlist,
    MusicCollectionItemWorkspaceFields.updatedAt,
    MusicCollectionItemWorkspaceFields.addedAt,
    MusicCollectionItemWorkspaceFields.signedBy,
    MusicCollectionItemWorkspaceFields.lastCleaned,
  ],
  columns: [
    musicStatusColumn(field: MusicCollectionItemWorkspaceFields.status),
    musicCoverColumn(field: MusicCollectionItemWorkspaceFields.cover),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.publisher,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.condition,
      group: 'Copy',
      defaultWidth: 124,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.grade,
      group: 'Copy',
      defaultWidth: 96,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.location,
      group: 'Copy',
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.storage,
      group: 'Copy',
      defaultWidth: 150,
    ),
    musicPricePaidColumn(field: MusicCollectionItemWorkspaceFields.pricePaid),
    musicMarketValueColumn(field: MusicCollectionItemWorkspaceFields.marketValue),
    musicPurchaseDateColumn(field: MusicCollectionItemWorkspaceFields.purchaseDate),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicCollectionItemWorkspaceFields.indexNumber,
      group: 'Copy',
      isNumeric: true,
      defaultWidth: 96,
    ),
    musicRatingColumn(field: MusicCollectionItemWorkspaceFields.rating),
    musicWishlistColumn(field: MusicCollectionItemWorkspaceFields.wishlist),
    musicUpdatedAtColumn(field: MusicCollectionItemWorkspaceFields.updatedAt),
    musicAddedAtColumn(field: MusicCollectionItemWorkspaceFields.addedAt),
    musicSignedByColumn(field: MusicCollectionItemWorkspaceFields.signedBy),
    musicLastCleanedColumn(field: MusicCollectionItemWorkspaceFields.lastCleaned),
  ],
  sorts: [
    musicStatusSort(),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCollectionItemWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCollectionItemWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCollectionItemWorkspaceFields.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCollectionItemWorkspaceFields.condition,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCollectionItemWorkspaceFields.grade,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCollectionItemWorkspaceFields.location,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicCollectionItemWorkspaceFields.storage,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicCollectionItemWorkspaceFields.pricePaid,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicCollectionItemWorkspaceFields.marketValue,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCollectionItemWorkspaceFields.purchaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicCollectionItemWorkspaceFields.indexNumber,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCollectionItemWorkspaceFields.updatedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCollectionItemWorkspaceFields.addedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicCollectionItemWorkspaceFields.lastCleaned,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.condition,
      sidebarTitle: 'Conditions',
      icon: Icons.verified_outlined,
      supportsBucketManagement: true,
      ownedBucketValueMutator:
          MusicCollectionItemWorkspaceFields.conditionBucketValueMutator(),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.grade,
      sidebarTitle: 'Grades',
      icon: Icons.stars_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.location,
      sidebarTitle: 'Locations',
      icon: Icons.place_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicCollectionItemWorkspaceFields.storage,
      sidebarTitle: 'Storage',
      icon: Icons.shelves,
    ),
  ],
  primaryColumn: MusicCollectionItemWorkspaceFields.title.id,
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
