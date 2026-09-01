import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

class LibraryWorkspaceQuery {
  const LibraryWorkspaceQuery({
    required this.kind,
    required this.searchQuery,
    required this.facetValues,
    required this.sortId,
    required this.sortAscending,
    required this.groupId,
    required this.visibleColumnIds,
    this.collectionId,
    this.scopeId,
    this.presentationLevelId,
  });

  final CatalogMediaKind kind;
  final String searchQuery;
  final Map<LibraryFacetIdRuntime, Set<String>> facetValues;
  final LibrarySortIdRuntime? sortId;
  final bool sortAscending;
  final LibraryGroupIdRuntime? groupId;
  final Set<LibraryFieldIdRuntime> visibleColumnIds;
  final String? collectionId;
  final String? scopeId;
  final String? presentationLevelId;
}
