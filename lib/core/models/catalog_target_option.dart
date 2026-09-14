import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/foundation.dart';

/// A target choice rendered by a generic host.
///
/// The host only displays the label and returns the complete reference. It
/// never interprets the reference's entity type; that meaning belongs to the
/// owning kind that supplied the option.
@immutable
final class CatalogTargetOption {
  const CatalogTargetOption({
    required this.ref,
    required this.label,
  });

  final CatalogEntityRef ref;
  final String label;
}
