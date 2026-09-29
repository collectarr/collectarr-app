import 'package:flutter/foundation.dart';

import 'catalog_media_kind.dart';
import 'money.dart';

/// Stable cross-kind identity for one App-owned copy.
///
/// This reference contains no Catalog Item identity or kind-specific copy
/// fields. Those are represented by separate references and kind-owned data.
@immutable
final class OwnedCopyRef {
  const OwnedCopyRef({required this.kind, required this.id});

  final CatalogMediaKind kind;
  final OwnedCopyId id;

  String get key => '${kind.apiValue}:${id.value}';

  factory OwnedCopyRef.fromKey(String key) {
    final separator = key.indexOf(':');
    if (separator <= 0 || separator == key.length - 1) {
      throw const FormatException('OwnedCopyRef key must be <kind>:<id>');
    }
    final kind = catalogMediaKindFromApiValue(key.substring(0, separator));
    final id = key.substring(separator + 1);
    if (kind.isUnknown || id.trim().isEmpty) {
      throw const FormatException(
        'OwnedCopyRef key must contain a known kind and non-empty id',
      );
    }
    return OwnedCopyRef(kind: kind, id: OwnedCopyId(id));
  }

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'id': id.value,
      };

  factory OwnedCopyRef.fromJson(Map<String, Object?> json) {
    final rawKind = json['kind'];
    final rawId = json['id'];
    if (rawKind is! String || rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException('OwnedCopyRef requires kind and id');
    }
    final kind = catalogMediaKindFromApiValue(rawKind);
    if (kind.isUnknown) {
      throw FormatException('OwnedCopyRef requires a known kind: $rawKind');
    }
    return OwnedCopyRef(kind: kind, id: OwnedCopyId(rawId));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedCopyRef && kind == other.kind && id == other.id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// Decodes a cross-kind Owned Copy reference at a transport boundary.
OwnedCopyRef? ownedCopyRefFromSerialized(Object? value) {
  if (value == null) return null;
  if (value is String) return OwnedCopyRef.fromKey(value);
  if (value is Map) {
    return OwnedCopyRef.fromJson(Map<String, Object?>.from(value));
  }
  throw FormatException('Invalid serialized OwnedCopyRef: $value');
}
