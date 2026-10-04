import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/entries/entry_import_transport.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_draft.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_codec.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_entry_repository.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import '../../helpers/tracking_state_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('collection mutations enqueue personal sync changes', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await _cacheSourceCatalogItem(db, 'comic-1', CatalogMediaKind.comic);

    await container.read(libraryEntryMutationsProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(
              condition: 'Near Mint',
            ),
            grade: '9.8',
            details: const ComicEntryDetailsDraft(),
          ),
        );

    final queued = (await db.select(db.syncQueue).get())
        .where((row) => row.entityType == 'library_entry')
        .toList();
    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');
    expect(entry.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
    expect(entry.catalogRef.id, entry.id.value);
    expect(queued, hasLength(1));
    expect(queued.single.entityType, 'library_entry');
    expect(queued.single.action, 'upsert');
  });

  test('duplicate clones the full entry and gives attachments new identities',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    const sourceRef = LibraryEntryRef(
      kind: CatalogMediaKind.comic,
      id: LibraryEntryId('source-entry'),
    );
    final sourceRecord = LibraryEntryRecord(
      id: sourceRef.id.value,
      kind: sourceRef.kind,
      catalogData: const {
        'title': 'Source issue',
        'unmapped_catalog_field': {'kept': true},
      },
      personalData: const {
        'condition': 'Near Mint',
        'quantity': 3,
        'unmapped_personal_field': ['keep', 'all', 'values'],
      },
      sourceCatalogRef: const CatalogItemRef(
        kind: CatalogMediaKind.comic,
        id: 'core-issue-7',
      ),
      updatedAt: DateTime.utc(2026, 10, 1),
    );
    final entries = LibraryEntriesRepository(db);
    await entries.replaceFromTransport(
      EntryImportTransport(ref: sourceRef, payload: sourceRecord.toJson()),
    );
    await ItemImageRepository(db).add(
      ItemImage(
        id: 'source-image',
        libraryEntryRef: sourceRef,
        imageData: Uint8List.fromList([1, 2, 3]),
        caption: 'Personal image',
        createdAt: DateTime.utc(2026, 10, 1),
      ),
    );
    await CustomFieldRepository(db).upsertValue(
      CustomFieldValue(
        id: 'source-custom-value',
        targetId: sourceRef.key,
        targetScope: CustomFieldTargetScope.libraryEntry,
        fieldDefinitionId: 'field-id',
        value: 'Unmapped custom value',
        updatedAt: DateTime.utc(2026, 10, 1),
      ),
    );
    await container.read(trackingMutationsProvider).syncEntryTrackingState(
          sourceRef,
          targetRef: const CatalogEntityRef(
            kind: CatalogMediaKind.comic,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'source-entry',
          ),
          sourceType: TrackingSourceType.physical,
          status: MediaTrackingStatus.completed,
          rating: 9,
          startedAt: DateTime.utc(2026, 9, 28),
          finishedAt: DateTime.utc(2026, 10, 1),
          notes: 'Finished the issue',
          progressCurrent: 6,
          progressTotal: 12,
          timesCompleted: 2,
        );

    final duplicate =
        await container.read(libraryEntryMutationsProvider).duplicateItem(
              sourceRef,
              tracking: LibraryEntryTrackingDraft(
                status: MediaTrackingStatus.completed,
                sourceType: TrackingSourceType.physical,
                rating: 9,
                startedAt: DateTime.utc(2026, 9, 28),
                finishedAt: DateTime.utc(2026, 10, 1),
                notes: 'Finished the issue',
                progressCurrent: 6,
                progressTotal: 12,
                timesCompleted: 2,
              ),
            );

    expect(duplicate, isNotNull);
    expect(duplicate, isNot(sourceRef));
    final duplicatePayload = await entries.payloadByRef(duplicate!);
    expect(duplicatePayload?['catalog_data'], sourceRecord.catalogData);
    expect(duplicatePayload?['personal_data'], sourceRecord.personalData);
    expect(duplicatePayload?['source_catalog_ref'],
        sourceRecord.sourceCatalogRef!.toJson());

    final images = ItemImageRepository(db);
    final sourceImages = await images.listForLibraryEntryRef(sourceRef);
    final duplicateImages = await images.listForLibraryEntryRef(duplicate);
    expect(sourceImages.single.id, 'source-image');
    expect(duplicateImages, hasLength(1));
    expect(duplicateImages.single.id, isNot(sourceImages.single.id));
    expect(duplicateImages.single.libraryEntryRef, duplicate);
    expect(duplicateImages.single.imageData, sourceImages.single.imageData);

    final fields = CustomFieldRepository(db);
    final sourceFields = await fields.listValuesForTarget(
      targetId: sourceRef.key,
      targetScope: CustomFieldTargetScope.libraryEntry,
    );
    final duplicateFields = await fields.listValuesForTarget(
      targetId: duplicate.key,
      targetScope: CustomFieldTargetScope.libraryEntry,
    );
    expect(sourceFields.single.id, 'source-custom-value');
    expect(duplicateFields, hasLength(1));
    expect(duplicateFields.single.id, isNot(sourceFields.single.id));
    expect(duplicateFields.single.targetId, duplicate.key);
    expect(duplicateFields.single.value, sourceFields.single.value);

    final changes = await db.select(db.syncQueue).get();
    final entryChanges =
        changes.where((change) => change.entityType == 'library_entry');
    expect(entryChanges, hasLength(1));
    expect(entryChanges.single.entityId, duplicate.id.value);
    expect(
        entryChanges.single.payloadJson, contains('unmapped_personal_field'));

    final trackingRecords = await readTrackingStates(db);
    expect(trackingRecords, hasLength(2));
    final duplicateTracking = trackingRecords.singleWhere(
      (record) => record.libraryEntryRef == duplicate,
    );
    expect(duplicateTracking.sourceType, TrackingSourceType.physical);
    expect(duplicateTracking.status, MediaTrackingStatus.completed);
    expect(duplicateTracking.rating, 9);
    expect(duplicateTracking.notes, 'Finished the issue');
    expect(duplicateTracking.progress.current, 6);
    expect(duplicateTracking.progress.total, 12);
    expect(duplicateTracking.progress.timesCompleted, 2);
  });

  test('collection add prefers the kind-entry create payload over defaults',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await _cacheSourceCatalogItem(
      db,
      'comic-typed-payload',
      CatalogMediaKind.comic,
    );

    await container.read(libraryEntryMutationsProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('comic-typed-payload', kind: 'comic'),
            common: const LibraryAddCommonDraft(
              condition: 'Default condition',
            ),
            details: const ComicEntryDetailsDraft(),
            typedPayload: ComicLibraryEntryCreatePayload(
              catalogRef: testCatalogRef('comic-typed-payload', kind: 'comic'),
              details: const ComicEntryDetailsDraft(),
              condition: 'Typed condition',
              purchaseStore: 'Typed store',
              collectionStatus: 'Complete',
            ),
          ),
        );

    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(
      db,
      'comic-typed-payload',
    );
    expect(entry.condition, 'Typed condition');
    expect(entry.purchaseStore, 'Typed store');
    expect(entry.collectionStatus, 'Complete');
  });

  test(
      'collection mutations stamp collection item createdAt and owner identity',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWithValue(db),
        authControllerProvider.overrideWith(
          () => _LibraryEntryAuthController(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await _cacheSourceCatalogItem(db, 'movie-1', CatalogMediaKind.movie);

    await container.read(libraryEntryMutationsProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('movie-1', kind: 'movie'),
            common: const LibraryAddCommonDraft(),
            details: const MovieEntryDetailsDraft(),
          ),
        );

    final entry = await _typedEntryForCatalog<MovieLibraryEntry>(db, 'movie-1');
    final queued = await db.select(db.syncQueue).getSingle();

    expect(entry.createdAt, isNotNull);
    expect(entry.ownerUserId, 'user-1');
    expect(entry.ownerLabel, 'owner@example.com');
    expect(queued.payloadJson, contains('"created_at"'));
    expect(queued.payloadJson, contains('"owner_user_id":"user-1"'));
    expect(queued.payloadJson, contains('"owner_label":"owner@example.com"'));
  });

  test('collection mutations request sync scheduler after local changes',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    late _SpySyncController syncController;
    final container = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWithValue(db),
        connectionSettingsProvider.overrideWith(
          _OnlineFirstConnectionSettingsController.new,
        ),
        syncControllerProvider.overrideWith(
          () => syncController = _SpySyncController(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await _cacheSourceCatalogItem(db, 'comic-1', CatalogMediaKind.comic);

    await container.read(libraryEntryMutationsProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(),
            details: const ComicEntryDetailsDraft(),
          ),
        );

    // The mutation runner schedules online-first sync without awaiting it.
    await Future<void>.delayed(Duration.zero);
    expect(syncController.syncNowRequests, 1);
  });

  test('catalog refresh preserves personal collection data', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(id: 'comic-1', kind: 'comic', title: 'Original'),
    ]);
    await container.read(collectionCommandCoordinatorProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(
              condition: 'Near Mint',
            ),
            tracking: const LibraryEntryTrackingDraft(rating: 8),
            details: const ComicEntryDetailsDraft(),
          ),
        );

    await container.read(catalogTransportMutationsProvider).upsertTransport(
          CatalogSearchCandidate.fromItem(testCatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Updated',
            synopsis: 'Refreshed metadata',
          )).kindCapability.toImportTransport(),
        );

    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');
    final tracking = await readSingleTrackingState(db);
    final catalog = await CatalogSnapshotRepository(db).findByRef(
      const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'comic-1',
      ),
    );

    expect(entry.condition, 'Near Mint');
    expect(tracking.rating, 8);
    expect(catalog?.title, 'Updated');
  });

  test('collection mutations mirror tracking into tracking entries', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await _cacheSourceCatalogItem(db, 'movie-1', CatalogMediaKind.movie);

    await container.read(collectionCommandCoordinatorProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('movie-1', kind: 'movie'),
            common: LibraryAddCommonDraft(),
            tracking: LibraryEntryTrackingDraft(
              status: MediaTrackingStatus.completed,
              rating: 8,
              startedAt: DateTime.utc(2026, 5, 10),
              finishedAt: DateTime.utc(2026, 5, 12),
            ),
            details: const MovieEntryDetailsDraft(),
          ),
        );

    final entry = await _typedEntryForCatalog<MovieLibraryEntry>(db, 'movie-1');
    final tracking = await readSingleTrackingState(db);
    final queued = await db.select(db.syncQueue).get();

    expect(tracking.catalogRef.id, entry.id.value);
    expect(
      tracking.libraryEntryRef?.key,
      LibraryEntryRef.fromKey('movie:${entry.id.value}').key,
    );
    expect(tracking.sourceTypeApiValue, 'physical');
    expect(tracking.statusStorageValue, 'Completed');
    expect(tracking.rating, 8);
    expect(
      queued.where((row) => row.entityType == 'tracking_entry'),
      hasLength(1),
    );
  });

  test('collection mutations infer digital entries from catalog snapshots',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'movie-digital-1',
        kind: 'movie',
        title: 'Ghost in the Shell',
        physicalFormat: 'digital',
        physicalFormatLabel: 'Digital',
      ),
    ]);

    await container.read(collectionCommandCoordinatorProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('movie-digital-1', kind: 'movie'),
            common: const LibraryAddCommonDraft(isDigital: true),
            tracking: const LibraryEntryTrackingDraft(
              status: MediaTrackingStatus.completed,
              rating: 9,
            ),
            details: const MovieEntryDetailsDraft(),
          ),
        );

    final entry = await _typedEntryForCatalog<MovieLibraryEntry>(
      db,
      'movie-digital-1',
    );
    final tracking = await readSingleTrackingState(db);

    expect(entry.isDigital, isTrue);
    expect(tracking.sourceTypeApiValue, TrackingSourceType.digital.apiValue);
  });

  test('collection mutations can sync entry tracking entries directly',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await _cacheSourceCatalogItem(db, 'movie-2', CatalogMediaKind.movie);

    final entry = await container
        .read(collectionCommandCoordinatorProvider)
        .addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('movie-2', kind: 'movie'),
            common: const LibraryAddCommonDraft(),
            details: const MovieEntryDetailsDraft(),
          ),
          syncTracking: false,
        );
    await container.read(trackingMutationsProvider).syncEntryTrackingState(
          entry,
          targetRef: const CatalogEntityRef(
            kind: CatalogMediaKind.movie,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'movie-2',
          ),
          status: MediaTrackingStatus.completed,
          rating: 10,
          startedAt: DateTime.utc(2026, 5, 20),
          finishedAt: DateTime.utc(2026, 5, 21),
        );

    final tracking = await readSingleTrackingState(db);
    final queued = await db.select(db.syncQueue).get();
    final trackingRef = tracking.catalogRef;

    expect(tracking.libraryEntryRef?.key, entry.key);
    expect(trackingRef.entityType, CatalogEntityTypeId.catalogItem);
    expect(trackingRef.id, 'movie-2');
    expect(tracking.statusStorageValue, 'Completed');
    expect(tracking.rating, 10);
    expect(
      queued.where((row) => row.entityType == 'tracking_entry'),
      hasLength(1),
    );
  });

  test('collection mutations can create tracking-only entries', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
          id: 'music-1', kind: 'music', title: 'Blessed & Possessed'),
    ]);

    await container.read(trackingMutationsProvider).upsertTrackingState(
          TrackingTarget.catalog(
            const CatalogEntityRef(
              kind: CatalogMediaKind.music,
              entityType: CatalogEntityTypeId.catalogItem,
              id: 'music-1',
            ),
          ),
          sourceType: TrackingSourceType.digital,
          status: MediaTrackingStatus.inProgress,
          rating: 7,
          progressCurrent: 6,
          progressTotal: 12,
          notes: 'Streaming copy',
        );

    final tracking = await readSingleTrackingState(db);
    final queued = await db.select(db.syncQueue).get();

    expect(
      tracking.catalogRef.id,
      'music-1',
    );
    expect(tracking.libraryEntryRef, isNull);
    expect(tracking.sourceTypeApiValue, 'digital');
    expect(tracking.progress.current, 6);
    expect(
      queued.where((row) => row.entityType == 'tracking_entry'),
      hasLength(1),
    );
  });

  test('collection mutations reuse existing tracked-only entries', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(id: 'movie-1', kind: 'movie', title: 'Dune'),
    ]);

    final trackingRepository = trackingRecordTestRepository(db);
    await trackingRepository.upsertStorageRecord(
      trackingRepository.create(
        id: 'tracking-existing',
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        sourceType: 'digital',
        status: 'Plan to watch',
        updatedAt: DateTime.utc(2026, 5, 23),
      ),
    );

    await container.read(trackingMutationsProvider).upsertTrackingState(
          TrackingTarget.catalog(testCatalogRef('movie-1', kind: 'movie')),
          sourceType: TrackingSourceType.digital,
          status: MediaTrackingStatus.inProgress,
          rating: 9,
        );

    final tracking = await readTrackingStates(db);
    expect(tracking, hasLength(1));
    expect(tracking.single.id, 'tracking-existing');
    expect(tracking.single.statusStorageValue, 'In progress');
    expect(tracking.single.rating, 9);
  });

  test('collection mutations canonicalize tracking source aliases', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(id: 'book-1', kind: 'book', title: 'Project Hail Mary'),
    ]);

    await container.read(trackingMutationsProvider).upsertTrackingState(
          TrackingTarget.catalog(testCatalogRef('book-1', kind: 'book')),
          sourceType: trackingSourceTypeFromValue('kindle'),
          status: mediaTrackingStatusFromValue('Reading'),
        );

    final tracking = await readSingleTrackingState(db);
    expect(tracking.sourceTypeApiValue, TrackingSourceType.digital.apiValue);
  });

  test('collection mutations enqueue catalog snapshots from cache', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Absolute Batman',
        itemNumber: '1',
        coverImageUrl: 'https://cdn.example/absolute.jpg',
        thumbnailImageUrl: 'https://cdn.example/absolute-thumb.jpg',
        publisher: 'DC',
        releaseYear: 2024,
      ),
    ]);

    await container.read(libraryEntryMutationsProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(),
            details: const ComicEntryDetailsDraft(),
          ),
        );

    final queued = await db.select(db.syncQueue).get();
    final snapshot = queued
        .where((row) => row.entityType == 'library_entry')
        .single;
    expect(queued.where((row) => row.entityType == 'catalog_item'), isEmpty);
    expect(snapshot.payloadJson, contains('"catalog_data"'));
    expect(snapshot.payloadJson, contains('Absolute Batman'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(syncControllerProvider).pendingCount, 1);
  });

  test('collection updates can clear nullable personal details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await _cacheSourceCatalogItem(db, 'comic-1', CatalogMediaKind.comic);

    await container.read(collectionCommandCoordinatorProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: LibraryAddCommonDraft(
              condition: 'Near Mint',
              purchaseDate: DateTime.utc(2026, 5, 10),
              pricePaidCents: 1299,
              currency: 'USD',
              personalNotes: 'Signed copy',
            ),
            grade: '9.8',
            details: const ComicEntryDetailsDraft(),
          ),
        );
    final original =
        await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');

    await container
        .read(collectionCommandCoordinatorProvider)
        .updateLibraryEntry(
          UpdateLibraryEntryCommand(
            libraryEntryRef: LibraryEntryRef(
              kind: CatalogMediaKind.comic,
              id: LibraryEntryId(original.id.value),
            ),
            payload: ComicLibraryEntryUpdatePayload.partial(
              condition: const Patch.set('Near Mint'),
              grade: const Patch.set('9.8'),
              purchaseDate: const Patch.clear(),
              pricePaidCents: const Patch.clear(),
              currency: const Patch.clear(),
              personalNotes: const Patch.clear(),
            ),
          ),
        );

    final updated = await _typedEntry<ComicLibraryEntry>(
      db,
      LibraryEntryRef(
        kind: CatalogMediaKind.comic,
        id: LibraryEntryId(original.id.value),
      ),
    );
    expect(updated.purchaseDate, isNull);
    expect(updated.pricePaidCents, isNull);
    expect(updated.currency, isNull);
    expect(updated.personalNotes, isNull);
  });

  test('collection updates can clear an existing location', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await _cacheSourceCatalogItem(db, 'comic-1', CatalogMediaKind.comic);

    await container.read(collectionCommandCoordinatorProvider).addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(
              locationId: 'loc-box-6',
            ),
            details: const ComicEntryDetailsDraft(),
          ),
        );
    final original =
        await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');

    await container
        .read(collectionCommandCoordinatorProvider)
        .updateLibraryEntry(
          UpdateLibraryEntryCommand(
            libraryEntryRef: LibraryEntryRef(
              kind: CatalogMediaKind.comic,
              id: LibraryEntryId(original.id.value),
            ),
            payload: ComicLibraryEntryUpdatePayload.partial(
              locationId: const Patch.clear(),
            ),
          ),
        );

    final updated = await _typedEntry<ComicLibraryEntry>(
      db,
      LibraryEntryRef(
        kind: CatalogMediaKind.comic,
        id: LibraryEntryId(original.id.value),
      ),
    );
    expect(updated.locationId, isNull);
  });

  test('wishlist updates Catalog Item references and notes', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(wishlistMutationsProvider).addToWishlist(
          const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-1'),
        );
    final originalRow = await db.select(db.wishlistItemsCache).getSingle();
    final original = WishlistItem(
      id: originalRow.id,
      catalogRef: CatalogItemRef.fromJson(
        jsonDecode(originalRow.catalogRefJson) as Map<String, Object?>,
      ),
      targetPriceCents: originalRow.targetPriceCents,
      currency: originalRow.currency,
      notes: originalRow.notes,
      createdAt: originalRow.createdAt,
      updatedAt: originalRow.updatedAt,
      deletedAt: originalRow.deletedAt,
    );

    await container.read(wishlistMutationsProvider).updateWishlistItem(
          original,
          catalogRef: const CatalogItemRef(
            kind: CatalogMediaKind.movie,
            id: 'movie-bundle-1',
          ),
          targetPriceCents: 4599,
          currency: 'USD',
          notes: 'Wait for the steelbook bundle.',
        );

    final updated = await db.select(db.wishlistItemsCache).getSingle();
    final queued = await db.select(db.syncQueue).get();

    final updatedRef = CatalogItemRef.fromJson(
      jsonDecode(updated.catalogRefJson) as Map<String, Object?>,
    );
    expect(updatedRef.kind, CatalogMediaKind.movie);
    expect(updatedRef.id, 'movie-bundle-1');
    expect(updated.targetPriceCents, 4599);
    expect(updated.currency, 'USD');
    expect(updated.notes, 'Wait for the steelbook bundle.');
    expect(
        queued.where((row) => row.entityType == 'wishlist_item'), hasLength(1));
  });

  test('wishlist can contain multiple concrete Catalog Items', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final wishlistMutations = container.read(wishlistMutationsProvider);
    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-4k'),
    );
    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-bluray'),
    );

    final rows = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();

    expect(rows.where((row) => row.deletedAt == null), hasLength(2));
    expect(
      rows
          .where((row) => row.deletedAt == null)
          .map((row) => CatalogItemRef.fromJson(
                jsonDecode(row.catalogRefJson) as Map<String, Object?>,
              ).id)
          .toSet(),
      {'movie-4k', 'movie-bluray'},
    );
    expect(
        queued.where((row) => row.entityType == 'wishlist_item'), hasLength(2));
  });

  test('wishlist removal targets a single Catalog Item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final wishlistMutations = container.read(wishlistMutationsProvider);
    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-4k'),
    );
    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-bluray'),
    );

    await wishlistMutations.removeFromWishlist(
      catalogRef: const CatalogItemRef(
        kind: CatalogMediaKind.movie,
        id: 'movie-4k',
      ),
    );

    final rows = await db.select(db.wishlistItemsCache).get();
    final activeRows = rows.where((row) => row.deletedAt == null).toList();
    final deletedRows = rows.where((row) => row.deletedAt != null).toList();

    expect(activeRows, hasLength(1));
    expect(
      CatalogItemRef.fromJson(
        jsonDecode(activeRows.single.catalogRefJson) as Map<String, Object?>,
      ).id,
      'movie-bluray',
    );
    expect(deletedRows, hasLength(1));
    expect(
      CatalogItemRef.fromJson(
        jsonDecode(deletedRows.single.catalogRefJson) as Map<String, Object?>,
      ).id,
      'movie-4k',
    );
  });

  test('collection import enqueues rows and refreshes pending count once',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'entry',
          kindEntryCells: ['9.8'],
          personal: CollectionImportPersonalValues(
            condition: 'Near Mint',
            pricePaidCents: 1299,
            currency: 'USD',
          ),
        ),
        const CollectionImportRow(
          itemId: 'comic-2',
          mediaKind: CatalogMediaKind.comic,
          status: 'wishlist',
        ),
      ],
    );

    final entry = await LibraryEntriesRepository(db).listActiveSummaries();
    final typedEntry = await ComicEntryRepository(db).listActive();
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 2);
    expect(entry, hasLength(1));
    expect(typedEntry, hasLength(1));
    expect(typedEntry.single.grade, '9.8');
    expect(wishlist, hasLength(1));
    // Rows without a complete kind-entry catalog projection must not create a
    // generic catalog snapshot as a side effect of importing Entry/Wishlist.
    expect(queued, hasLength(2));
    final entryChanges =
        queued.where((row) => row.entityType == 'library_entry').toList();
    expect(entryChanges, hasLength(1));
    final entryPayload = jsonDecode(entryChanges.single.payloadJson);
    expect(entryPayload, isA<Map<String, dynamic>>());
    expect(entryPayload, contains('id'));
    expect(entryPayload, contains('catalog_data'));
    expect(entryPayload, contains('personal_data'));
    expect(entryPayload, contains('updated_at'));
    expect(container.read(syncControllerProvider).pendingCount, 2);
  });

  test('collection import moves existing wishlist rows to entry in one batch',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final wishlistMutations = container.read(wishlistMutationsProvider);
    final importOrchestrator =
        container.read(collectionImportOrchestratorProvider);

    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.comic, id: 'comic-1'),
    );
    await importOrchestrator.importRows([
      const CollectionImportRow(
        itemId: 'comic-1',
        mediaKind: CatalogMediaKind.comic,
        status: 'entry',
      ),
    ]);

    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = (await db.select(db.syncQueue).get())
        .where((row) =>
            row.entityType == 'library_entry' ||
            row.entityType == 'wishlist_item' ||
            row.entityType == 'catalog_item')
        .toList();

    expect(entry, isNotNull);
    expect(wishlist.single.deletedAt, isNotNull);
    expect(queued, hasLength(3));
    expect(
        queued.where((row) => row.entityType == 'wishlist_item').single.action,
        'delete');
  });

  test('collection import resolves clz rows from local catalog cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Amazing Spider-Man, Vol. 2',
        itemNumber: '520',
        barcode: '759606047161-52011',
      ),
    ]);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: '',
          status: 'entry',
          title: 'Different title from CSV',
          mediaKind: CatalogMediaKind.comic,
          kindCatalogCells: [
            '',
            'comic',
            'Different title from CSV',
            '520',
            '',
            '',
            '',
            '',
            '',
            '',
            '75960604716152011',
          ],
          kindEntryCells: ['7.5'],
        ),
      ],
    );

    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');
    final typedEntry = await ComicEntryRepository(db).listActive();
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 1);
    expect(entry.itemId, 'comic-1');
    expect(entry.grade, '7.5');
    expect(typedEntry, hasLength(1));
    expect(
      queued.where((row) => row.entityType == 'catalog_item'),
      hasLength(1),
    );
  });

  test('collection import stores media-specific catalog fields from csv',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: 'movie-1',
          mediaKind: CatalogMediaKind.movie,
          status: 'entry',
          title: 'Blade Runner',
          kindCatalogCells: [
            'movie-1',
            'movie',
            'Blade Runner',
            'Final Cut',
            '4K UHD',
            'Final Cut 4K release',
            '4k-uhd',
            '4K UHD',
            '',
            '',
            '883929087129',
          ],
        ),
      ],
    );

    final catalog = await CatalogSnapshotRepository(db).findByRef(
      const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'movie-1',
      ),
    );
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 1);
    expect(catalog?.kind, 'movie');
    expect(catalog?.editionTitle, 'Final Cut 4K release');
    expect(catalog?.physicalFormat, '4k-uhd');
    expect(catalog?.physicalFormatLabel, '4K UHD');
    expect(
      queued.where((row) => row.entityType == 'catalog_item'),
      hasLength(1),
    );
  });

  test('collection import preserves universal entry fields from csv', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      [
        CollectionImportRow(
          itemId: 'book-entry-fields',
          mediaKind: CatalogMediaKind.book,
          status: 'entry',
          title: 'Imported book',
          kindEntryCells: ['8.5'],
          personal: CollectionImportPersonalValues(
            condition: 'Very Good',
            purchaseDate: DateTime.utc(2026, 8, 1),
            pricePaidCents: 2599,
            currency: 'EUR',
            notes: 'Imported note',
            locationId: 'shelf-a',
            indexNumber: 12,
            tags: 'gift,read',
            soldAt: DateTime.utc(2026, 8, 15),
            sellPriceCents: 3199,
            soldTo: 'collector@example.test',
          ),
        ),
      ],
    );

    final entry = await _typedEntryForCatalog<BookLibraryEntry>(
      db,
      'book-entry-fields',
    );
    expect(imported, 1);
    expect(entry.itemId, 'book-entry-fields');
    expect(entry.condition, 'Very Good');
    expect(entry.grade, '8.5');
    expect(entry.purchaseDate?.toUtc(), DateTime.utc(2026, 8, 1));
    expect(entry.pricePaidCents, 2599);
    expect(entry.currency, 'EUR');
    expect(entry.personalNotes, 'Imported note');
    expect(entry.locationId, 'shelf-a');
    expect(entry.indexNumber, 12);
    expect(entry.tags, 'gift,read');
    expect(entry.soldAt?.toUtc(), DateTime.utc(2026, 8, 15));
    expect(entry.sellPriceCents, 3199);
    expect(entry.soldTo, 'collector@example.test');
  });

  test('collection import delegates kind-entry csv cells to Comic', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final csv = CollectionCsvCodec(profiles: collectionCsvKindProfiles);
    final entryFixture = testLibraryEntry(
      id: 'entry-comic-details',
      itemId: 'comic-entry-details',
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      graderNotes: 'Pressing preserved',
      signedBy: 'Artist',
      keyComic: true,
      keyReason: 'First appearance',
      coverPriceCents: 499,
    );
    final rows = csv.parse(
      csv.exportShelf([
        LibraryWorkspaceSource(
          itemId: 'comic-entry-details',
          catalogData: testWorkspaceCatalogData(testCatalogItemWithKindMetadata(
            testCatalogItem(
              id: 'comic-entry-details',
              kind: 'comic',
              title: 'Imported Comic',
            ),
          ).asShelfCatalogItem),
          libraryEntrySummary: testLibraryEntrySummary(entryFixture),
          libraryEntryDispatch: testComicLibraryEntryDispatchFrom(
            testComicLibraryEntryFrom(entryFixture),
          ),
        ),
      ]),
    );

    await container.read(collectionImportOrchestratorProvider).importRows(rows);

    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(
      db,
      'comic-entry-details',
    );
    final details = entry.details;
    expect(details.rawOrSlabbed, 'Slabbed');
    expect(details.gradingCompany, 'CGC');
    expect(details.graderNotes, 'Pressing preserved');
    expect(details.signedBy, 'Artist');
    expect(details.keyComic, isTrue);
    expect(details.keyReason, 'First appearance');
    expect(details.coverPriceCents, 499);
  });

  test('collection import uses media type when matching local catalog cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Dune',
        barcode: '1234567890',
      ),
      testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Dune',
        barcode: '1234567890',
      ),
    ]);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: '',
          mediaKind: CatalogMediaKind.movie,
          status: 'entry',
          title: 'Dune',
          kindCatalogCells: [
            '',
            'movie',
            'Dune',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '1234567890',
          ],
        ),
      ],
    );

    final entry = await _typedEntryForCatalog<MovieLibraryEntry>(db, 'movie-1');
    expect(imported, 1);
    expect(entry.itemId, 'movie-1');
  });

  test(
      'collection import does not synthesize catalog metadata without kind cells',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: 'comic-without-projection',
          mediaKind: CatalogMediaKind.comic,
          title: 'Only a structural import row',
          status: 'entry',
        ),
      ],
    );

    expect(
        await CatalogSnapshotRepository(db).findByRef(
          const CatalogEntityRef(
            kind: CatalogMediaKind.comic,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'comic-without-projection',
          ),
        ),
        isNull);
    expect(
      (await db.select(db.syncQueue).get())
          .where((row) => row.entityType == 'catalog_item'),
      isEmpty,
    );
  });

  test('collection import preview reports matched unresolved and skipped rows',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Amazing Spider-Man, Vol. 2',
        itemNumber: '520',
        barcode: '75960604716152011',
      ),
    ]);

    final preview = await container
        .read(collectionImportOrchestratorProvider)
        .previewImportRows(
      const [
        CollectionImportRow(
          itemId: '',
          mediaKind: CatalogMediaKind.comic,
          status: 'entry',
          title: 'The Amazing Spider-Man, Vol. 2',
          kindCatalogCells: [
            '',
            'comic',
            'The Amazing Spider-Man, Vol. 2',
            '520',
            '',
            '',
            '',
            '',
            '',
            '',
            '75960604716152011',
          ],
        ),
        CollectionImportRow(
          itemId: '',
          status: 'entry',
          title: 'Unknown Series',
          kindCatalogCells: [
            '',
            '',
            'Unknown Series',
            '1',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
          ],
        ),
        CollectionImportRow(itemId: '', status: ''),
      ],
    );

    expect(preview.totalRows, 3);
    expect(preview.resolvedCount, 1);
    expect(preview.unresolvedCount, 1);
    expect(preview.skippedCount, 1);
    expect(preview.resolvedRows.single.itemId, 'comic-1');
  });

  test('collection import preview skips duplicate csv targets', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final importOrchestrator =
        container.read(collectionImportOrchestratorProvider);
    final preview = await importOrchestrator.previewImportRows(
      const [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'entry',
          kindEntryCells: ['9.8'],
        ),
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'entry',
          kindEntryCells: ['7.5'],
        ),
      ],
    );

    expect(preview.resolvedCount, 1);
    expect(preview.duplicateCount, 1);
    expect(preview.duplicateRows.single.kindEntryCells.first, '7.5');
    expect(preview.reviewCount, 1);

    final imported = await importOrchestrator.importRows(preview.resolvedRows);
    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(
      db,
      'comic-1',
    );
    expect(imported, 1);
    expect(entry.grade, '9.8');
  });

  test('collection import routes tracking columns to tracking entries',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      [
        CollectionImportRow(
          itemId: 'comic-tracking-import',
          mediaKind: CatalogMediaKind.comic,
          status: 'entry',
          tracking: CollectionImportTrackingValues(
            rating: 8,
            status: 'Read',
            startedAt: DateTime.utc(2026, 6, 1),
            finishedAt: DateTime.utc(2026, 6, 2),
          ),
        ),
      ],
    );

    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(
      db,
      'comic-tracking-import',
    );
    final tracking = await readSingleTrackingState(db);
    expect(imported, 1);
    expect(
      tracking.libraryEntryRef?.key,
      LibraryEntryRef.fromKey('comic:${entry.id.value}').key,
    );
    expect(tracking.statusStorageValue, 'Completed');
    expect(tracking.rating, 8);
    expect(tracking.startedAt?.toUtc(), DateTime.utc(2026, 6, 1));
    expect(tracking.finishedAt?.toUtc(), DateTime.utc(2026, 6, 2));
  });

  test('collection import preview reports existing entry conflicts', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final importOrchestrator =
        container.read(collectionImportOrchestratorProvider);

    await coordinator.addLibraryEntry(
      typedAddLibraryEntryCommand(
        catalogRef: testCatalogRef('comic-1', kind: 'comic'),
        common: const LibraryAddCommonDraft(),
        grade: '4.0',
        details: const ComicEntryDetailsDraft(),
      ),
    );

    final preview = await importOrchestrator.previewImportRows(
      const [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'entry',
          kindEntryCells: ['7.5'],
        ),
      ],
    );

    expect(preview.resolvedCount, 0);
    expect(preview.conflictCount, 1);
    expect(preview.conflictRows.single.itemId, 'comic-1');
  });

  test('collection import updates existing entry conflict without duplicate',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final importOrchestrator =
        container.read(collectionImportOrchestratorProvider);

    await coordinator.addLibraryEntry(
      typedAddLibraryEntryCommand(
        catalogRef: testCatalogRef('comic-1', kind: 'comic'),
        common: const LibraryAddCommonDraft(condition: 'Good'),
        grade: '4.0',
        details: const ComicEntryDetailsDraft(),
      ),
    );
    final original =
        await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');

    final imported = await importOrchestrator.importRows(
      const [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'entry',
          kindEntryCells: ['7.5'],
          personal: CollectionImportPersonalValues(locationId: 'loc-box-6'),
        ),
      ],
    );

    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');
    expect(imported, 1);
    expect(entry.id, original.id);
    expect(entry.condition, 'Good');
    expect(entry.grade, '7.5');
    expect(entry.locationId, 'loc-box-6');
  });

  test('collection import preserves structured location ids', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'entry',
          personal: CollectionImportPersonalValues(
            locationId: 'loc-short-box-6',
          ),
        ),
      ],
    );

    final entry = await _typedEntryForCatalog<ComicLibraryEntry>(db, 'comic-1');
    expect(imported, 1);
    expect(entry.locationId, 'loc-short-box-6');
  });
}

