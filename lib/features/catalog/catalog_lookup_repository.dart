import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

export 'catalog_kind_lookup.dart' show CatalogLookupQuery;

/// Orchestrates typed catalog lookups without inspecting kind metadata.
final class CatalogLookupRepository {
  CatalogLookupRepository(
    LocalDatabase db, {
    Iterable<CatalogKindLookup>? lookups,
  }) : _lookups = {
          for (final lookup in (lookups ?? collectarrCatalogKindLookups(db)))
            lookup.kind: lookup,
        };

  final Map<CatalogMediaKind, CatalogKindLookup> _lookups;

  Future<CatalogSearchHit?> resolve(
    CatalogLookupQuery query, {
    CatalogMediaKind? kind,
  }) async {
    if (kind != null) {
      return _lookups[kind]?.resolve(query);
    }
    for (final lookup in _lookups.values) {
      final hit = await lookup.resolve(query);
      if (hit != null) return hit;
    }
    return null;
  }
}
