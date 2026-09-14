import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_summary_reader.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';

/// Reads only the structural catalog projection required by mixed/global UI.
///
/// This is intentionally separate from [CatalogTransportRepository]. Callers
/// that only need a title, kind or image must not depend on the full catalog
/// transport facade or rehydrate [CatalogItemDto] graphs.
final class CatalogDisplaySummaryRepository {
  CatalogDisplaySummaryRepository(
    this._db, {
    Iterable<CatalogKindSummaryReader>? readers,
  }) : _readers = [
          ...(readers ?? collectarrKindCatalogTransportCodecs),
        ];

  final LocalDatabase _db;
  final List<CatalogKindSummaryReader> _readers;

  Future<List<CatalogDisplaySummary>> findAll({CatalogMediaKind? kind}) async {
    final summaries = <CatalogDisplaySummary>[];
    for (final reader in _readers) {
      if (kind != null && reader.kind != kind) {
        continue;
      }
      summaries.addAll(await reader.listSummaries(_db));
    }
    return summaries;
  }

  Future<Map<CatalogEntityRef, CatalogDisplaySummary>> findByRefs(
    Iterable<CatalogEntityRef> refs,
  ) async {
    final wanted = refs.toSet();
    if (wanted.isEmpty) return const {};
    for (final ref in wanted) {
      requireKnownCatalogRef(ref, 'catalogSummary.ref');
    }

    final result = <CatalogEntityRef, CatalogDisplaySummary>{};
    for (final reader in _readers) {
      for (final summary in await reader.listSummaries(_db)) {
        for (final ref in wanted) {
          // A mixed host may hold a release/edition ref while the catalog
          // summary is intentionally projected at the owning root. Matching
          // root scope is structural and preserves the caller's complete ref
          // as the map key; no kind-specific entity type is inferred here.
          if (summary.ref == ref || summary.ref == ref.rootScope) {
            result[ref] = summary;
          }
        }
      }
    }
    return result;
  }

  Future<CatalogDisplaySummary?> findByRef(CatalogEntityRef ref) async {
    return (await findByRefs([ref]))[ref];
  }
}
