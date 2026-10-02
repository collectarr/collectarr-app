import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';

/// Resolves opaque kind-owned metadata overrides for catalog display.
///
/// The host compares Catalog Item references only. Field IDs and values remain
/// the responsibility of the owning kind.
class MetadataOverrideResolver {
  MetadataOverrideResolver(Iterable<UserMetadataOverride> overrides)
      : _byField = {
          for (final override in overrides)
            if (!override.isDeleted)
              _key(override.catalogRef, override.fieldId): override,
        };

  final Map<(CatalogItemRef, MetadataFieldId), UserMetadataOverride> _byField;

  static (CatalogItemRef, MetadataFieldId) _key(
    CatalogItemRef catalogRef,
    MetadataFieldId fieldId,
  ) =>
      (catalogRef, fieldId);

  bool get hasOverrides => _byField.isNotEmpty;

  Iterable<UserMetadataOverride> get overrides => _byField.values;

  UserMetadataOverride? find(
    CatalogItemRef catalogRef,
    MetadataFieldId fieldId,
  ) =>
      _byField[_key(catalogRef, fieldId)];

  String? resolve(
    CatalogItemRef catalogRef,
    MetadataFieldId fieldId,
    String? original,
  ) =>
      find(catalogRef, fieldId)?.overrideValue ?? original;

  Map<CatalogItemRef, List<UserMetadataOverride>> groupedByCatalogItem() {
    final result = <CatalogItemRef, List<UserMetadataOverride>>{};
    for (final override in _byField.values) {
      result
          .putIfAbsent(override.catalogRef, () => <UserMetadataOverride>[])
          .add(override);
    }
    return result;
  }
}
