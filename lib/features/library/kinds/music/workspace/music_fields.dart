import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
export 'package:collectarr_app/features/library/kinds/music/workspace/music_preference_codec.dart';

/// Single source of truth schema for Music kind fields.
abstract final class MusicKindSchema {
  static final title = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final artist = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.publisher,
    label: 'Label',
    getValue: (dto) => dto.publisher,
  );

  static final genre = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.genre,
  );

  static final releaseCount = numberField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.releaseCount,
    label: 'Release count',
    getValue: (dto) => dto.releaseCount,
  );

  static final aggregateListenCount = numberField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.aggregateListenCount,
    label: 'Aggregate listens',
    getValue: (dto) => dto.aggregateListenCount,
    entityScope: LibraryEntityScope.work,
  );

  static final aggregateLastListened = dateField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.aggregateLastListened,
    label: 'Last listened',
    getValue: (dto) => dto.aggregateLastListened,
    entityScope: LibraryEntityScope.work,
  );

  static final listenedReleaseCount = numberField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.listenedReleaseCount,
    label: 'Listened releases',
    getValue: (dto) => dto.listenedReleaseCount,
    entityScope: LibraryEntityScope.work,
  );

  static final listenCount = numberField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.listenCount,
    label: 'Listen count',
    getValue: (dto) => dto.listenCount,
    entityScope: LibraryEntityScope.release,
  );

  static final lastListened = dateField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.lastListened,
    label: 'Last listened',
    getValue: (dto) => dto.lastListened,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.trackCount,
    label: 'Track count',
    getValue: (dto) => dto.trackCount,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );

  static final condition =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is MusicOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final rating =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  // Rich Music Metadata Fields
  static final catalogNumber = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.catalogNumber,
    label: 'Catalog Number',
    getValue: (dto) => dto.catalogNumber,
    entityScope: LibraryEntityScope.release,
  );

  static final format = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseType = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.releaseType,
    label: 'Release type',
    getValue: (dto) => dto.releaseType,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseStatus = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.releaseStatus,
    label: 'Release status',
    getValue: (dto) => dto.releaseStatus,
    entityScope: LibraryEntityScope.release,
  );

  static final language = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.language,
    label: 'Language',
    getValue: (dto) => dto.language,
    entityScope: LibraryEntityScope.release,
  );

  static final packaging = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.packaging,
    label: 'Packaging',
    getValue: (dto) => dto.packaging,
    entityScope: LibraryEntityScope.release,
  );

  static final boxSet = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.boxSet,
    label: 'Box set',
    getValue: (dto) => dto.boxSet,
    entityScope: LibraryEntityScope.release,
  );

  static final country = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.country,
    label: 'Country',
    getValue: (dto) => dto.country,
    entityScope: LibraryEntityScope.release,
  );

  static final discCount = numberField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.discCount,
    label: 'Disc Count',
    getValue: (dto) => dto.discCount,
    entityScope: LibraryEntityScope.release,
  );

  static final signedBy =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is MusicOwnedItem ? owned.details.signedBy : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final grade =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.grade,
    label: 'Grade',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.grade : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final storage =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.storage,
    label: 'Storage',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      if (owned is! MusicOwnedItem) return null;
      final values = [
        for (final medium in owned.details.media) ...[
          if (medium.storageDevice?.trim().isNotEmpty == true)
            medium.storageDevice!.trim(),
          if (medium.storageSlot?.trim().isNotEmpty == true)
            medium.storageSlot!.trim(),
        ],
      ];
      return values.isEmpty ? null : values.join(' \u00B7 ');
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final purchaseDate =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, DateTime?>(
    id: MusicFieldIds.purchaseDate,
    label: 'Purchase date',
    getValue: (context) => context.source.purchaseDate,
    entityScope: LibraryEntityScope.copy,
  );

  static final marketValue =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.marketValue,
    label: 'Market value',
    getValue: (context) => context.source.marketValueCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final indexNumber =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.indexNumber,
    label: 'Index number',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.indexNumber : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final lastCleaned =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, DateTime?>(
    id: MusicFieldIds.lastCleaned,
    label: 'Last cleaned',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is MusicOwnedItem ? owned.details.lastCleanedDate : null;
    },
    entityScope: LibraryEntityScope.copy,
  );
}

final musicLibraryFieldDefinitions = [
  MusicKindSchema.title,
  MusicKindSchema.artist,
  MusicKindSchema.publisher,
  MusicKindSchema.releaseDate,
  MusicKindSchema.trackCount,
  MusicKindSchema.barcode,
  MusicKindSchema.condition,
  MusicKindSchema.location,
  MusicKindSchema.pricePaid,
  MusicKindSchema.catalogNumber,
  MusicKindSchema.format,
  MusicKindSchema.country,
  MusicKindSchema.discCount,
  MusicKindSchema.signedBy,
];

