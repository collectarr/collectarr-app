import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_toolbar_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';

LibraryHierarchyCapability libraryHierarchyForKind(CatalogMediaKind kind) =>
    collectarrKindHierarchies[kind]!;

LibraryKindTopology libraryTopologyForKind(CatalogMediaKind kind) =>
    collectarrKindTopologies[kind]!;

LibraryTrackingTopology libraryTrackingTopologyForKind(CatalogMediaKind kind) =>
    collectarrKindTrackingTopologies[kind]!;

LibraryInspectorCapability libraryInspectorForKind(CatalogMediaKind kind) =>
    collectarrKindInspectors[kind]!;

WorkProjectionCapability<LibraryWorkspaceDto> libraryWorkCapabilityForKind(
  CatalogMediaKind kind,
) =>
    collectarrKindWorkCapabilities[kind]!;

ReleaseProjectionCapability<LibraryWorkspaceDto>?
    libraryReleaseCapabilityForKind(CatalogMediaKind kind) =>
        collectarrKindReleaseCapabilities[kind];

LibraryReleaseDetailSource? libraryReleaseDetailSourceForKind(
  CatalogMediaKind kind,
) =>
    collectarrKindReleaseDetailSources[kind];

LibraryCatalogTargetCapability libraryCatalogTargetForKind(
  CatalogMediaKind kind,
) =>
    collectarrKindCatalogTargets[kind]!;

LibraryKindToolbarModule? libraryToolbarForKind(CatalogMediaKind kind) =>
    collectarrKindToolbars[kind];

List<LibrarySearchTarget> librarySearchTargetOptionsForKind(
  CatalogMediaKind kind,
) =>
    collectarrKindSearchTargetOptions[kind] ?? const [];

LibraryWorkspaceViewProfile libraryViewProfileForKind(CatalogMediaKind kind) =>
    collectarrKindViewProfiles[kind]!;

LibraryKindWorkspace libraryWorkspaceForKind(CatalogMediaKind kind) =>
    collectarrKindWorkspaces[kind]!;

LibraryFacetModule? libraryFacetModuleForKind(CatalogMediaKind kind) =>
    collectarrKindFacetModules[kind];
