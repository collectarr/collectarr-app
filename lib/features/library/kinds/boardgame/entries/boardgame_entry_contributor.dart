import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor.dart';

final boardGameEntryContributor =
    TypedEntryKindContributor<BoardGameLibraryEntry>(
  kind: CatalogMediaKind.boardgame,
  findById: (database, id) =>
      BoardGameEntryRepository(database).findById(LibraryEntryId(id)),
  upsert: (database, item) => BoardGameEntryRepository(database).upsert(item),
  listActive: (database) => BoardGameEntryRepository(database).listActive(),
  createItemWithCatalog: ({
    required payload,
    required sourceCatalogItem,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! BoardgameLibraryEntryCreatePayload) {
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
    if (payload is! BoardgameLibraryEntryUpdatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    if (!payload.canApplyTo(existing)) {
      throw StateError('Entry update payload does not belong to boardgame');
    }
    return payload.applyTo(
      existing,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  },
  toJson: (item) => item.toJson().cast<String, Object?>(),
  fromJson: BoardGameLibraryEntry.fromJson,
  summary: BoardGameLibraryEntryProjection.toSummary,
  createPayload: BoardgameLibraryEntryCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) =>
      item.copyWith(personal: item.personal.copyWith(locationId: locationId)),
);
