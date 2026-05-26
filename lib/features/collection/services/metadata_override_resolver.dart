import 'package:collectarr_app/core/models/user_metadata_override.dart';

/// Resolves user metadata overrides for catalog display.
///
/// Given a list of active overrides for an item, this resolver returns the
/// user-corrected value for a field, or falls back to the original.
class MetadataOverrideResolver {
  MetadataOverrideResolver(Iterable<UserMetadataOverride> overrides)
      : _byField = {
          for (final o in overrides)
            if (!o.isDeleted) _key(o.fieldPath, o.editionId, o.variantId): o,
        };

  final Map<String, UserMetadataOverride> _byField;

  static String _key(String fieldPath, String? editionId, String? variantId) {
    if (variantId != null) return 'variant:$variantId:$fieldPath';
    if (editionId != null) return 'edition:$editionId:$fieldPath';
    return 'item:$fieldPath';
  }

  /// Whether any overrides exist.
  bool get hasOverrides => _byField.isNotEmpty;

  /// All active overrides.
  Iterable<UserMetadataOverride> get overrides => _byField.values;

  /// Look up the override for a top-level item field.
  UserMetadataOverride? findItemOverride(String fieldPath) =>
      _byField[_key(fieldPath, null, null)];

  /// Look up the override for an edition field.
  UserMetadataOverride? findEditionOverride(
    String editionId,
    String fieldPath,
  ) =>
      _byField[_key(fieldPath, editionId, null)];

  /// Look up the override for a variant field.
  UserMetadataOverride? findVariantOverride(
    String variantId,
    String fieldPath,
  ) =>
      _byField[_key(fieldPath, null, variantId)];

  /// Resolve a top-level item field: returns the override value if present,
  /// otherwise the [original] value.
  String? resolveItem(String fieldPath, String? original) {
    final override = findItemOverride(fieldPath);
    return override?.overrideValue ?? original;
  }

  /// Resolve an edition field.
  String? resolveEdition(
    String editionId,
    String fieldPath,
    String? original,
  ) {
    final override = findEditionOverride(editionId, fieldPath);
    return override?.overrideValue ?? original;
  }

  /// Resolve a variant field.
  String? resolveVariant(
    String variantId,
    String fieldPath,
    String? original,
  ) {
    final override = findVariantOverride(variantId, fieldPath);
    return override?.overrideValue ?? original;
  }

  /// Returns all overrides grouped by scope key.
  Map<String, List<UserMetadataOverride>> groupedByScope() {
    final result = <String, List<UserMetadataOverride>>{};
    for (final o in _byField.values) {
      result.putIfAbsent(o.scopeKey, () => <UserMetadataOverride>[]).add(o);
    }
    return result;
  }
}
