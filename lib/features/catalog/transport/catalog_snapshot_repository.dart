import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

/// Reads complete catalog snapshots at an explicit serialization boundary.
///
/// A snapshot is transport-shaped data used by sync, metadata refresh and
/// explicit edit boundaries. Mixed/global Library code must use
/// [CatalogDisplaySummaryRepository] instead, and kind code should decode a
/// snapshot immediately into its concrete domain model.
final class CatalogSnapshotRepository {
  CatalogSnapshotRepository(
    this._db, {
    Iterable<CatalogKindTransportBoundary> codecs =
        libraryCatalogTransportCodecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, CatalogKindTransportBoundary> _codecs;

  Future<Map<CatalogEntityRef, CatalogItemDto>> findByRefs(
    Iterable<CatalogEntityRef> refs,
  ) async {
    final wanted = refs.toSet();
    if (wanted.isEmpty) return const {};
    final result = <CatalogEntityRef, CatalogItemDto>{};
    for (final item in await _allItems()) {
      final itemRef = item.catalogRef;
      for (final ref in wanted) {
        // Shelf lookups are normally rooted, but a typed target may still be
        // supplied by a detail/editor host. Keep the requested key so the
        // caller never has to know which side carried the child reference.
        if (itemRef == ref || itemRef.rootScope == ref.rootScope) {
          result[ref] = item;
        }
      }
    }
    return result;
  }

  Future<CatalogItemDto?> findByRef(CatalogEntityRef ref) async {
    return (await findByRefs([ref]))[ref];
  }

  /// Reads a catalog item for a mixed/global host without leaking the
  /// generated Core DTO outside this transport boundary.
  Future<Map<CatalogEntityRef, CatalogSearchCandidate>> findCandidatesByRefs(
    Iterable<CatalogEntityRef> refs,
  ) async {
    final items = await findByRefs(refs);
    return items.map(
      (ref, item) => MapEntry(ref, CatalogSearchCandidate.fromItem(item)),
    );
  }

  Future<CatalogSearchCandidate?> findCandidateByRef(
    CatalogEntityRef ref,
  ) async {
    final item = await findByRef(ref);
    return item == null ? null : CatalogSearchCandidate.fromItem(item);
  }

  /// Reads complete schema-v1 transport without promoting it to a search
  /// candidate. Generic mutation hosts use this for payload-only edits.
  Future<Map<CatalogEntityRef, CatalogImportTransport>> findTransportsByRefs(
    Iterable<CatalogEntityRef> refs,
  ) async {
    final items = await findByRefs(refs);
    return items.map(
      (ref, item) => MapEntry(ref, CatalogImportTransport.fromItem(item)),
    );
  }

  Future<CatalogImportTransport?> findTransportByRef(
    CatalogEntityRef ref,
  ) async {
    final item = await findByRef(ref);
    return item == null ? null : CatalogImportTransport.fromItem(item);
  }

  Future<List<CatalogItemDto>> findAll({CatalogMediaKind? kind}) async {
    return [
      for (final item in await _allItems())
        if (kind == null || item.mediaKind == kind) item,
    ];
  }

  Future<List<CatalogItemDto>> _allItems() async {
    final result = <CatalogItemDto>[];
    for (final codec in _codecs.values) {
      result.addAll(await codec.listTransport(_db));
    }
    return result;
  }
}
