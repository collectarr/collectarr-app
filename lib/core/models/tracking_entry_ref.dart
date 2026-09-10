import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Structural identity for a tracking entry at a mixed-feature boundary.
///
/// Tracking entries are persisted in a universal v1 index for now, so an id
/// alone is not a safe cross-kind lookup key. The kind is kept in memory and
/// serialized only by the sync/database boundary.
final class TrackingEntryRef {
  const TrackingEntryRef({
    required this.kind,
    required this.id,
  });

  final CatalogMediaKind kind;
  final String id;

  String get key => '${kind.apiValue}:$id';

  @override
  bool operator ==(Object other) {
    return other is TrackingEntryRef && other.kind == kind && other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}
