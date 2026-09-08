import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_summary_reader.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

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
          ...(readers ?? collectarrKindCatalogRepositoryCodecs),
        ];

  final LocalDatabase _db;
  final List<CatalogKindSummaryReader> _readers;

  Future<Map<String, CatalogDisplaySummary>> findByIds(
    Iterable<String> ids,
  ) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return const {};

    final result = <String, CatalogDisplaySummary>{};
    for (final reader in _readers) {
      for (final summary in await reader.listSummaries(_db)) {
        if (wanted.contains(summary.id)) {
          result[summary.id] = summary;
        }
      }
    }
    return result;
  }

  Future<List<CatalogDisplaySummary>> findAll({String? kind}) async {
    final normalizedKind = kind?.trim().toLowerCase();
    final summaries = <CatalogDisplaySummary>[];
    for (final reader in _readers) {
      if (normalizedKind != null &&
          normalizedKind.isNotEmpty &&
          reader.kind.apiValue != normalizedKind) {
        continue;
      }
      summaries.addAll(await reader.listSummaries(_db));
    }
    return summaries;
  }
}
