import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_toolbar_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';

LibraryHierarchyCapability libraryHierarchyForKind(CatalogMediaKind kind) =>
    collectarrKindHierarchies[kind] ?? const LibraryHierarchyCapability();

LibraryTargetVocabulary libraryEntityVocabularyForKind(CatalogMediaKind kind) =>
    collectarrKindEntityVocabularies[kind]!;

LibraryTrackingTopology libraryTrackingTopologyForKind(CatalogMediaKind kind) =>
    collectarrKindTrackingTopologies[kind]!;

LibraryInspectorCapability libraryInspectorForKind(CatalogMediaKind kind) =>
    collectarrKindInspectors[kind]!;

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
