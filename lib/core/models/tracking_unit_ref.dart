import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Structural identity for a kind-owned tracking unit in mixed infrastructure.
final class TrackingUnitRef {
  const TrackingUnitRef({
    required this.kind,
    required this.id,
  });

  final CatalogMediaKind kind;
  final String id;

  String get key => '${kind.apiValue}:$id';

  @override
  bool operator ==(Object other) {
    return other is TrackingUnitRef && other.kind == kind && other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}
