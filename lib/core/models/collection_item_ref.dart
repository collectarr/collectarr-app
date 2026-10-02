import 'package:flutter/foundation.dart';

import 'catalog_media_kind.dart';

@immutable
class CollectionItemId {
  const CollectionItemId(this.value);

  final String value;

  static CollectionItemId? fromRaw(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return CollectionItemId(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionItemId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Stable cross-kind identity for one personal collection entry.
///
/// The entry has its own ID and links to canonical metadata separately.
/// Duplicated entries can share one Catalog Item reference while retaining
/// independent personal fields.
@immutable
final class CollectionItemRef {
  const CollectionItemRef({
    required this.kind,
    required this.id,
  });

  final CatalogMediaKind kind;
  final CollectionItemId id;

  String get key => '${kind.apiValue}:${Uri.encodeComponent(id.value)}';

  factory CollectionItemRef.fromKey(String key) {
    final parts = key.split(':');
    if (parts.length != 2 || parts.first.isEmpty || parts[1].isEmpty) {
      throw const FormatException(
        'CollectionItemRef key must be <kind>:<id>',
      );
    }
    final kind = catalogMediaKindFromApiValue(parts.first);
    final id = Uri.decodeComponent(parts[1]);
    if (kind.isUnknown || id.trim().isEmpty) {
      throw const FormatException(
        'CollectionItemRef key must contain a known kind and ID',
      );
    }
    return CollectionItemRef(
      kind: kind,
      id: CollectionItemId(id),
    );
  }

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'id': id.value,
      };

  factory CollectionItemRef.fromJson(Map<String, Object?> json) {
    final rawKind = json['kind'];
    final rawId = json['id'];
    if (rawKind is! String ||
        rawId is! String ||
        rawId.trim().isEmpty) {
      throw const FormatException(
        'CollectionItemRef requires kind and id',
      );
    }
    final kind = catalogMediaKindFromApiValue(rawKind);
    if (kind.isUnknown) {
      throw FormatException('CollectionItemRef requires a known kind: $rawKind');
    }
    return CollectionItemRef(
      kind: kind,
      id: CollectionItemId(rawId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionItemRef &&
          kind == other.kind &&
          id == other.id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// Decodes a cross-kind collection-entry reference at a transport boundary.
CollectionItemRef? collectionItemRefFromSerialized(Object? value) {
  if (value == null) return null;
  if (value is String) return CollectionItemRef.fromKey(value);
  if (value is Map) {
    return CollectionItemRef.fromJson(Map<String, Object?>.from(value));
  }
  throw FormatException('Invalid serialized CollectionItemRef: $value');
}
