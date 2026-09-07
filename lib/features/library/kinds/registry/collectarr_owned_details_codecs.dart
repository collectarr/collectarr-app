import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

/// Composition-root map for the common JSON owned-details boundary.
///
/// Generic persistence and sync code may use this map to decode a payload,
/// but it must not inspect the returned concrete details. Kind semantics stay
/// in the codec implementations under their owning kind.
final collectarrOwnedDetailsCodecs =
    Map<CatalogMediaKind, OwnedDetailsPersistenceCodec>.unmodifiable(
  collectarrKindOwnedDetailsCodecs,
);

OwnedDetailsPersistenceCodec collectarrOwnedDetailsCodecForKind(
  CatalogMediaKind kind,
) {
  final codec = collectarrOwnedDetailsCodecs[kind];
  if (codec == null) {
    throw ArgumentError('No owned-details codec registered for kind: $kind');
  }
  return codec;
}
