class UserFolder {
  const UserFolder({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.iconName,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String? iconName;
  final int sortOrder;

  UserFolder copyWith({
    String? name,
    String? description,
    String? parentId,
    String? iconName,
    int? sortOrder,
  }) {
    return UserFolder(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
