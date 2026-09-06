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

/// Kind-owned projection into the structural serial-authority store.
abstract interface class SerialAuthorityContributor {
  CatalogMediaKind get kind;

  Iterable<SerialAuthorityCandidate> candidates(Iterable<Object?> metadata);
}
