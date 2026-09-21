import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final musicOwnedCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.copy,
  fields: [
    MusicWorkspaceFields.title,
    MusicWorkspaceFields.artist,
    MusicWorkspaceFields.publisher,
    MusicWorkspaceFields.condition,
    MusicWorkspaceFields.grade,
    MusicWorkspaceFields.location,
    MusicWorkspaceFields.storage,
    MusicWorkspaceFields.pricePaid,
    MusicWorkspaceFields.marketValue,
    MusicWorkspaceFields.purchaseDate,
    MusicWorkspaceFields.indexNumber,
    MusicWorkspaceFields.status,
    MusicWorkspaceFields.rating,
    MusicWorkspaceFields.wishlist,
    MusicWorkspaceFields.updatedAt,
    MusicWorkspaceFields.addedAt,
    MusicWorkspaceFields.signedBy,
    MusicWorkspaceFields.lastCleaned,
  ],
  columns: [
    musicStatusColumn(),
    musicCoverColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.publisher,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.condition,
      group: 'Copy',
      defaultWidth: 124,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.grade,
      group: 'Copy',
      defaultWidth: 96,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.location,
      group: 'Copy',
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.storage,
      group: 'Copy',
      defaultWidth: 150,
    ),
    musicPricePaidColumn(),
    musicMarketValueColumn(),
    musicPurchaseDateColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      MusicWorkspaceFields.indexNumber,
      group: 'Copy',
      isNumeric: true,
      defaultWidth: 96,
    ),
    musicRatingColumn(),
    musicWishlistColumn(),
    musicUpdatedAtColumn(),
    musicAddedAtColumn(),
    musicSignedByColumn(),
    musicLastCleanedColumn(),
  ],
  sorts: [
    musicStatusSort(),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.condition,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.grade,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.location,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      MusicWorkspaceFields.storage,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicWorkspaceFields.pricePaid,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicWorkspaceFields.marketValue,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicWorkspaceFields.purchaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      MusicWorkspaceFields.indexNumber,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicWorkspaceFields.updatedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicWorkspaceFields.addedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      MusicWorkspaceFields.lastCleaned,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.condition,
      sidebarTitle: 'Conditions',
      icon: Icons.verified_outlined,
      supportsBucketManagement: true,
      ownedBucketValueMutator: musicOwnedConditionBucketValueMutator(),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.grade,
      sidebarTitle: 'Grades',
      icon: Icons.stars_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.location,
      sidebarTitle: 'Locations',
      icon: Icons.place_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      MusicWorkspaceFields.storage,
      sidebarTitle: 'Storage',
      icon: Icons.shelves,
    ),
  ],
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
  preferenceCodec: const MusicPreferenceCodec(),
);
