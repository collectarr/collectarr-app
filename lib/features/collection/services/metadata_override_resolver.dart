import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';

/// Resolves opaque kind-owned metadata overrides for catalog display.
///
/// The host compares structural references only. Field IDs and values remain
/// the responsibility of the owning kind.
class MetadataOverrideResolver {
  MetadataOverrideResolver(Iterable<UserMetadataOverride> overrides)
      : _byField = {
          for (final override in overrides)
            if (!override.isDeleted)
              _key(override.targetRef, override.fieldKey): override,
        };

  final Map<String, UserMetadataOverride> _byField;

  static String _key(CatalogEntityRef target, String fieldKey) =>
      '${target.kind}:${target.entityType.apiValue}:${target.id}:$fieldKey';

  bool get hasOverrides => _byField.isNotEmpty;

  Iterable<UserMetadataOverride> get overrides => _byField.values;

  UserMetadataOverride? find(
    CatalogEntityRef target,
    String fieldKey,
  ) =>
      _byField[_key(target, fieldKey)];

  String? resolve(
    CatalogEntityRef target,
    String fieldKey,
    String? original,
  ) =>
      find(target, fieldKey)?.overrideValue ?? original;

  Map<String, List<UserMetadataOverride>> groupedByScope() {
    final result = <String, List<UserMetadataOverride>>{};
    for (final override in _byField.values) {
      result
          .putIfAbsent(override.scopeKey, () => <UserMetadataOverride>[])
          .add(override);
    }
    return result;
  }
}
