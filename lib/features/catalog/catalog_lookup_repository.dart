import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_catalog_kind_lookups.dart';

export 'catalog_kind_lookup.dart' show CatalogLookupQuery;

/// Orchestrates typed catalog lookups without inspecting kind metadata.
final class CatalogLookupRepository {
  CatalogLookupRepository(
    LocalDatabase db, {
    Iterable<CatalogKindLookup>? lookups,
  }) : _lookups = [
          ...(lookups ?? collectarrCatalogKindLookups(db)),
        ];

  final List<CatalogKindLookup> _lookups;

  Future<CatalogSearchHit?> resolve(
    CatalogLookupQuery query, {
    String? kind,
  }) async {
    final normalizedKind = _normalizeKind(kind);
    for (final lookup in _lookups) {
      if (normalizedKind != null && lookup.kind.apiValue != normalizedKind) {
        continue;
      }
      final hit = await lookup.resolve(query);
      if (hit != null) return hit;
    }
    return null;
  }

  static String? _normalizeKind(String? kind) {
    final normalized = kind?.trim().toLowerCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
