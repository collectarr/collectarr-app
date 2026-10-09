import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

abstract final class MusicPersonalWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.condition,
    metadata: MusicWorkspaceFieldMetadata.condition,
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.location,
    metadata: MusicWorkspaceFieldMetadata.location,
    getValue: (context) => context.personal.locationPath,
  );

  static final listenCount =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.listenCount,
    metadata: MusicWorkspaceFieldMetadata.listenCount,
    getValue: (context) => context.dto.listeningSummary?.totalListenCount,
  );

  static final lastListened =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.lastListened,
    metadata: MusicWorkspaceFieldMetadata.lastListened,
    getValue: (context) => context.dto.listeningSummary?.lastListened,
  );

  static final pricePaid =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.pricePaid,
    metadata: MusicWorkspaceFieldMetadata.pricePaid,
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final rating =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.rating,
    metadata: MusicWorkspaceFieldMetadata.rating,
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, bool>(
    id: MusicFieldIds.wishlist,
    metadata: MusicWorkspaceFieldMetadata.wishlist,
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime>(
    id: MusicFieldIds.updatedAt,
    metadata: MusicWorkspaceFieldMetadata.updatedAt,
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.addedAt,
    metadata: MusicWorkspaceFieldMetadata.addedAt,
    getValue: (context) => context.addedAt,
  );

  static final signedBy =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.signedBy,
    metadata: MusicWorkspaceFieldMetadata.signedBy,
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry
          ? entry.personal.details.signedBy
          : null;
    },
  );

  static final grade =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.grade,
    metadata: MusicWorkspaceFieldMetadata.grade,
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry ? entry.personal.grade : null;
    },
  );

  static final storageSummary =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.storageSummary,
    metadata: MusicWorkspaceFieldMetadata.storageSummary,
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch,
      );
      if (entry is! MusicLibraryEntry) return null;
      final values = [
        for (final medium in entry.personal.details.media)
          [
            medium.storageDevice?.trim(),
            medium.storageSlot?.trim(),
          ].whereType<String>().where((value) => value.isNotEmpty).join(' / '),
      ];
      final populated = values.where((value) => value.isNotEmpty).toList();
      return populated.isEmpty ? null : populated.join(' | ');
    },
  );

  static final storageDevice = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.storageDevice,
    metadata: MusicWorkspaceFieldMetadata.storageDevice,
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch,
      );
      if (entry is! MusicLibraryEntry) return const <String>[];
      return {
        for (final medium in entry.personal.details.media)
          if (medium.storageDevice?.trim() case final device?)
            if (device.isNotEmpty) device,
      };
    },
  );

  static final storageSlot = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.storageSlot,
    metadata: MusicWorkspaceFieldMetadata.storageSlot,
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch,
      );
      if (entry is! MusicLibraryEntry) return const <String>[];
      return {
        for (final medium in entry.personal.details.media)
          if (medium.storageSlot?.trim() case final slot?)
            if (slot.isNotEmpty) slot,
      };
    },
  );

  static final purchaseDate =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.purchaseDate,
    metadata: MusicWorkspaceFieldMetadata.purchaseDate,
    getValue: (context) => context.item.entrySummary?.purchaseDate,
  );

  static final marketValue =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.marketValue,
    metadata: MusicWorkspaceFieldMetadata.marketValue,
    getValue: (context) => context.item.entrySummary?.marketValueCents,
  );

  static final indexNumber =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.indexNumber,
    metadata: MusicWorkspaceFieldMetadata.indexNumber,
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry ? entry.personal.indexNumber : null;
    },
  );

  static final lastCleaned =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.lastCleaned,
    metadata: MusicWorkspaceFieldMetadata.lastCleaned,
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry
          ? entry.personal.details.lastCleanedDate
          : null;
    },
  );

  static final all =
      <LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, Object?>>[
    condition,
    grade,
    location,
    listenCount,
    lastListened,
    storageSummary,
    storageDevice,
    storageSlot,
    pricePaid,
    marketValue,
    purchaseDate,
    indexNumber,
    rating,
    wishlist,
    updatedAt,
    addedAt,
    signedBy,
    lastCleaned,
  ];

  static LibraryEntryGroupBucketValueMutator conditionBucketValueMutator() {
    return (item, currentLabel, {String? replacement}) {
      if (item is! LibraryEntryDispatch ||
          item.kind != CatalogMediaKind.music ||
          item.value is! MusicLibraryEntry) {
        return null;
      }
      final entry = item.value as MusicLibraryEntry;
      if (entry.personal.condition?.trim() != currentLabel.trim()) return null;
      final next = replacement?.trim();
      return UpdateLibraryEntryCommand(
        libraryEntryRef: LibraryEntryRef(
          kind: CatalogMediaKind.music,
          id: LibraryEntryId(entry.id.value),
        ),
        payload: MusicLibraryEntryUpdatePayload(
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
