import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_schema_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

final _musicCopyFields = musicWorkspaceFieldsForScope(LibraryEntityScope.copy);

final musicOwnedCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceProjection>(
  kindNamespace: 'music',
  entityScope: LibraryEntityScope.copy,
  fields: [
    _musicCopyFields.title,
    _musicCopyFields.artist,
    _musicCopyFields.publisher,
    _musicCopyFields.condition,
    _musicCopyFields.grade,
    _musicCopyFields.location,
    _musicCopyFields.storage,
    _musicCopyFields.pricePaid,
    _musicCopyFields.marketValue,
    _musicCopyFields.purchaseDate,
    _musicCopyFields.indexNumber,
    _musicCopyFields.status,
    _musicCopyFields.rating,
    _musicCopyFields.wishlist,
    _musicCopyFields.updatedAt,
    _musicCopyFields.addedAt,
    _musicCopyFields.signedBy,
    _musicCopyFields.lastCleaned,
  ],
  columns: [
    musicStatusColumn(),
    musicCoverColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.artist,
      defaultWidth: 160,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.title,
      defaultWidth: 260,
      maxWidth: 520,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.publisher,
      group: 'Release',
      defaultWidth: 140,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.condition,
      group: 'Copy',
      defaultWidth: 124,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.grade,
      group: 'Copy',
      defaultWidth: 96,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.location,
      group: 'Copy',
      defaultWidth: 118,
    ),
    columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.storage,
      group: 'Copy',
      defaultWidth: 150,
    ),
    musicPricePaidColumn(),
    musicMarketValueColumn(),
    musicPurchaseDateColumn(),
    columnFromField<MusicKind, MusicWorkspaceProjection, num?>(
      _musicCopyFields.indexNumber,
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
      _musicCopyFields.artist,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicCopyFields.title,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicCopyFields.publisher,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicCopyFields.condition,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicCopyFields.grade,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicCopyFields.location,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, String>(
      _musicCopyFields.storage,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      _musicCopyFields.pricePaid,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      _musicCopyFields.marketValue,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      _musicCopyFields.purchaseDate,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, int>(
      _musicCopyFields.indexNumber,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      _musicCopyFields.updatedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      _musicCopyFields.addedAt,
      defaultAscending: false,
    ),
    sortFromField<MusicKind, MusicWorkspaceProjection, DateTime>(
      _musicCopyFields.lastCleaned,
      defaultAscending: false,
    ),
  ],
  groups: [
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.artist,
      sidebarTitle: 'Artists',
      icon: Icons.person_outline,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.publisher,
      sidebarTitle: 'Labels',
      icon: Icons.business_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.condition,
      sidebarTitle: 'Conditions',
      icon: Icons.verified_outlined,
      supportsBucketManagement: true,
      ownedBucketValueMutator: musicOwnedConditionBucketValueMutator(),
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.grade,
      sidebarTitle: 'Grades',
      icon: Icons.stars_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.location,
      sidebarTitle: 'Locations',
      icon: Icons.place_outlined,
    ),
    groupFromField<MusicKind, MusicWorkspaceProjection, String?>(
      _musicCopyFields.storage,
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
