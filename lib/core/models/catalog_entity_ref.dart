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

  static const _knownApiValues = <String>{
    'work',
    'season',
    'edition',
    'release',
    'issue',
    'episode',
    'track',
    'bundle_release',
    'owned_copy',
    'tracking_entry',
    'copy',
  };

  final String apiValue;

  static CatalogEntityTypeId fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return const CatalogEntityTypeId('unknown');
    }
    if (_knownApiValues.contains(normalized)) {
      return CatalogEntityTypeId(normalized);
    }
    return const CatalogEntityTypeId('unknown');
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
    };
  }

  factory CatalogEntityRef.fromJson(Map<String, Object?> json) {
    return CatalogEntityRef(
      kind: catalogMediaKindFromApiValue(json['kind'] as String?),
      entityType:
          CatalogEntityTypeId.fromApiValue(json['entity_type'] as String?),
      id: json['id'] as String? ?? '',
      rootId: json['root_id'] as String?,
    );
  }

  CatalogEntityRef copyWith({
    CatalogMediaKind? kind,
    CatalogEntityTypeId? entityType,
    String? id,
    Object? rootId = _catalogEntityRefUnset,
  }) {
    return CatalogEntityRef(
      kind: kind ?? this.kind,
      entityType: entityType ?? this.entityType,
      id: id ?? this.id,
      rootId: identical(rootId, _catalogEntityRefUnset)
          ? this.rootId
          : rootId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogEntityRef &&
            other.kind == kind &&
            other.entityType == entityType &&
            other.id == id &&
            other.rootId == rootId;
  }

  @override
  int get hashCode => Object.hash(kind, entityType, id, rootId);
}