final musicLibraryGroupDefinitions = [
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.artist,
    sidebarTitle: 'Artists',
    icon: Icons.person_outline,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['artist'],
    ),
  ),
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.publisher,
    sidebarTitle: 'Labels',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'record_label'],
    ),
  ),
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.format,
    sidebarTitle: 'Formats',
    icon: Icons.album_outlined,
  ),
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.country,
    sidebarTitle: 'Countries',
    icon: Icons.public_outlined,
  ),
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
    supportsBucketManagement: true,
    ownedBucketValueMutator: musicOwnedConditionBucketValueMutator(),
  ),
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

LibraryOwnedGroupBucketValueMutator musicOwnedConditionBucketValueMutator() {
  return (item, currentLabel, {String? replacement}) {
    if (item is! MusicOwnedItemDispatch) return null;
    final owned = item.value;
    if (owned.condition?.trim() != currentLabel.trim()) return null;
    final next = replacement?.trim();
    return UpdateOwnedItemCommand(
      ownedRef: OwnedItemRef(
        kind: CatalogMediaKind.music,
        id: OwnedItemId(owned.id.value),
      ),
      payload: MusicOwnedItemUpdatePayload(
        targetRef: const Patch<CatalogEntityRef?>.unchanged(),
        quantity: const Patch.unchanged(),
        condition: next == null || next.isEmpty
            ? const Patch.clear()
            : Patch.set(next),
        grade: const Patch.unchanged(),
        purchaseDate: const Patch.unchanged(),
        pricePaidCents: const Patch.unchanged(),
        currency: const Patch.unchanged(),
        personalNotes: const Patch.unchanged(),
        locationId: const Patch.unchanged(),
        purchaseStore: const Patch.unchanged(),
        collectionStatus: const Patch.unchanged(),
        isDigital: const Patch.unchanged(),
        tags: const Patch.unchanged(),
        soldAt: const Patch.unchanged(),
        sellPriceCents: const Patch.unchanged(),
        soldTo: const Patch.unchanged(),
        marketValueCents: const Patch.unchanged(),
        indexNumber: const Patch.unchanged(),
        details: const Patch.unchanged(),
      ),
    );
  };
}

final musicLibrarySortDefinitions = [
  sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.artist),
  sortFromField<MusicKind, MusicWorkspaceDto, String>(
      MusicKindSchema.publisher),
  LibrarySortDefinition<MusicKind, MusicWorkspaceDto>(
    id: MusicSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MusicWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.title),
  sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.releaseDate,
      defaultAscending: false),
  sortFromField<MusicKind, MusicWorkspaceDto, num>(MusicKindSchema.trackCount,
      defaultAscending: false),
  sortFromField<MusicKind, MusicWorkspaceDto, num>(MusicKindSchema.discCount,
      defaultAscending: false),
];

final musicLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MusicFieldIds.status,
  MusicFieldIds.cover,
  MusicFieldIds.artist,
  MusicFieldIds.title,
  MusicFieldIds.publisher,
  MusicFieldIds.releaseDate,
  MusicFieldIds.trackCount,
  MusicFieldIds.barcode,
  MusicFieldIds.rating,
  MusicFieldIds.condition,
  MusicFieldIds.pricePaid,
  MusicFieldIds.location,
  MusicFieldIds.wishlist,
  MusicFieldIds.updatedAt,
};

final musicLibraryColumnDefinitions = [
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: MusicKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.cover,
    label: '',
    getValue: MusicKindSchema.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(MusicKindSchema.artist,
      defaultWidth: 160),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(MusicKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<MusicKind, MusicWorkspaceDto, DateTime?>(
    MusicKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, num?>(
    MusicKindSchema.trackCount,
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MusicKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: MusicKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: MusicKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, int?>(
    MusicKindSchema.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: MusicKindSchema.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.catalogNumber,
    group: 'Edition',
    defaultWidth: 120,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.format,
    group: 'Edition',
    defaultWidth: 100,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.country,
    group: 'Edition',
    defaultWidth: 100,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, num?>(
    MusicKindSchema.discCount,
    group: 'Edition',
    isNumeric: true,
    defaultWidth: 80,
  ),
];

final musicLibraryEntityWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MusicKind, MusicWorkspaceDto>(
  kindNamespace: 'music',
  fields: musicLibraryFieldDefinitions,
  columns: musicLibraryColumnDefinitions,
  sorts: musicLibrarySortDefinitions,
  groups: musicLibraryGroupDefinitions,
  defaultVisibleColumns: musicLibraryDefaultVisibleColumns,
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
  preferenceCodec: const MusicPreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
