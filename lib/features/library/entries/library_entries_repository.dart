import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/config/library_entry_mutation_result.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/library/entries/entry_import_transport.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Cross-kind read/write host backed by each kind's complete entry table.
///
/// Typed aggregates are the canonical persistence path. Mixed/global views
/// consume structural summaries and references rather than a common Entry
/// aggregate.
final class LibraryEntriesRepository {
  LibraryEntriesRepository(LocalDatabase database)
      : database = database,
        _persistence = CollectarrLibraryEntryPersistence(database);

  final LocalDatabase database;
  final CollectarrLibraryEntryPersistence _persistence;
  static const _uuid = Uuid();

  Future<LibraryEntryMutationResult> createLibraryEntry({
    required CatalogMediaKind kind,
    required LibraryEntryCreatePayload payload,
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    return _persistence.createLibraryEntry(
      kind: kind,
      payload: payload,
      resolvedCatalogRef: resolvedCatalogRef,
      id: id,
      createdAt: createdAt,
      existingIsDigital: existingIsDigital,
      ownerUserId: ownerUserId,
      ownerLabel: ownerLabel,
    );
  }

  Future<LibraryEntryMutationResult> updateLibraryEntry({
    required LibraryEntryRef ref,
    required LibraryEntryUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    return _persistence.updateLibraryEntry(
      ref: ref,
      payload: payload,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  }

  Future<LibraryEntryCreatePayload?> createPayloadByRef(LibraryEntryRef ref) {
    return _persistence.createPayloadByRef(ref);
  }

  Future<JsonMap?> payloadByRef(LibraryEntryRef ref) {
    return LibraryEntryStore(database).find(ref.kind, ref.id.value).then(
          (record) => record == null ? null : JsonMap.from(record.toJson()),
        );
  }

  /// Clones the complete persisted record into a new local identity.
  ///
  /// Catalog and personal maps are copied without projecting through a
  /// kind-specific Add payload, so fields that are not currently visible in
  /// a form are retained too.
  Future<LibraryEntryMutationResult?> duplicateRecord(
    LibraryEntryRef sourceRef, {
    required String newId,
    required DateTime createdAt,
  }) async {
    final source = await LibraryEntryStore(database)
        .find(sourceRef.kind, sourceRef.id.value);
    if (source == null) return null;

    final personalData = Map<String, dynamic>.from(source.personalData);
    if (personalData.containsKey('created_at')) {
      personalData['created_at'] = createdAt.toUtc().toIso8601String();
    }
    final duplicate = LibraryEntryRecord(
      id: newId,
      kind: source.kind,
      catalogData: source.catalogData,
      personalData: personalData,
      sourceCatalogRef: source.sourceCatalogRef,
      updatedAt: createdAt.toUtc(),
    );
    return _persistence.replaceFromPayload(
      source.kind,
      JsonMap.from(duplicate.toJson()),
    );
  }

  Future<LibraryEntryMutationResult> replaceFromTransport(
    EntryImportTransport transport,
  ) async {
    final record = LibraryEntryRecord.fromJson(transport.payload);
    if (record.id != transport.ref.id.value) {
      throw FormatException(
        'Imported entry ID ${record.id} does not match transport reference '
        '${transport.ref.id.value}.',
      );
    }
    if (record.kind != transport.ref.kind) {
      throw FormatException(
        'Imported ${record.kind.apiValue} entry does not match '
        '${transport.ref.kind.apiValue} reference.',
      );
    }
    final personalData = Map<String, dynamic>.from(record.personalData);
    final hasImages = personalData.containsKey(libraryEntrySyncImagesKey);
    final hasCustomFields =
        personalData.containsKey(libraryEntrySyncCustomFieldsKey);
    final rawImages = personalData.remove(libraryEntrySyncImagesKey);
    final rawCustomFields =
        personalData.remove(libraryEntrySyncCustomFieldsKey);
    final hasExternalLinks =
        personalData.containsKey(libraryEntrySyncExternalLinksKey);
    final rawExternalLinks =
        personalData.remove(libraryEntrySyncExternalLinksKey);
    final hasLoans = personalData.containsKey(libraryEntrySyncLoansKey);
    final rawLoans = personalData.remove(libraryEntrySyncLoansKey);
    final hasFolderMemberships =
        personalData.containsKey(libraryEntrySyncFolderMembershipsKey);
    final rawFolderMemberships =
        personalData.remove(libraryEntrySyncFolderMembershipsKey);
    final hasReadingQueuePosition =
        personalData.containsKey(libraryEntrySyncReadingQueuePositionKey);
    final rawReadingQueuePosition =
        personalData.remove(libraryEntrySyncReadingQueuePositionKey);
    final rawFolderDefinitions =
        personalData.remove(libraryEntryCsvFolderDefinitionsKey);
    final cleanRecord = LibraryEntryRecord(
      id: record.id,
      kind: record.kind,
      catalogData: record.catalogData,
      personalData: personalData,
      sourceCatalogRef: record.sourceCatalogRef,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
    );
    final entryRef = transport.ref;
    final parsedImages =
        hasImages ? _parseImportedImages(rawImages, entryRef) : null;
    final parsedCustomFields = hasCustomFields
        ? _parseImportedCustomFields(
            rawCustomFields, entryRef, record.updatedAt)
        : null;
    final parsedExternalLinks = hasExternalLinks
        ? _parseImportedExternalLinks(rawExternalLinks, entryRef)
        : null;
    final parsedLoans = hasLoans ? _parseImportedLoans(rawLoans, entryRef) : null;
    final parsedFolderMemberships = hasFolderMemberships
        ? _parseImportedFolderMemberships(rawFolderMemberships)
        : null;
    final parsedFolderDefinitions = rawFolderDefinitions == null
        ? const <UserFolder>[]
        : _parseImportedFolderDefinitions(rawFolderDefinitions);
    final parsedReadingQueuePosition = _parseImportedReadingQueuePosition(
      rawReadingQueuePosition,
      present: hasReadingQueuePosition,
    );

    // Validate the entire envelope before the first write, then persist the
    // record and its personal attachments in one transaction. An invalid
    // image/custom-field row must not leave a half-imported entry behind.
    return database.transaction(() async {
      final result = await _persistence.replaceFromPayload(
        transport.ref.kind,
        JsonMap.from(cleanRecord.toJson()),
      );
      if (hasImages) {
        final images = ItemImageRepository(database);
        await images.deleteAllForLibraryEntryRef(entryRef);
        for (final image in parsedImages!) {
          await images.add(image);
        }
      }
      if (hasCustomFields) {
        final fields = CustomFieldRepository(database);
        await fields.deleteValuesForTarget(
          targetId: entryRef.key,
          targetScope: CustomFieldTargetScope.libraryEntry,
        );
        await fields.upsertValues(parsedCustomFields!);
      }
      if (hasExternalLinks) {
        await UserExternalLinksCacheRepository(database)
            .replaceForLibraryEntry(entryRef, parsedExternalLinks!);
      }
      if (hasLoans) {
        await LoanRepository(database).replaceForLibraryEntry(
          entryRef,
          parsedLoans!,
        );
      }
      if (parsedFolderDefinitions.isNotEmpty) {
        final folders = UserFolderRepository(database);
        for (final folder in parsedFolderDefinitions) {
          await folders.applySyncedUpsert(folder);
          await SyncQueueRepository(database).enqueue(SyncChange(
            id: 'user_folder:${folder.id}:upsert:'
                '${record.updatedAt.microsecondsSinceEpoch}',
            entityType: 'user_folder',
            entityId: folder.id,
            action: 'upsert',
            payload: folder.toSyncPayload(),
            clientChangedAt: record.updatedAt.toUtc(),
          ));
        }
      }
      if (hasFolderMemberships) {
        await UserFolderRepository(database).replaceMembershipsForItem(
          entryRef,
          parsedFolderMemberships!,
        );
      }
      if (hasReadingQueuePosition) {
        await ReadingQueueRepository(database).applySyncedPosition(
          entryRef,
          parsedReadingQueuePosition,
        );
      }
      return result;
    });
  }

  List<ItemImage> _parseImportedImages(
    Object? rawImages,
    LibraryEntryRef entryRef,
  ) {
    if (rawImages is! List) {
      throw const FormatException('Imported entry images must be a list.');
    }
    return [
      for (final value in rawImages)
        if (value is Map)
          ItemImage.fromJson({
            ...Map<String, Object?>.from(value),
            'id': _uuid.v4(),
            'library_entry_ref': entryRef.toJson(),
          })
        else
          throw const FormatException('Imported entry image is invalid.'),
    ];
  }

  List<CustomFieldValue> _parseImportedCustomFields(
    Object? rawCustomFields,
    LibraryEntryRef entryRef,
    DateTime fallbackUpdatedAt,
  ) {
    if (rawCustomFields is! List) {
      throw const FormatException('Imported custom fields must be a list.');
    }
    return [
      for (final value in rawCustomFields)
        if (value is Map)
          CustomFieldValue(
            id: _uuid.v4(),
            targetId: entryRef.key,
            targetScope: CustomFieldTargetScope.libraryEntry,
            fieldDefinitionId: value['field_definition_id'] as String,
            value: value['value'] as String?,
            updatedAt: DateTime.parse(
              value['updated_at'] as String? ??
                  fallbackUpdatedAt.toUtc().toIso8601String(),
            ),
          )
        else
          throw const FormatException(
            'Imported custom field value is invalid.',
          ),
    ];
  }

  List<Loan> _parseImportedLoans(Object? rawLoans, LibraryEntryRef entryRef) {
    if (rawLoans is! List) {
      throw const FormatException('Imported loans must be a list.');
    }
    return [
      for (final value in rawLoans)
        if (value is Map)
          Loan.fromJson({
            ...Map<String, Object?>.from(value),
            'id': _uuid.v4(),
            'library_entry_ref': entryRef.toJson(),
          })
        else
          throw const FormatException('Imported loan is invalid.'),
    ];
  }

  List<({String folderId, int sortOrder})> _parseImportedFolderMemberships(
    Object? rawMemberships,
  ) {
    if (rawMemberships is! List) {
      throw const FormatException('Imported folder memberships must be a list.');
    }
    return [
      for (final value in rawMemberships)
        if (value is Map &&
            value['folder_id'] is String &&
            value['sort_order'] is int)
          (
            folderId: value['folder_id'] as String,
            sortOrder: value['sort_order'] as int,
          )
        else
          throw const FormatException('Imported folder membership is invalid.'),
    ];
  }

  List<UserFolder> _parseImportedFolderDefinitions(Object? rawFolders) {
    if (rawFolders is! List) {
      throw const FormatException('Imported folder definitions must be a list.');
    }
    return [
      for (final value in rawFolders)
        if (value is Map)
          UserFolder.fromJson(Map<String, Object?>.from(value))
        else
          throw const FormatException('Imported folder definition is invalid.'),
    ];
  }

  int? _parseImportedReadingQueuePosition(
    Object? value, {
    required bool present,
  }) {
    if (!present || value == null) return null;
    if (value is int && value >= 0) return value;
    throw const FormatException('Imported reading queue position is invalid.');
  }

  List<UserExternalLink> _parseImportedExternalLinks(
    Object? rawExternalLinks,
    LibraryEntryRef entryRef,
  ) {
    if (rawExternalLinks is! List) {
      throw const FormatException('Imported entry external links must be a list.');
    }
    return [
      for (final value in rawExternalLinks)
        if (value is Map)
          UserExternalLink.fromJson({
            ...Map<String, Object?>.from(value),
            'id': _uuid.v4(),
            'library_entry_ref': entryRef.toJson(),
          })
        else
          throw const FormatException('Imported entry external link is invalid.'),
    ];
  }

  SyncChange syncChangeForMutation(
    LibraryEntryMutationResult result, {
    required String action,
    required DateTime changedAt,
  }) {
    return SyncChange(
      id: 'library_entry:${result.ref.id.value}:$action:'
          '${changedAt.millisecondsSinceEpoch}',
      entityType: 'library_entry',
      entityId: result.ref.id.value,
      action: action,
      payload: result.syncPayload,
      clientChangedAt: changedAt,
    );
  }

  /// Builds the current complete Sync snapshot after all entry attachments have
  /// been written in the local transaction.
  Future<SyncChange> syncChangeForCurrentEntry(
    LibraryEntryRef ref, {
    required String action,
    required DateTime changedAt,
  }) async {
    final store = LibraryEntryStore(database);
    final existing = await store.find(ref.kind, ref.id.value);
    final record = existing == null
        ? null
        : LibraryEntryRecord(
            id: existing.id,
            kind: existing.kind,
            catalogData: existing.catalogData,
            personalData: existing.personalData,
            sourceCatalogRef: existing.sourceCatalogRef,
            updatedAt: changedAt.toUtc(),
            deletedAt: existing.deletedAt,
          );
    if (record == null) throw StateError('Library entry not found: ${ref.key}');
    await store.put(record);
    final payload = record.toJson();
    final personalData = Map<String, dynamic>.from(record.personalData);
    final images =
        await ItemImageRepository(database).listForLibraryEntryRef(ref);
    final customFields =
        await CustomFieldRepository(database).listValuesForTarget(
      targetId: ref.key,
      targetScope: CustomFieldTargetScope.libraryEntry,
    );
    personalData[libraryEntrySyncImagesKey] = [
      for (final image in images)
        {
          'id': image.id,
          'library_entry_ref': ref.toJson(),
          'image_type': image.imageType,
          'image_data': base64Encode(image.imageData),
          'caption': image.caption,
          'sort_order': image.sortOrder,
          'created_at': image.createdAt.toUtc().toIso8601String(),
        },
    ];
    personalData[libraryEntrySyncCustomFieldsKey] = [
      for (final field in customFields)
        {
          'id': field.id,
          'field_definition_id': field.fieldDefinitionId,
          'value': field.value,
          'updated_at': field.updatedAt.toUtc().toIso8601String(),
        },
    ];
    personalData[libraryEntrySyncLoansKey] = [
      for (final loan in await LoanRepository(database).getLoansForItem(ref))
        loan.toJson(),
    ];
    personalData[libraryEntrySyncFolderMembershipsKey] = [
      for (final membership in await UserFolderRepository(database)
          .getMembershipSnapshotForItem(ref))
        {
          'folder_id': membership.folderId,
          'sort_order': membership.sortOrder,
        },
    ];
    personalData[libraryEntrySyncReadingQueuePositionKey] =
        await ReadingQueueRepository(database).positionFor(ref);
    personalData[libraryEntrySyncExternalLinksKey] = [
      for (final link in await UserExternalLinksCacheRepository(database)
          .listByLibraryEntryRef(ref))
        link.toJson(),
    ];
    payload['personal_data'] = personalData;
    return SyncChange(
      id: 'library_entry:${ref.id.value}:$action:${changedAt.microsecondsSinceEpoch}',
      entityType: 'library_entry',
      entityId: ref.id.value,
      action: action,
      payload: payload,
      clientChangedAt: changedAt,
    );
  }

  Future<List<LibraryEntrySummary>> listActiveSummaries() async {
    return _persistence.listActiveSummaries();
  }

  Future<LibraryEntrySummary?> findSummaryByRef(LibraryEntryRef ref) async {
    for (final item in await listActiveSummaries()) {
      if (item.ref == ref) return item;
    }
    return null;
  }

  Future<LibraryEntryMutationResult?> markDeletedByRef(
    LibraryEntryRef ref,
    DateTime deletedAt,
  ) {
    return _persistence.markDeletedByRef(ref, deletedAt);
  }

  Future<void> updateLocation(LibraryEntryRef ref, String? locationId) {
    return _persistence.updateLocation(ref, locationId);
  }
}

/// Queues a fresh full personal snapshot after a per-entry attachment changes.
Future<void> enqueueLibraryEntrySnapshot(
  LocalDatabase database,
  LibraryEntryRef ref, {
  DateTime? changedAt,
}) async {
  final now = (changedAt ?? DateTime.now()).toUtc();
  final change = await LibraryEntriesRepository(database)
      .syncChangeForCurrentEntry(ref, action: 'upsert', changedAt: now);
  await SyncQueueRepository(database).enqueue(change);
}

Future<void> enqueueReadingQueueSnapshots(
  LocalDatabase database,
  LibraryEntryRef changedRef,
) async {
  final refs = {
    ...await ReadingQueueRepository(database).getQueue(),
    changedRef,
  };
  for (final ref in refs) {
    await enqueueLibraryEntrySnapshot(database, ref);
  }
}
