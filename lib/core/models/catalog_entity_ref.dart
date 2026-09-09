import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/core/models/catalog_media_kind.dart';

const Object _catalogEntityRefUnset = Object();

/// Opaque entity identity carried by structural cross-feature references.
///
/// The owning kind decides which entity types it supports. Generic code may
/// transport and compare this identifier, but must not treat the identifier
/// set as a universal media ontology.
@immutable
final class CatalogEntityTypeId {
  const CatalogEntityTypeId(this.apiValue);

  final String apiValue;

  static CatalogEntityTypeId fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return const CatalogEntityTypeId('unknown');
    }
    // Entity types are owned by the kind that interprets them. Core must keep
    // unknown/future identifiers opaque so a newer server can round-trip
    // through an older v1 client without silently changing the target.
    return CatalogEntityTypeId(normalized);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogEntityTypeId && other.apiValue == apiValue;

  @override
  int get hashCode => apiValue.hashCode;
}

@immutable
class CatalogEntityRef {
  const CatalogEntityRef({
    required this.kind,
    required this.entityType,
    required this.id,
    this.rootId,
    this.parentId,
  });

  /// The owning media kind is typed in memory. It is serialized as the
  /// stable API value only at transport/database boundaries.
  final CatalogMediaKind kind;
  final CatalogEntityTypeId entityType;
  final String id;

  /// Root catalog entity used to group child targets in feature projections.
  ///
  /// This is structural reference context, not kind metadata. It is present
  /// for targets such as editions and releases that belong to a work.
  final String? rootId;

  /// Immediate structural parent for nested catalog targets.
  ///
  /// This is intentionally an opaque identifier. It lets a target such as a
  /// release preserve both its work and edition context without making core
  /// aware of the owning kind's hierarchy.
  final String? parentId;

  CatalogMediaKind get mediaKind => kind;

  bool get isKnown =>
      !kind.isUnknown &&
      id.trim().isNotEmpty &&
      entityType != const CatalogEntityTypeId('unknown');

  Map<String, Object?> toJson() {
    return {
      'kind': kind.apiValue,
      'entity_type': entityType.apiValue,
      'id': id,
      if (rootId != null) 'root_id': rootId,
      if (parentId != null) 'parent_id': parentId,
    };
  }

  factory CatalogEntityRef.fromJson(Map<String, Object?> json) {
    return CatalogEntityRef(
      kind: catalogMediaKindFromApiValue(json['kind'] as String?),
      entityType:
          CatalogEntityTypeId.fromApiValue(json['entity_type'] as String?),
      id: json['id'] as String? ?? '',
      rootId: json['root_id'] as String?,
      parentId: json['parent_id'] as String?,
    );
  }

  CatalogEntityRef copyWith({
    CatalogMediaKind? kind,
    CatalogEntityTypeId? entityType,
    String? id,
    Object? rootId = _catalogEntityRefUnset,
    Object? parentId = _catalogEntityRefUnset,
  }) {
    return CatalogEntityRef(
      kind: kind ?? this.kind,
      entityType: entityType ?? this.entityType,
      id: id ?? this.id,
      rootId: identical(rootId, _catalogEntityRefUnset)
          ? this.rootId
          : rootId as String?,
      parentId: identical(parentId, _catalogEntityRefUnset)
          ? this.parentId
          : parentId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogEntityRef &&
            other.kind == kind &&
            other.entityType == entityType &&
            other.id == id &&
            other.rootId == rootId &&
            other.parentId == parentId;
  }

  @override
  int get hashCode => Object.hash(kind, entityType, id, rootId, parentId);
}