Future<T> _typedEntry<T>(LocalDatabase db, LibraryEntryRef ref) async {
  final result = switch (ref.kind) {
    CatalogMediaKind.comic =>
      await ComicEntryRepository(db).findById(LibraryEntryId(ref.id.value)),
    CatalogMediaKind.book =>
      await BookEntryRepository(db).findById(LibraryEntryId(ref.id.value)),
    CatalogMediaKind.movie =>
      await MovieEntryRepository(db).findById(LibraryEntryId(ref.id.value)),
    _ => throw StateError('Unsupported test Entry kind ${ref.kind}'),
  };
  expect(result, isNotNull, reason: 'Missing typed Collection item ${ref.key}');
  return result as T;
}

Future<T> _typedEntryForCatalog<T>(LocalDatabase db, String itemId) async {
  final summaries = await LibraryEntriesRepository(db).listActiveSummaries();
  final localCatalogItems = await CatalogItemCacheRepository(db).findAll();
  final cachedItem = localCatalogItems
      .where((item) => item.id == itemId)
      .firstOrNull;
  LibraryEntrySummary? summary;
  for (final candidate in summaries) {
    final payload = await LibraryEntriesRepository(db).payloadByRef(
      candidate.ref,
    );
    final source = payload?['source_catalog_ref'];
    final catalogData = payload?['catalog_data'];
    final sourceId = source is Map ? source['id'] : null;
    final matches = (candidate.catalogRef?.rootId ??
                candidate.catalogRef?.id) ==
            itemId ||
        sourceId == itemId ||
        (cachedItem != null &&
            candidate.ref.kind == cachedItem.mediaKind &&
            catalogData is Map &&
            catalogData['title'] == cachedItem.title);
    if (matches) {
      summary = candidate;
      break;
    }
  }
  if (summary == null && summaries.length == 1) summary = summaries.single;
  expect(summary, isNotNull, reason: 'Missing local entry for $itemId');
  return _typedEntry<T>(db, summary!.ref);
}

Future<void> _cacheSourceCatalogItem(
  LocalDatabase db,
  String id,
  CatalogMediaKind kind,
) {
  return CatalogTransportRepository(db).upsertTransportItems([
    testCatalogItem(id: id, kind: kind.apiValue, title: id),
  ]);
}

class _LibraryEntryAuthController extends AuthController {
  _LibraryEntryAuthController();

  @override
  AuthState build() => const AuthState(
        token: 'test-token',
        userId: 'user-1',
        email: 'owner@example.com',
      );
}

class _SpySyncController extends SyncController {
  _SpySyncController();

  int syncNowRequests = 0;

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {
    syncNowRequests += 1;
  }
}

class _OnlineFirstConnectionSettingsController
    extends ConnectionSettingsController {
  @override
  ConnectionSettings build() => const ConnectionSettings(
        preferOnlineFirstSync: true,
        syncBaseUrl: 'https://sync.example.test',
        syncKey: 'test-sync-key',
      );
}
