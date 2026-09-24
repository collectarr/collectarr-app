import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicOwnedCopyWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.primaryLabel,
    entityScope: LibraryEntityScope.copy,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
    entityScope: LibraryEntityScope.copy,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    label: 'Label',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.copy,
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
    getValue: (context) => context.dto.imageUrl,
    entityScope: LibraryEntityScope.copy,
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
      return values.isEmpty ? null : values.join(' / ');
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

  static LibraryOwnedGroupBucketValueMutator conditionBucketValueMutator() {
    return (item, currentLabel, {String? replacement}) {
      if (item is! LibraryOwnedItemDispatch ||
          item.kind != CatalogMediaKind.music ||
          item.value is! MusicOwnedItem) {
        return null;
      }
      final owned = item.value as MusicOwnedItem;
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
}
