import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_edit_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

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

LibraryOwnedEditCapability libraryOwnedEditForKind(CatalogMediaKind kind) =>
    libraryEditCapabilitiesForKind(kind).owned;
