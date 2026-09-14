import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Structural identity for a watch session at a mixed-feature boundary.
///
/// Watch-session tables are owned by the media kind. An id without its kind
/// would therefore require an unsafe cross-kind scan.
final class WatchSessionRef {
  const WatchSessionRef({
    required this.kind,
    required this.id,
  });

  final CatalogMediaKind kind;
  final String id;

  String get key => '${kind.apiValue}:$id';

  @override
  bool operator ==(Object other) {
    return other is WatchSessionRef && other.kind == kind && other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}
