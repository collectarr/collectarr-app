import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

final musicOwnedCopyWorkspaceSchema =
    LibraryKindSchema<MusicKind, MusicWorkspaceDto>(
  kindNamespace: 'music',
  fields: [
    MusicKindSchema.title,
    MusicKindSchema.artist,
    MusicKindSchema.publisher,
    MusicKindSchema.condition,
    MusicKindSchema.grade,
    MusicKindSchema.location,
    MusicKindSchema.storage,
    MusicKindSchema.pricePaid,
    MusicKindSchema.marketValue,
    MusicKindSchema.purchaseDate,
    MusicKindSchema.indexNumber,
    MusicKindSchema.status,
    MusicKindSchema.rating,
    MusicKindSchema.wishlist,
    MusicKindSchema.updatedAt,
    MusicKindSchema.addedAt,
    MusicKindSchema.signedBy,
    MusicKindSchema.lastCleaned,
  ],
  columns: [
    musicStatusColumn(),
    musicCoverColumn(),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.publisher,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.condition,
      group: 'Copy',
      defaultWidth: 124,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.grade,
      group: 'Copy',
      defaultWidth: 96,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.location,
      group: 'Copy',
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.storage,
      group: 'Copy',
      defaultWidth: 150,
    ),
    musicPricePaidColumn(),
    musicMarketValueColumn(),
    musicPurchaseDateColumn(),
    columnFromField<MusicKind, MusicWorkspaceDto, num?>(
      MusicKindSchema.indexNumber,
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
    sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.artist),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.title),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(
      MusicKindSchema.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(
      MusicKindSchema.condition,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(
      MusicKindSchema.grade,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(
      MusicKindSchema.location,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, String>(
      MusicKindSchema.storage,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, int>(
      MusicKindSchema.pricePaid,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, int>(
      MusicKindSchema.marketValue,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.purchaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, int>(
      MusicKindSchema.indexNumber,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.updatedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.addedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.lastCleaned,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.condition,
      sidebarTitle: 'Conditions',
      icon: Icons.verified_outlined,
      supportsBucketManagement: true,
      ownedBucketValueMutator: musicOwnedConditionBucketValueMutator(),
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.grade,
      sidebarTitle: 'Grades',
      icon: Icons.stars_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.location,
      sidebarTitle: 'Locations',
      icon: Icons.place_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.storage,
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
