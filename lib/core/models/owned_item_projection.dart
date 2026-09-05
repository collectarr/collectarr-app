import 'package:flutter/foundation.dart';

import 'catalog_media_kind.dart';
import 'money.dart';

/// Stable cross-kind identity for an owned copy.
///
/// This is a reference only. It deliberately does not expose the owned
/// domain model or any kind-specific fields.
@immutable
final class OwnedItemRef {
  const OwnedItemRef({required this.kind, required this.id});

  final CatalogMediaKind kind;
  final OwnedItemId id;

  String get key => '${kind.apiValue}:${id.value}';

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'id': id.value,
      };

  factory OwnedItemRef.fromJson(Map<String, Object?> json) {
    final rawKind = json['kind'];
    final rawId = json['id'];
    if (rawKind is! String || rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException('OwnedItemRef requires kind and id');
    }
    return OwnedItemRef(
      kind: catalogMediaKindFromApiValue(rawKind),
      id: OwnedItemId(rawId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemRef && kind == other.kind && id == other.id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// Small read projection used by mixed-kind hosts such as Loans and Shelf.
///
/// Keep this projection intentionally boring. If a UI needs condition, grade,
/// packaging, or another semantic field, it must dispatch to the owning kind.
@immutable
final class OwnedItemSummary {
  const OwnedItemSummary({
    required this.ref,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.ownerLabel,
    this.locationLabel,
  });

  final OwnedItemRef ref;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? ownerLabel;
  final String? locationLabel;
}
