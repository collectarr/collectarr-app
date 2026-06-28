class CustomFieldDefinition {
  const CustomFieldDefinition({
    required this.id,
    required this.name,
    required this.fieldType,
    this.mediaKind,
    this.editScope,
    this.sortOrder = 0,
    this.options,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String fieldType; // text, number, date, bool, select
  final String? mediaKind; // null = all media types
  final String? editScope; // null = all edit scopes, otherwise media/release
  final int sortOrder;
  final String? options; // JSON array for select type
  final DateTime createdAt;

  factory CustomFieldDefinition.fromJson(Map<String, dynamic> json) {
    return CustomFieldDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      fieldType: json['field_type'] as String,
      mediaKind: json['media_kind'] as String?,
      editScope: json['edit_scope'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      options: json['options'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'name': name,
      'field_type': fieldType,
      'media_kind': mediaKind,
      'edit_scope': editScope,
      'sort_order': sortOrder,
      'options': options,
    };
  }

  CustomFieldDefinition copyWith({
    String? id,
    String? name,
    String? fieldType,
    String? mediaKind,
    String? editScope,
    int? sortOrder,
    String? options,
    DateTime? createdAt,
  }) {
    return CustomFieldDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      mediaKind: mediaKind ?? this.mediaKind,
      editScope: editScope ?? this.editScope,
      sortOrder: sortOrder ?? this.sortOrder,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CustomFieldValue {
  const CustomFieldValue({
    required this.id,
    required this.ownedItemId,
    required this.fieldDefinitionId,
    this.value,
    required this.updatedAt,
  });

  final String id;
  final String ownedItemId;
  final String fieldDefinitionId;
  final String? value;
  final DateTime updatedAt;

  factory CustomFieldValue.fromJson(Map<String, dynamic> json) {
    return CustomFieldValue(
      id: json['id'] as String,
      ownedItemId: json['owned_item_id'] as String,
      fieldDefinitionId: json['field_definition_id'] as String,
      value: json['value'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'owned_item_id': ownedItemId,
      'field_definition_id': fieldDefinitionId,
      'value': value,
    };
  }

  CustomFieldValue copyWith({
    String? id,
    String? ownedItemId,
    String? fieldDefinitionId,
    String? value,
    DateTime? updatedAt,
  }) {
    return CustomFieldValue(
      id: id ?? this.id,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      fieldDefinitionId: fieldDefinitionId ?? this.fieldDefinitionId,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
