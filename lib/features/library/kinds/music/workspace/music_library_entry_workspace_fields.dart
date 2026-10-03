import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicLibraryEntryWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.primaryLabel,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    label: 'Label',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final condition =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.source.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry ? entry.condition : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final location =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final pricePaid =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isEntry ? 'entry' : null),
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.imageUrl,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final rating =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final wishlist =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final updatedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final addedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final signedBy =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.source.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry ? entry.details.signedBy : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final grade =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.grade,
    label: 'Grade',
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.source.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry ? entry.grade : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final storage =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.storage,
    label: 'Storage',
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.source.libraryEntryDispatch,
      );
      if (entry is! MusicLibraryEntry) return null;
      final values = [
        for (final medium in entry.details.media) ...[
          if (medium.storageDevice?.trim().isNotEmpty == true)
            medium.storageDevice!.trim(),
          if (medium.storageSlot?.trim().isNotEmpty == true)
            medium.storageSlot!.trim(),
        ],
      ];
      return values.isEmpty ? null : values.join(' / ');
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final purchaseDate =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.purchaseDate,
    label: 'Purchase date',
    getValue: (context) => context.source.purchaseDate,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final marketValue =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.marketValue,
    label: 'Market value',
    getValue: (context) => context.source.marketValueCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final indexNumber =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.indexNumber,
    label: 'Index number',
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.source.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry ? entry.indexNumber : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final lastCleaned =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.lastCleaned,
    label: 'Last cleaned',
    getValue: (context) {
      final entry = MusicLibraryEntryProjection.fromDispatch(
        context.source.libraryEntryDispatch,
      );
      return entry is MusicLibraryEntry ? entry.details.lastCleanedDate : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static LibraryEntryGroupBucketValueMutator conditionBucketValueMutator() {
    return (item, currentLabel, {String? replacement}) {
      if (item is! LibraryEntryDispatch ||
          item.kind != CatalogMediaKind.music ||
          item.value is! MusicLibraryEntry) {
        return null;
      }
      final entry = item.value as MusicLibraryEntry;
      if (entry.condition?.trim() != currentLabel.trim()) return null;
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
