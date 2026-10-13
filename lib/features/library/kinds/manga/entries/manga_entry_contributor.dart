import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor.dart';

final mangaEntryContributor = TypedEntryKindContributor<MangaLibraryEntry>(
  kind: CatalogMediaKind.manga,
  findById: (database, id) =>
      MangaEntryRepository(database).findById(LibraryEntryId(id)),
  upsert: (database, item) => MangaEntryRepository(database).upsert(item),
  listActive: (database) => MangaEntryRepository(database).listActive(),
  createItemWithCatalog: ({
    required payload,
    required sourceCatalogItem,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! MangaLibraryEntryCreatePayload) {
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
    if (payload is! MangaLibraryEntryUpdatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    if (!payload.canApplyTo(existing)) {
      throw StateError('Entry update payload does not belong to manga');
    }
    return payload.applyTo(
      existing,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  },
  toJson: (item) => item.toJson().cast<String, Object?>(),
  fromJson: MangaLibraryEntry.fromJson,
  summary: MangaLibraryEntryProjection.toSummary,
  createPayload: MangaLibraryEntryCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) =>
      item.copyWith(personal: item.personal.copyWith(locationId: locationId)),
);
