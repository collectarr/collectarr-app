import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Structural identity for a tracking entry at a mixed-feature boundary.
///
/// Tracking entries are persisted in kind-owned v1 tables, so an id alone is
/// not a safe cross-kind lookup key. The kind is kept in memory and serialized
/// only by the sync/database boundary.
final class TrackingLifecycleRef {
  const TrackingLifecycleRef({
    required this.kind,
    required this.id,
  });

  final CatalogMediaKind kind;
  final String id;

  String get key => '${kind.apiValue}:$id';

  @override
  bool operator ==(Object other) {
    return other is TrackingLifecycleRef &&
        other.kind == kind &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}
