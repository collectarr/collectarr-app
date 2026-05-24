enum PersonalItemAnchorType {
  item('item', 'Media'),
  edition('edition', 'Edition'),
  variant('variant', 'Physical release'),
  bundleRelease('bundle_release', 'Bundle release');

  const PersonalItemAnchorType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PersonalItemAnchorType? fromApiValue(String? value) {
    final normalized = normalizePersonalItemAnchorType(value);
    if (normalized == null) {
      return null;
    }
    for (final anchor in PersonalItemAnchorType.values) {
      if (anchor.apiValue == normalized) {
        return anchor;
      }
    }
    return null;
  }
}

class PersonalItemAnchor {
  const PersonalItemAnchor._({
    required this.type,
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
  });

  final PersonalItemAnchorType type;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;

  String get apiValue => type.apiValue;

  static PersonalItemAnchor? fromRaw({
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    final type = resolvePersonalItemAnchor(
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (type == null) {
      return null;
    }

    final normalizedEditionId = _normalizedAnchorId(editionId);
    final normalizedVariantId = _normalizedAnchorId(variantId);
    final normalizedBundleReleaseId = _normalizedAnchorId(bundleReleaseId);

    return PersonalItemAnchor._(
      type: type,
      editionId: switch (type) {
        PersonalItemAnchorType.edition || PersonalItemAnchorType.variant =>
          normalizedEditionId,
        _ => null,
      },
      variantId: type == PersonalItemAnchorType.variant ? normalizedVariantId : null,
      bundleReleaseId: type == PersonalItemAnchorType.bundleRelease
          ? normalizedBundleReleaseId
          : null,
    );
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'anchor_type': apiValue,
      'edition_id': editionId,
      'variant_id': variantId,
      'bundle_release_id': bundleReleaseId,
    };
  }
}

String? normalizePersonalItemAnchorType(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  switch (normalized) {
    case 'item':
    case 'media':
    case 'work':
      return PersonalItemAnchorType.item.apiValue;
    case 'edition':
    case 'release':
      return PersonalItemAnchorType.edition.apiValue;
    case 'variant':
      return PersonalItemAnchorType.variant.apiValue;
    case 'physical_release':
    case 'physical-release':
      return PersonalItemAnchorType.variant.apiValue;
    case 'bundle_release':
    case 'bundle-release':
    case 'bundle':
    case 'package':
    case 'box_set':
    case 'box-set':
      return PersonalItemAnchorType.bundleRelease.apiValue;
    default:
      return null;
  }
}

PersonalItemAnchorType? resolvePersonalItemAnchor({
  String? anchorType,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final normalized = normalizePersonalItemAnchorType(anchorType);
  final hasBundleRelease = _hasAnchorValue(bundleReleaseId);
  final hasVariant = _hasAnchorValue(variantId);
  final hasEdition = _hasAnchorValue(editionId);

  if (normalized == PersonalItemAnchorType.item.apiValue) {
    return PersonalItemAnchorType.item;
  }
  if (hasBundleRelease ||
      normalized == PersonalItemAnchorType.bundleRelease.apiValue) {
    return PersonalItemAnchorType.bundleRelease;
  }
  if (hasVariant || normalized == PersonalItemAnchorType.variant.apiValue) {
    return hasVariant
        ? PersonalItemAnchorType.variant
        : hasEdition
        ? PersonalItemAnchorType.edition
        : PersonalItemAnchorType.variant;
  }
  if (hasEdition || normalized == PersonalItemAnchorType.edition.apiValue) {
    return PersonalItemAnchorType.edition;
  }
  return normalized == null ? null : PersonalItemAnchorType.fromApiValue(normalized);
}

String? resolvePersonalItemAnchorType({
  String? anchorType,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  return resolvePersonalItemAnchor(
    anchorType: anchorType,
    editionId: editionId,
    variantId: variantId,
    bundleReleaseId: bundleReleaseId,
  )?.apiValue;
}

bool _hasAnchorValue(String? value) {
  final trimmed = value?.trim();
  return trimmed != null && trimmed.isNotEmpty;
}

String? _normalizedAnchorId(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}