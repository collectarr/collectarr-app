import 'package:flutter/foundation.dart';

import 'catalog_media_kind.dart';
import 'money.dart';

/// Stable cross-kind identity for one App-owned copy.
///
/// The Catalog Item ID and copy ID together identify the personal record;
/// kind-owned copy fields remain in their owning domain models.
@immutable
final class OwnedCopyRef {
  const OwnedCopyRef({
    required this.kind,
    required this.itemId,
    required this.id,
  });

  final CatalogMediaKind kind;
  final String itemId;
  final OwnedCopyId id;

  String get key =>
      '${kind.apiValue}:${Uri.encodeComponent(itemId)}:${Uri.encodeComponent(id.value)}';

  factory OwnedCopyRef.fromKey(String key) {
    final parts = key.split(':');
    if (parts.length != 3 ||
        parts.first.isEmpty ||
        parts[1].isEmpty ||
        parts[2].isEmpty) {
      throw const FormatException(
        'OwnedCopyRef key must be <kind>:<item-id>:<copy-id>',
      );
    }
    final kind = catalogMediaKindFromApiValue(parts.first);
    final itemId = Uri.decodeComponent(parts[1]);
    final copyId = Uri.decodeComponent(parts[2]);
    if (kind.isUnknown || itemId.trim().isEmpty || copyId.trim().isEmpty) {
      throw const FormatException(
        'OwnedCopyRef key must contain a known kind, item ID, and copy ID',
      );
    }
    return OwnedCopyRef(
      kind: kind,
      itemId: itemId,
      id: OwnedCopyId(copyId),
    );
  }

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'item_id': itemId,
        'copy_id': id.value,
      };

  factory OwnedCopyRef.fromJson(Map<String, Object?> json) {
    final rawKind = json['kind'];
    final rawItemId = json['item_id'];
    final rawCopyId = json['copy_id'];
    if (rawKind is! String ||
        rawItemId is! String ||
        rawCopyId is! String ||
        rawItemId.trim().isEmpty ||
        rawCopyId.trim().isEmpty) {
      throw const FormatException(
        'OwnedCopyRef requires kind, item_id, and copy_id',
      );
    }
    final kind = catalogMediaKindFromApiValue(rawKind);
    if (kind.isUnknown) {
      throw FormatException('OwnedCopyRef requires a known kind: $rawKind');
    }
    return OwnedCopyRef(
      kind: kind,
      itemId: rawItemId,
      id: OwnedCopyId(rawCopyId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedCopyRef &&
          kind == other.kind &&
          itemId == other.itemId &&
          id == other.id;

  @override
  int get hashCode => Object.hash(kind, itemId, id);
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
