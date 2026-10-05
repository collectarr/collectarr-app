import 'package:flutter/foundation.dart';

import 'catalog_media_kind.dart';

export 'catalog_media_kind.dart';

/// Identity of one concrete canonical Catalog Item.
///
/// This reference intentionally has no Work, Release, parent, or fallback
/// identity.
@immutable
final class CatalogItemRef {
  const CatalogItemRef({required this.kind, required this.id});

  final CatalogMediaKind kind;
  final String id;

  String get key => '${kind.apiValue}:$id';

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'id': id,
      };

  factory CatalogItemRef.fromJson(Map<String, Object?> json) {
    final unexpected = json.keys.where((key) => key != 'kind' && key != 'id');
    if (unexpected.isNotEmpty) {
      throw FormatException(
        'CatalogItemRef contains unsupported fields: ${unexpected.join(', ')}',
      );
    }
    final rawKind = json['kind'];
    final rawId = json['id'];
    if (rawKind is! String || rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException('CatalogItemRef requires kind and id');
    }
    final kind = catalogMediaKindFromApiValue(rawKind);
    if (kind.isUnknown) {
      throw FormatException('CatalogItemRef requires a known kind: $rawKind');
    }
    return CatalogItemRef(kind: kind, id: rawId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogItemRef && kind == other.kind && id == other.id;

  @override
  int get hashCode => Object.hash(kind, id);
}
