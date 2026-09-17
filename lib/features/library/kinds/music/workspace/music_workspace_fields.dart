import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';

/// Music fields are shared by the three scoped registries, but every scoped
/// schema selects only the fields owned by its entity.
abstract final class MusicWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    label: 'Label',
    getValue: (dto) => dto.publisher,
  );

  static final genre = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.genre,
  );

  static final releaseCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseCount,
    label: 'Release count',
    getValue: (dto) => dto.releaseCount,
  );

  static final aggregateListenCount =
      numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.aggregateListenCount,
    label: 'Aggregate listens',
    getValue: (dto) => dto.aggregateListenCount,
    entityScope: LibraryEntityScope.work,
  );

  static final aggregateLastListened =
      dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.aggregateLastListened,
    label: 'Last listened',
    getValue: (dto) => dto.aggregateLastListened,
    entityScope: LibraryEntityScope.work,
  );

  static final listenedReleaseCount =
      numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenedReleaseCount,
    label: 'Listened releases',
    getValue: (dto) => dto.listenedReleaseCount,
    entityScope: LibraryEntityScope.work,
  );

  static final listenCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenCount,
    label: 'Listen count',
    getValue: (dto) => dto.listenCount,
    entityScope: LibraryEntityScope.release,
  );

  static final lastListened = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.lastListened,
    label: 'Last listened',
    getValue: (dto) => dto.lastListened,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.trackCount,
    label: 'Track count',
    getValue: (dto) => dto.trackCount,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );

  static final condition =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final rating =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final catalogNumber = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.catalogNumber,
    label: 'Catalog Number',
    getValue: (dto) => dto.catalogNumber,
    entityScope: LibraryEntityScope.release,
  );

  static final format = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseType = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseType,
    label: 'Release type',
    getValue: (dto) => dto.releaseType,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseStatus = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseStatus,
    label: 'Release status',
    getValue: (dto) => dto.releaseStatus,
    entityScope: LibraryEntityScope.release,
  );

  static final language = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.language,
    label: 'Language',
    getValue: (dto) => dto.language,
    entityScope: LibraryEntityScope.release,
  );

  static final packaging = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.packaging,
    label: 'Packaging',
    getValue: (dto) => dto.packaging,
    entityScope: LibraryEntityScope.release,
  );

  static final boxSet = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.boxSet,
    label: 'Box set',
    getValue: (dto) => dto.boxSet,
    entityScope: LibraryEntityScope.release,
  );

  static final country = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.country,
    label: 'Country',
    getValue: (dto) => dto.country,
    entityScope: LibraryEntityScope.release,
  );

  static final discCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.discCount,
    label: 'Disc Count',
    getValue: (dto) => dto.discCount,
    entityScope: LibraryEntityScope.release,
  );

  static final signedBy =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.details.signedBy : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final grade =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
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
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
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
      return values.isEmpty ? null : values.join(' · ');
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final purchaseDate =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.purchaseDate,
    label: 'Purchase date',
    getValue: (context) => context.source.purchaseDate,
    entityScope: LibraryEntityScope.copy,
  );

  static final marketValue =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.marketValue,
    label: 'Market value',
    getValue: (context) => context.source.marketValueCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final indexNumber =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
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
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.lastCleaned,
    label: 'Last cleaned',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.details.lastCleanedDate : null;
    },
    entityScope: LibraryEntityScope.copy,
  );
}

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
