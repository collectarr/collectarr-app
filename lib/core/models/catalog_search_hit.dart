import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/foundation.dart';

/// The intentionally small result shape used when a search crosses kinds.
///
/// A hit is enough to render a result and route a click. Full catalog payloads
/// must be loaded by the repository owned by [kind] after dispatch.
@immutable
final class CatalogSearchHit {
  const CatalogSearchHit({
    required this.ref,
    required this.kind,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });

  factory CatalogSearchHit.fromCatalogItem(CatalogItem item) {
    return CatalogSearchHit(
      ref: item.catalogRef,
      kind: item.mediaKind,
      title: item.resolvedDisplayTitle,
      subtitle: item.itemNumber ?? item.editionTitle,
      imageUrl: item.displayCoverUrl,
    );
  }

  factory CatalogSearchHit.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    if (id.isEmpty) {
      throw const FormatException('Catalog search hit is missing id');
    }

    final rawKind = json['kind']?.toString().trim() ?? '';
    final kind = catalogMediaKindFromValue(rawKind);
    final title = json['title']?.toString().trim() ?? '';
    if (title.isEmpty) {
      throw const FormatException('Catalog search hit is missing title');
    }

    return CatalogSearchHit(
      ref: CatalogEntityRef(
        kind: kind.apiValue,
        entityType: json['entity_type'] == null
            ? CatalogEntityType.work
            : CatalogEntityType.fromApiValue(
                json['entity_type']?.toString(),
              ),
        id: id,
      ),
      kind: kind,
      title: title,
      subtitle: _nullableString(json['subtitle'] ?? json['summary']),
      imageUrl: _nullableString(json['image_url']),
    );
  }

  final CatalogEntityRef ref;
  final CatalogMediaKind kind;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': ref.id,
      'kind': kind.apiValue,
      'entity_type': ref.entityType.apiValue,
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogSearchHit &&
            ref.kind == other.ref.kind &&
            ref.entityType == other.ref.entityType &&
            ref.id == other.ref.id &&
            kind == other.kind &&
            title == other.title &&
            subtitle == other.subtitle &&
            imageUrl == other.imageUrl;
  }

  @override
  int get hashCode => Object.hash(
        ref.kind,
        ref.entityType,
        ref.id,
        kind,
        title,
        subtitle,
        imageUrl,
      );
}

String? _nullableString(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
