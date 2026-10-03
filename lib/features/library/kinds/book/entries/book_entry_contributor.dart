import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor.dart';

final bookEntryContributor = TypedEntryKindContributor<BookLibraryEntry>(
  kind: CatalogMediaKind.book,
  findById: (database, id) =>
      BookEntryRepository(database).findById(LibraryEntryId(id)),
  upsert: (database, item) => BookEntryRepository(database).upsert(item),
  listActive: (database) => BookEntryRepository(database).listActive(),
  createItem: ({
    required payload,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! BookLibraryEntryCreatePayload) {
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
    if (payload is! BookLibraryEntryUpdatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    if (!payload.canApplyTo(existing)) {
      throw StateError('Entry update payload does not belong to book');
    }
    return payload.applyTo(
      existing,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  },
  toJson: (item) => item.toJson().cast<String, Object?>(),
  fromJson: BookLibraryEntry.fromJson,
  summary: BookLibraryEntryProjection.toSummary,
  createPayload: BookLibraryEntryCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) =>
      item.copyWith(locationId: locationId),
);
