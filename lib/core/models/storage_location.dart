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
    final parts = <String>[];
    StorageLocation? current = this;
    while (current != null) {
      parts.insert(0, current.name);
      current = current.parentId != null
          ? allLocations
              .cast<StorageLocation?>()
              .firstWhere((l) => l!.id == current!.parentId, orElse: () => null)
          : null;
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
