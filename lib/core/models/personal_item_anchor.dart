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
    case 'variant':
    case 'release':
      return PersonalItemAnchorType.edition.apiValue;
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