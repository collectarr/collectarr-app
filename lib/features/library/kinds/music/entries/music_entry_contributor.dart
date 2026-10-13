import 'package:collectarr_app/features/library/kinds/music/data/music_listening_mutations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:uuid/uuid.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor.dart';

final musicEntryContributor = TypedEntryKindContributor<MusicLibraryEntry>(
  kind: CatalogMediaKind.music,
  findById: (database, id) =>
      MusicEntryRepository(database).findById(LibraryEntryId(id)),
  upsert: (database, item) => MusicEntryRepository(database).upsert(item),
  onCreated: (database, item, payload) async {
    if (payload is! MusicLibraryEntryCreatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    final mutations = MusicListeningMutations(database);
    final ref = LibraryEntryRef(kind: CatalogMediaKind.music, id: item.id);
    for (final event in payload.initialListens) {
      await mutations.upsert(MusicListenEvent(
          id: const Uuid().v4(),
          libraryEntryRef: ref,
          listenedAt: event.listenedAt,
          notes: event.notes,
          location: event.location,
          startedAt: event.startedAt,
          finishedAt: event.finishedAt,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt));
    }
  },
  listActive: (database) => MusicEntryRepository(database).listActive(),
  createItemWithCatalog: ({
    required payload,
    required sourceCatalogItem,
    required id,
    required createdAt,
    required existingIsDigital,
    required ownerUserId,
    required ownerLabel,
  }) {
    if (payload is! MusicLibraryEntryCreatePayload) {
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
    if (payload is! MusicLibraryEntryUpdatePayload) {
      throw ArgumentError.value(payload, 'payload');
    }
    return payload.applyTo(
      existing,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  },
  toJson: (item) => item.toJson().cast<String, Object?>(),
  fromJson: MusicLibraryEntry.fromJson,
  summary: MusicLibraryEntryProjection.toSummary,
  createPayload: MusicLibraryEntryCreatePayload.fromTypedItem,
  itemId: (item) => item.id.value,
  markDeleted: (item, deletedAt) =>
      item.copyWith(deletedAt: deletedAt, updatedAt: deletedAt),
  updateItemLocation: (item, locationId) => item.copyWith(
    personal: item.personal.copyWith(locationId: locationId),
  ),
);
