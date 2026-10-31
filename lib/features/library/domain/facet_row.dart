/// A named facet value and the library item IDs that belong to it.
final class LibraryFacetRow {
  const LibraryFacetRow({
    required this.name,
    required this.itemIds,
  });

  final String name;
  final List<String> itemIds;
}
