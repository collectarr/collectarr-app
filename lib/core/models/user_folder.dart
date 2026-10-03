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

  Map<String, Object?> toSyncPayload() => {
        'name': name,
        'description': description,
        'parent_id': parentId,
        'icon_name': iconName,
        'sort_order': sortOrder,
      };

  factory UserFolder.fromJson(Map<String, Object?> json) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('User folder name is required.');
    }
    return UserFolder(
      id: json['id'] as String,
      name: name,
      description: json['description'] as String?,
      parentId: json['parent_id'] as String?,
      iconName: json['icon_name'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

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
