import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/core/models/catalog_media_kind.dart';

const Object _catalogEntityRefUnset = Object();

enum CatalogEntityType {
  work('work'),
  season('season'),
  edition('edition'),
  release('release'),
  issue('issue'),
  episode('episode'),
  track('track'),
  bundleRelease('bundle_release'),
  ownedCopy('owned_copy'),
  trackingEntry('tracking_entry'),
  copy('copy'),
  unknown('unknown');

  const CatalogEntityType(this.apiValue);

  final String apiValue;

  static CatalogEntityType fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return CatalogEntityType.unknown;
    }
    for (final type in CatalogEntityType.values) {
      if (type.apiValue == normalized) {
        return type;
      }
    }
    return CatalogEntityType.unknown;
  }
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
  final CatalogEntityType entityType;
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
      entityType != CatalogEntityType.unknown;

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
          CatalogEntityType.fromApiValue(json['entity_type'] as String?),
      id: json['id'] as String? ?? '',
      rootId: json['root_id'] as String?,
    );
  }

  CatalogEntityRef copyWith({
    CatalogMediaKind? kind,
    CatalogEntityType? entityType,
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
