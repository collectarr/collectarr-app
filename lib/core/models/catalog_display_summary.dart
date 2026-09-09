import 'package:flutter/foundation.dart';

import 'catalog_entity_ref.dart';
import 'catalog_media_kind.dart';

/// Minimal catalog projection for mixed-kind/global hosts.
///
/// This is intentionally smaller than [CatalogItemDto]. A kind-specific
/// field must be resolved after dispatch through the owning kind repository.
@immutable
final class CatalogDisplaySummary {
  const CatalogDisplaySummary({
    required this.ref,
    required this.kind,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });

  factory CatalogDisplaySummary.work({
    required CatalogMediaKind kind,
    required String id,
    required String title,
    String? subtitle,
    String? imageUrl,
  }) {
    return CatalogDisplaySummary(
      ref: CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityType.work,
        id: id,
      ),
      kind: kind,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
    );
  }

  final CatalogEntityRef ref;
  final CatalogMediaKind kind;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  String get id => ref.id;
}
