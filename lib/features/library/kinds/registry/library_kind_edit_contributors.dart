import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_edit_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

LibraryEditCapabilitySet libraryEditCapabilitiesForKind(
  CatalogMediaKind kind,
) =>
    collectarrKindEditCapabilities[kind]!;

LibraryEditPresentationCapability libraryEditPresentationForKind(
  CatalogMediaKind kind,
) =>
    libraryEditCapabilitiesForKind(kind).presentationCapability;

LibraryEditSessionCapability libraryEditSessionForKind(CatalogMediaKind kind) =>
    libraryEditCapabilitiesForKind(kind).session;

LibraryCoreCorrectionTarget resolveLibraryCoreCorrectionTargetForKind({
  required CatalogMediaKind kind,
  required LibraryEntityRef? node,
  required LibraryEntityScope? requestedScope,
  required CatalogEntityRef catalogRef,
}) =>
    libraryEditCapabilitiesForKind(kind).coreCorrectionTargetResolver(
      node: node,
      requestedScope: requestedScope,
      catalogRef: catalogRef,
    );

LibraryOwnedEditCapability libraryOwnedEditForKind(CatalogMediaKind kind) =>
    libraryEditCapabilitiesForKind(kind).owned;
