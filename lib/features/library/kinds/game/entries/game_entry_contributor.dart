import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor.dart';

final gameEntryContributor = TypedEntryKindContributor<GameLibraryEntry>(
  kind: CatalogMediaKind.game,
  findById: (database, id) =>
      GameEntryRepository(database).findById(LibraryEntryId(id)),
  upsert: (database, item) => GameEntryRepository(database).upsert(item),
  listActive: (database) => GameEntryRepository(database).listActive(),
  createItem: ({
    required payload,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! GameLibraryEntryCreatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    return payload.toLibraryEntry(
      id: id,
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
    if (payload is! GameLibraryEntryUpdatePayload) {
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
  fromJson: GameLibraryEntry.fromJson,
  summary: GameLibraryEntryProjection.toSummary,
  createPayload: GameLibraryEntryCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) =>
      item.copyWith(locationId: locationId),
);
