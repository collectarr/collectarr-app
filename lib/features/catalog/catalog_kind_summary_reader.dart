import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Typed read contract for the deliberately small mixed-catalog projection.
///
/// A summary reader may be used by global hosts, but it must not expose a
/// [CatalogItemDto] or any kind-specific metadata. The owning kind remains
/// responsible for projecting its domain into [CatalogDisplaySummary].
abstract interface class CatalogKindSummaryReader {
  CatalogMediaKind get kind;

  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db);
}
