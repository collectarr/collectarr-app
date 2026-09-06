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
              _key(override.targetRef, override.fieldPath): override,
        };

  final Map<String, UserMetadataOverride> _byField;

  static String _key(CatalogEntityRef target, String fieldPath) =>
      '${target.kind}:${target.entityType.apiValue}:${target.id}:$fieldPath';

  bool get hasOverrides => _byField.isNotEmpty;

  Iterable<UserMetadataOverride> get overrides => _byField.values;

  UserMetadataOverride? find(
    CatalogEntityRef target,
    String fieldPath,
  ) =>
      _byField[_key(target, fieldPath)];

  String? resolve(
    CatalogEntityRef target,
    String fieldPath,
    String? original,
  ) =>
      find(target, fieldPath)?.overrideValue ?? original;

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
