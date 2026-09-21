import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_entity_action_capability.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_action_registry.dart';

LibraryEntityActionCapability libraryEntityActionsForKind(
  CatalogMediaKind kind,
) {
  final capability = collectarrKindEntityActions[kind];
  if (capability == null) {
    throw ArgumentError('No entity actions registered for kind: $kind');
  }
  return capability;
}
