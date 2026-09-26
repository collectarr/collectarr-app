import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

/// Identifies one canonical, collectible catalog edition for a library kind.
///
/// This reference intentionally has no parent chain or generic entity type.
/// Series membership and repeated contents are catalog relationships, not
/// additional workspace roots.
@immutable
final class CatalogItemRef {
  CatalogItemRef({required this.kind, required String id}) : id = id.trim() {
    if (kind.isUnknown) {
      throw ArgumentError.value(
          kind, 'kind', 'A known catalog kind is required.');
    }
    if (this.id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'A catalog item ID is required.');
    }
  }

  final CatalogMediaKind kind;
  final String id;

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'id': id,
      };

  factory CatalogItemRef.fromJson(Map<String, Object?> json) {
    final rawKind = json['kind'];
    final kind =
        catalogMediaKindFromApiValue(rawKind is String ? rawKind : null);
    if (kind.isUnknown) {
      throw FormatException('Unsupported catalog item kind: $rawKind');
    }
    final rawId = json['id'];
    if (rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException(
          'Catalog item ID must be a non-empty string.');
    }
    return CatalogItemRef(kind: kind, id: rawId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogItemRef && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => 'CatalogItemRef(${kind.apiValue}, $id)';
}
