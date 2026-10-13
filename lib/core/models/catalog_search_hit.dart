import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:flutter/foundation.dart';

/// The intentionally small result shape used when a search crosses kinds.
///
/// A hit is enough to render a result and route a click. Full catalog payloads
/// must be loaded by the repository entry by [kind] after dispatch.
@immutable
final class CatalogSearchHit {
  CatalogSearchHit({
    required this.ref,
    required this.kind,
    String? title,
    String? primaryLabel,
    this.subtitle,
    this.imageUrl,
  }) : primaryLabel = primaryLabel ?? title ?? ref.id;

  factory CatalogSearchHit.fromJson(Map<String, Object?> json) {
    final id = json['id']?.toString().trim() ?? '';
    if (id.isEmpty) {
      throw const FormatException('Catalog search hit is missing id');
    }

    final rawKind = json['kind']?.toString().trim() ?? '';
    final kind = catalogMediaKindFromValue(rawKind);
    final label = _nullableString(
          json['primary_label'] ??
              json['primaryLabel'] ??
              json['title'] ??
              json['display_title'] ??
              json['name'],
        ) ??
        id;

    return CatalogSearchHit(
      ref: CatalogItemRef(kind: kind, id: id),
      kind: kind,
      primaryLabel: label,
      subtitle: _nullableString(json['subtitle'] ?? json['summary']),
      imageUrl: _nullableString(json['image_url']),
    );
  }

  final CatalogItemRef ref;
  final CatalogMediaKind kind;
  final String primaryLabel;
  String get title => primaryLabel;
  final String? subtitle;
  final String? imageUrl;

  Map<String, Object?> toJson() {
    return {
      'id': ref.id,
      'kind': kind.apiValue,
      'primary_label': primaryLabel,
      'title': primaryLabel,
      if (subtitle != null) 'subtitle': subtitle,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogSearchHit &&
            ref == other.ref &&
            kind == other.kind &&
            primaryLabel == other.primaryLabel &&
            subtitle == other.subtitle &&
            imageUrl == other.imageUrl;
  }

  @override
  int get hashCode => Object.hash(
        ref,
        kind,
        primaryLabel,
        subtitle,
        imageUrl,
      );
}

String? _nullableString(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
