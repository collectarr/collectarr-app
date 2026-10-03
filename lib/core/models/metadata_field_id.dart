import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

/// Opaque metadata field identity used by in-memory override APIs.
///
/// The owning kind supplies [value]. Generic persistence and sync only emit
/// [serializedValue] at their explicit string boundary.
@immutable
final class MetadataFieldId {
  const MetadataFieldId({
    required this.kind,
    required this.value,
  });

  final CatalogMediaKind kind;
  final String value;

  String get serializedValue => value;

  bool appliesTo(CatalogMediaKind target) => target == kind;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MetadataFieldId && other.kind == kind && other.value == value;
  }

  @override
  int get hashCode => Object.hash(kind, value);
}
