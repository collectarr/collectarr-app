import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

/// Reads complete catalog snapshots at an explicit serialization boundary.
///
/// A snapshot is transport-shaped data used by sync, metadata refresh and
/// explicit edit boundaries. Mixed/global Library code must use
/// [CatalogDisplaySummaryRepository] instead, and kind code should decode a
/// snapshot immediately into its concrete domain model.
final class CatalogSnapshotRepository {
  CatalogSnapshotRepository(this._db);

  final LocalDatabase _db;

  Future<Map<CatalogItemRef, CatalogItemDto>> findByRefs(
    Iterable<CatalogItemRef> refs,
  ) async {
    final wanted = refs.toSet();
    if (wanted.isEmpty) return const {};
    final result = <CatalogItemRef, CatalogItemDto>{};
    final requestedByItem = <CatalogItemRef, List<CatalogItemRef>>{};
    for (final ref in wanted) {
      final root = ref;
      final itemRef = CatalogItemRef(kind: root.kind, id: root.id);
      requestedByItem.putIfAbsent(itemRef, () => []).add(ref);
    }
    final items =
        await CatalogItemCacheRepository(_db).findByRefs(requestedByItem.keys);
    for (final item in items) {
      final itemRef = CatalogItemRef(kind: item.mediaKind, id: item.id);
      for (final requestedRef
          in requestedByItem[itemRef] ?? const <CatalogItemRef>[]) {
        result[requestedRef] = item;
      }
    }
    return result;
  }

  Future<CatalogItemDto?> findByRef(CatalogItemRef ref) async {
    return (await findByRefs([ref]))[ref];
  }

  /// Reads a catalog item for a mixed/global host without leaking the
  /// generated Core DTO outside this transport boundary.
  Future<Map<CatalogItemRef, CatalogSearchCandidate>> findCandidatesByRefs(
    Iterable<CatalogItemRef> refs,
  ) async {
    final items = await findByRefs(refs);
    if (items.isEmpty) return const {};
    final summaries =
        await CatalogDisplaySummaryRepository(_db).findByRefs(items.keys);
    return items.map((ref, item) {
      final summary = summaries[ref];
      return MapEntry(
        ref,
        summary == null
            ? CatalogSearchCandidate.fromItem(item)
            : CatalogSearchCandidate.fromTransport(
                item: item,
                summary: summary,
              ),
      );
    });
  }

  Future<CatalogSearchCandidate?> findCandidateByRef(
    CatalogItemRef ref,
  ) async {
    return (await findCandidatesByRefs([ref]))[ref];
  }

  /// Reads complete schema-v1 transport without promoting it to a search
  /// candidate. Generic mutation hosts use this for payload-only edits.
  Future<Map<CatalogItemRef, CatalogImportTransport>> findTransportsByRefs(
    Iterable<CatalogItemRef> refs,
  ) async {
    final items = await findByRefs(refs);
    return items.map(
      (ref, item) => MapEntry(ref, CatalogImportTransport.fromItem(item)),
    );
  }

  Future<CatalogImportTransport?> findTransportByRef(
    CatalogItemRef ref,
  ) async {
    final item = await findByRef(ref);
    return item == null ? null : CatalogImportTransport.fromItem(item);
  }

  Future<List<CatalogItemDto>> findAll({CatalogMediaKind? kind}) async {
    return CatalogItemCacheRepository(_db).findAll(kind: kind);
  }
}
