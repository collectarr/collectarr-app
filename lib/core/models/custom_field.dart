import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

enum CustomFieldTargetScope {
  work('work'),
  edition('edition'),
  release('release'),
  issue('issue'),
  episode('episode'),
  track('track'),
  ownedCopy('ownedCopy'),
  trackingEntry('trackingEntry'),
  media('media'),
  all('all');

  const CustomFieldTargetScope(this.apiValue);

  final String apiValue;

  static CustomFieldTargetScope fromApiValue(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return CustomFieldTargetScope.media;
    }
    for (final scope in CustomFieldTargetScope.values) {
      if (scope.apiValue == normalized) {
        return scope;
      }
    }
    return CustomFieldTargetScope.media;
  }
}

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
  final String?
      editScope; // legacy column; now stores custom field target scope
  final int sortOrder;
  final String? options; // JSON array for select type
  final DateTime createdAt;

  CustomFieldTargetScope get targetScope =>
      CustomFieldTargetScope.fromApiValue(editScope);

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
    CustomFieldTargetScope? targetScope,
    int? sortOrder,
    String? options,
    DateTime? createdAt,
  }) {
    return CustomFieldDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      mediaKind: mediaKind ?? this.mediaKind,
      editScope: editScope ?? targetScope?.apiValue ?? this.editScope,
      sortOrder: sortOrder ?? this.sortOrder,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CustomFieldValue {
  const CustomFieldValue({
    required this.id,
    required this.targetId,
    required this.targetScope,
    this.catalogRef,
    required this.fieldDefinitionId,
    this.value,
    required this.updatedAt,
  });

  final String id;
  final String targetId;
  final CustomFieldTargetScope targetScope;
  final CatalogEntityRef? catalogRef;
  final String fieldDefinitionId;
  final String? value;
  final DateTime updatedAt;

  factory CustomFieldValue.fromJson(Map<String, dynamic> json) {
    return CustomFieldValue(
      id: json['id'] as String,
      targetId: json['target_id'] as String,
      targetScope:
          CustomFieldTargetScope.fromApiValue(json['target_scope'] as String?),
      catalogRef: json['catalog_ref'] is Map<String, dynamic>
          ? CatalogEntityRef.fromJson(
              json['catalog_ref'] as Map<String, dynamic>)
          : null,
      fieldDefinitionId: json['field_definition_id'] as String,
      value: json['value'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'target_id': targetId,
      'target_scope': targetScope.apiValue,
      if (catalogRef != null) 'catalog_ref': catalogRef!.toJson(),
      'field_definition_id': fieldDefinitionId,
      'value': value,
    };
  }

  CustomFieldValue copyWith({
    String? id,
    String? targetId,
    CustomFieldTargetScope? targetScope,
    CatalogEntityRef? catalogRef,
    String? fieldDefinitionId,
    String? value,
    DateTime? updatedAt,
  }) {
    return CustomFieldValue(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetScope: targetScope ?? this.targetScope,
      catalogRef: catalogRef ?? this.catalogRef,
      fieldDefinitionId: fieldDefinitionId ?? this.fieldDefinitionId,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
