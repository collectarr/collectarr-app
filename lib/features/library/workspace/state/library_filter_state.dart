class LibraryFilterState {
  const LibraryFilterState({
    this.searchQuery = '',
    this.facetValues = const {},
    this.groupId,
    this.sortId,
    this.sortAscending = true,
    this.visibleColumnIds = const {},
    this.presentationLevelId,
  });

  final String searchQuery;
  final Map<String, Set<String>> facetValues;
  final String? groupId;
  final String? sortId;
  final bool sortAscending;
  final Set<String> visibleColumnIds;
  final String? presentationLevelId;

  LibraryFilterState copyWith({
    String? searchQuery,
    Map<String, Set<String>>? facetValues,
    String? Function()? groupId,
    String? Function()? sortId,
    bool? sortAscending,
    Set<String>? visibleColumnIds,
    String? Function()? presentationLevelId,
  }) {
    return LibraryFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      facetValues: facetValues ?? this.facetValues,
      groupId: groupId != null ? groupId() : this.groupId,
      sortId: sortId != null ? sortId() : this.sortId,
      sortAscending: sortAscending ?? this.sortAscending,
      visibleColumnIds: visibleColumnIds ?? this.visibleColumnIds,
      presentationLevelId: presentationLevelId != null
          ? presentationLevelId()
          : this.presentationLevelId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryFilterState &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          _mapEquals(facetValues, other.facetValues) &&
          groupId == other.groupId &&
          sortId == other.sortId &&
          sortAscending == other.sortAscending &&
          _setEquals(visibleColumnIds, other.visibleColumnIds) &&
          presentationLevelId == other.presentationLevelId;

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      facetValues.hashCode ^
      groupId.hashCode ^
      sortId.hashCode ^
      sortAscending.hashCode ^
      visibleColumnIds.hashCode ^
      presentationLevelId.hashCode;
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    final valA = a[key];
    final valB = b[key];
    if (valA is Set && valB is Set) {
      if (!_setEquals(valA, valB)) return false;
    } else {
      if (valA != valB) return false;
    }
  }
  return true;
}
