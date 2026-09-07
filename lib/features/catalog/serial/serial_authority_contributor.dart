import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Structural series candidate produced by a kind-owned metadata projection.
///
/// Serial authority stores and indexes these values, but never interprets a
/// kind payload map itself on this path.
final class SerialAuthorityCandidate {
  const SerialAuthorityCandidate({
    required this.mediaKind,
    required this.title,
    this.coreSeriesId,
    this.sortTitle,
  });

  final CatalogMediaKind mediaKind;
  final String title;
  final String? coreSeriesId;
  final String? sortTitle;
}

/// Structural catalog projection used by serial authority operations.
///
/// The serial feature needs an item's identity and series identity to count
/// and reassign entries. It must not receive a generic catalog DTO or inspect
/// a kind payload map for those values.
final class SerialAuthorityCatalogRecord {
  const SerialAuthorityCatalogRecord({
    required this.itemId,
    required this.title,
    this.seriesTitle,
    this.coreSeriesId,
  });

  final String itemId;
  final String title;
  final String? seriesTitle;
  final String? coreSeriesId;
}

/// Kind-owned projection into the structural serial-authority store.
abstract interface class SerialAuthorityContributor {
  CatalogMediaKind get kind;

  Iterable<SerialAuthorityCandidate> candidates(Iterable<Object?> metadata);

  /// Reads the kind-owned catalog repository into a structural serial view.
  Future<List<SerialAuthorityCatalogRecord>> catalogRecords(
    LocalDatabase db,
  );

  /// Applies a serial assignment through the owning kind's typed repository.
  Future<void> assignSeries(
    LocalDatabase db, {
    required Iterable<String> itemIds,
    required String? coreSeriesId,
    required String seriesTitle,
  });
}
