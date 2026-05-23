enum PersonalItemAnchorType {
  item('item', 'Media'),
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
    case 'variant':
    case 'release':
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