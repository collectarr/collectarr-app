import 'package:flutter/foundation.dart';

import 'catalog_entity_ref.dart';

/// Minimal catalog projection for mixed-kind/global hosts.
///
/// This is intentionally smaller than [CatalogItemDto]. A kind-specific
/// field must be resolved after dispatch through the owning kind repository.
@immutable
final class CatalogDisplaySummary {
  const CatalogDisplaySummary({
    required this.ref,
    required this.kind,
    required this.primaryLabel,
    this.subtitle,
    this.imageUrl,
  });

  factory CatalogDisplaySummary.root({
    required CatalogMediaKind kind,
    required String id,
    required String primaryLabel,
    String? subtitle,
    String? imageUrl,
  }) {
    return CatalogDisplaySummary(
      ref: CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityTypeId.root,
        id: id,
      ),
      kind: kind,
      primaryLabel: primaryLabel,
      subtitle: subtitle,
      imageUrl: imageUrl,
    );
  }

  final CatalogEntityRef ref;
  final CatalogMediaKind kind;

  /// UI label supplied by the owning kind; it is not a canonical field.
  final String primaryLabel;
  final String? subtitle;
  final String? imageUrl;

  String get id => ref.id;
}
