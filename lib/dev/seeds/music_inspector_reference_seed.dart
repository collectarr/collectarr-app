import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';

/// Inserts only the explicitly identified comparison entry; never resets a DB.
Future<MusicLibraryEntry> seedMusicInspectorReference(
        LocalDatabase database, Map<String, dynamic> fixture,
        {Map<String, Uint8List> images = const {}}) =>
    database.transaction(() async {
      final catalog = Map<String, dynamic>.from(fixture['catalog'] as Map);
      final metadata = MusicCatalogMapper.fromCatalogPayload(catalog);
      final entry = MusicLibraryEntry(
        id: LibraryEntryId(fixture['entry_id'] as String),
        metadata: metadata,
        sourceCatalogRef: CatalogItemRef(
          kind: CatalogMediaKind.music,
          id: catalog['id'] as String,
        ),
        personal: MusicPersonalData.fromJson(
          Map<String, dynamic>.from(fixture['personal'] as Map),
        ),
        createdAt: DateTime.parse(fixture['created_at'] as String),
        updatedAt: DateTime.parse(fixture['updated_at'] as String),
      );
      final store = LibraryEntryStore(database);
      final existing = await store.find(CatalogMediaKind.music, entry.id.value);
      if (existing != null && existing.catalogData['title'] != metadata.title) {
        throw StateError('Comparison ID belongs to an unrelated local entry.');
      }
      await store.putKindJson(
        CatalogMediaKind.music,
        entry.toJson(),
      );
      final entryRef =
          LibraryEntryRef(kind: CatalogMediaKind.music, id: entry.id);
      final imageRepository = ItemImageRepository(database);
      for (final image in images.entries) {
        final id = '${entry.id.value}-${image.key}';
        await database.transaction(() async {
          await imageRepository.delete(id);
          await imageRepository.add(ItemImage(
              id: id,
              libraryEntryRef: entryRef,
              imageType: image.key,
              imageData: image.value,
              caption: 'Inspector reference ${image.key}',
              createdAt: entry.updatedAt));
        });
      }
      const locationId = 'collectarr-inspector-reference-location';
      final locations = LocationRepository(database);
      await locations.applySyncedUpsert(
          const StorageLocation(id: locationId, name: 'Record Cabinet'));
      await locations.assignItemToLocation(entryRef, locationId);
      final loans = LoanRepository(database);
      await loans.replaceForLibraryEntry(entryRef, [
        Loan(
            id: '${entry.id.value}-active',
            libraryEntryRef: entryRef,
            borrowerName: 'Alex Reference',
            lentDate: DateTime.utc(2026, 10, 1),
            dueDate: DateTime.utc(2026, 10, 20),
            notes: 'Reference current loan'),
        Loan(
            id: '${entry.id.value}-returned',
            libraryEntryRef: entryRef,
            borrowerName: 'Jane Reference',
            lentDate: DateTime.utc(2026, 8, 1),
            dueDate: DateTime.utc(2026, 8, 15),
            returnedDate: DateTime.utc(2026, 10, 11),
            notes: 'Reference loan history'),
      ]);
      await MusicListeningRepository(database).upsert(MusicListenEvent(
          id: '${entry.id.value}-listen',
          libraryEntryRef: entryRef,
          listenedAt: DateTime.utc(2026, 2, 18, 18),
          location: 'Listening room',
          notes: 'Reference listening event',
          createdAt: entry.updatedAt,
          updatedAt: entry.updatedAt));
      return (await MusicEntryRepository(database).findById(entry.id))!;
    });
