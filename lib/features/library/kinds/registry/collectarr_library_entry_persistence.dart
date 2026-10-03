import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/config/library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/config/library_entry_mutation_result.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor_registry.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor.dart';

/// Composition-root dispatch for the typed entry repositories.
///
/// The registry is generated from each kind's repository, projection and ID
/// files. Collection orchestration only owns the structural dispatch contract;
/// it does not import or enumerate concrete kinds manually.
final class CollectarrLibraryEntryPersistence {
  CollectarrLibraryEntryPersistence(this._database)
      : _contributors = collectarrEntryKindContributors;

  final LocalDatabase _database;
  final Map<CatalogMediaKind, EntryKindContributor> _contributors;

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
    return entryContributorForKind(kind).createLibraryEntry(
      database: _database,
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
    return entryContributorForKind(ref.kind).updateLibraryEntry(
      database: _database,
      ref: ref,
      payload: payload,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  }

  Future<LibraryEntryCreatePayload?> createPayloadByRef(LibraryEntryRef ref) {
    return entryContributorForKind(ref.kind).createPayloadByRef(
      _database,
      ref,
    );
  }

  Future<JsonMap?> payloadByRef(LibraryEntryRef ref) {
    return entryContributorForKind(ref.kind).payloadByRef(_database, ref);
  }

  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    LibraryEntryRef ref,
  ) {
    return entryContributorForKind(ref.kind).syncPayloadByRef(_database, ref);
  }

  Future<LibraryEntryMutationResult> replaceFromPayload(
    CatalogMediaKind kind,
    JsonMap payload,
  ) {
    return entryContributorForKind(kind).replaceFromPayload(_database, payload);
  }

  Future<LibraryEntryDispatch?> libraryEntryForLibraryByRef(
    LibraryEntryRef ref,
  ) async {
    return entryContributorForKind(ref.kind).itemForLibraryByRef(
      _database,
      ref,
    );
  }

  Future<List<LibraryEntryDispatch>> listActiveDispatches() async {
    final groups = await Future.wait(
      _contributors.values.map(
        (contributor) => contributor.listActiveDispatches(_database),
      ),
    );
    return groups.expand((group) => group).toList(growable: false);
  }

  Future<LibraryEntryMutationResult?> markDeletedByRef(
    LibraryEntryRef ref,
    DateTime deletedAt,
  ) async {
    return entryContributorForKind(ref.kind).markDeletedByRef(
      _database,
      ref,
      deletedAt,
    );
  }

  Future<void> updateLocation(LibraryEntryRef ref, String? locationId) async {
    await entryContributorForKind(ref.kind).updateLocation(
      _database,
      ref,
      locationId,
    );
  }

  Future<List<LibraryEntrySummary>> listActiveSummaries() async {
    final groups = await Future.wait(
      _contributors.values.map(
        (contributor) => contributor.listActiveSummaries(_database),
      ),
    );
    return groups.expand((group) => group).toList(growable: false);
  }
}
