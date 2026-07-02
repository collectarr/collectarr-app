enum CatalogEntityType {
  work('work'),
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
    final alias = switch (normalized) {
      'bundle-release' => 'bundle_release',
      'owned-copy' => 'owned_copy',
      'tracking-entry' => 'tracking_entry',
      'bundle' => 'bundle_release',
      'package' => 'bundle_release',
      'box_set' => 'bundle_release',
      'box-set' => 'bundle_release',
      'media' => 'work',
      _ => normalized,
    };
    for (final type in CatalogEntityType.values) {
      if (type.apiValue == alias) {
        return type;
      }
    }
    return CatalogEntityType.unknown;
  }
}

class CatalogEntityRef {
  const CatalogEntityRef({
    required this.kind,
    required this.entityType,
    required this.id,
  });

  final String kind;
  final CatalogEntityType entityType;
  final String id;

  bool get isKnown =>
      kind.trim().isNotEmpty &&
      id.trim().isNotEmpty &&
      entityType != CatalogEntityType.unknown;

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'entity_type': entityType.apiValue,
      'id': id,
    };
  }

  factory CatalogEntityRef.fromJson(Map<String, dynamic> json) {
    return CatalogEntityRef(
      kind: json['kind'] as String? ?? 'unknown',
      entityType:
          CatalogEntityType.fromApiValue(json['entity_type'] as String?),
      id: json['id'] as String? ?? '',
    );
  }

  CatalogEntityRef copyWith({
    String? kind,
    CatalogEntityType? entityType,
    String? id,
  }) {
    return CatalogEntityRef(
      kind: kind ?? this.kind,
      entityType: entityType ?? this.entityType,
      id: id ?? this.id,
    );
  }
}
