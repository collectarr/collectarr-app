import 'package:collectarr_app/core/models/catalog_media_kind.dart';

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
  final Map<String, Set<String>> facetValues;
  final String? sortId;
  final bool sortAscending;
  final String? groupId;
  final Set<String> visibleColumnIds;
  final String? collectionId;
  final String? scopeId;
  final String? presentationLevelId;
}
