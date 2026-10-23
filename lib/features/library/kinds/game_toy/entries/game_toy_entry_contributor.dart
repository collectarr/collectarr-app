import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/data/game_toy_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/data/game_toy_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor.dart';

final gameToyEntryContributor = TypedEntryKindContributor<GameToyLibraryEntry>(
  kind: CatalogMediaKind.gameToy,
  findById: (database, id) =>
      GameToyEntryRepository(database).findById(LibraryEntryId(id)),
  upsert: (database, item) => GameToyEntryRepository(database).upsert(item),
  listActive: (database) => GameToyEntryRepository(database).listActive(),
  createItemWithCatalog: ({
    required payload,
    required sourceCatalogItem,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! GameToyLibraryEntryCreatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    return payload.toLibraryEntry(
      id: id,
      sourceCatalogItem: sourceCatalogItem,
      createdAt: createdAt,
      existingIsDigital: existingIsDigital,
      ownerUserId: ownerUserId,
      ownerLabel: ownerLabel,
    );
  },
  updateItem: ({
    required existing,
    required payload,
    required updatedAt,
    required fallbackOwnerUserId,
    required fallbackOwnerLabel,
  }) {
    if (payload is! GameToyLibraryEntryUpdatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    if (!payload.canApplyTo(existing)) {
      throw StateError('Entry update payload does not belong to game');
    }
    return payload.applyTo(
      existing,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  },
  toJson: (item) => item.toJson().cast<String, Object?>(),
  fromJson: GameToyLibraryEntry.fromJson,
  summary: GameToyLibraryEntryProjection.toSummary,
  createPayload: GameToyLibraryEntryCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) =>
      item.copyWith(personal: item.personal.copyWith(locationId: locationId)),
);
