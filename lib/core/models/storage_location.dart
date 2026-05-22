class StorageLocation {
  const StorageLocation({
    required this.id,
    required this.name,
    this.parentId,
    this.description,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? parentId;
  final String? description;
  final int sortOrder;

  /// Build the full path label e.g. "Room > Shelf > Box 3"
  String fullPath(List<StorageLocation> allLocations) {
    final byId = {for (final location in allLocations) location.id: location};
    final visited = <String>{};
    final parts = <String>[];
    StorageLocation? current = this;
    while (current != null && visited.add(current.id)) {
      parts.insert(0, current.name);
      current = current.parentId == null ? null : byId[current.parentId!];
    }
    return parts.join(' › ');
  }

  StorageLocation copyWith({
    String? name,
    String? parentId,
    String? description,
    int? sortOrder,
  }) {
    return StorageLocation(
      id: id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
