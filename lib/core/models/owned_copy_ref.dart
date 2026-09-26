import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:flutter/foundation.dart';

/// Identifies one App-owned copy of a canonical Catalog Item.
@immutable
final class OwnedCopyRef {
  OwnedCopyRef({
    required this.kind,
    required String itemId,
    required String copyId,
  })  : itemId = itemId.trim(),
        copyId = copyId.trim() {
    if (kind.isUnknown) {
      throw ArgumentError.value(
          kind, 'kind', 'A known catalog kind is required.');
    }
    if (this.itemId.isEmpty) {
      throw ArgumentError.value(
          itemId, 'itemId', 'A catalog item ID is required.');
    }
    if (this.copyId.isEmpty) {
      throw ArgumentError.value(
          copyId, 'copyId', 'An owned copy ID is required.');
    }
  }

  final CatalogMediaKind kind;
  final String itemId;
  final String copyId;

  CatalogItemRef get catalogItem => CatalogItemRef(kind: kind, id: itemId);

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'item_id': itemId,
        'copy_id': copyId,
      };

  factory OwnedCopyRef.fromJson(Map<String, Object?> json) {
    final rawKind = json['kind'];
    final kind =
        catalogMediaKindFromApiValue(rawKind is String ? rawKind : null);
    if (kind.isUnknown) {
      throw FormatException('Unsupported owned-copy kind: $rawKind');
    }
    String readRequiredId(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Owned-copy $key must be a non-empty string.');
      }
      return value;
    }

    return OwnedCopyRef(
      kind: kind,
      itemId: readRequiredId('item_id'),
      copyId: readRequiredId('copy_id'),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedCopyRef &&
          other.kind == kind &&
          other.itemId == itemId &&
          other.copyId == copyId;

  @override
  int get hashCode => Object.hash(kind, itemId, copyId);

  @override
  String toString() => 'OwnedCopyRef(${kind.apiValue}, $itemId, $copyId)';
}
