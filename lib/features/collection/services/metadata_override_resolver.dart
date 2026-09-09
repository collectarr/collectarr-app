import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
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
              _key(override.targetRef, override.fieldId): override,
        };

  final Map<(CatalogEntityRef, MetadataFieldId), UserMetadataOverride> _byField;

  static (CatalogEntityRef, MetadataFieldId) _key(
    CatalogEntityRef target,
    MetadataFieldId fieldId,
  ) =>
      (target, fieldId);

  bool get hasOverrides => _byField.isNotEmpty;

  Iterable<UserMetadataOverride> get overrides => _byField.values;

  UserMetadataOverride? find(
    CatalogEntityRef target,
    MetadataFieldId fieldId,
  ) =>
      _byField[_key(target, fieldId)];

  String? resolve(
    CatalogEntityRef target,
    MetadataFieldId fieldId,
    String? original,
  ) =>
      find(target, fieldId)?.overrideValue ?? original;

  Map<CatalogEntityRef, List<UserMetadataOverride>> groupedByTarget() {
    final result = <CatalogEntityRef, List<UserMetadataOverride>>{};
    for (final override in _byField.values) {
      result
          .putIfAbsent(override.targetRef, () => <UserMetadataOverride>[])
          .add(override);
    }
    return result;
  }
}
