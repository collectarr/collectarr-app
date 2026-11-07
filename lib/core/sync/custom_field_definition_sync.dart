import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:uuid/uuid.dart';

/// Sync entity carrying a custom field's definition. Its values travel with
/// the entries that hold them.
const customFieldDefinitionEntityType = 'custom_field_definition';

SyncChange customFieldDefinitionChange(CustomFieldDefinition definition) =>
    SyncChange(
      id: const Uuid().v4(),
      entityType: customFieldDefinitionEntityType,
      entityId: definition.id,
      action: 'upsert',
      payload: {
        'name': definition.name,
        'field_type': definition.valueType.apiValue,
        'media_kind': definition.mediaKind,
        'edit_scope': definition.editScope,
        'sort_order': definition.sortOrder,
        'options': definition.options,
        'created_at': definition.createdAt.toUtc().toIso8601String(),
      },
      clientChangedAt: DateTime.now().toUtc(),
    );

SyncChange customFieldDefinitionDeletion(String id) => SyncChange(
      id: const Uuid().v4(),
      entityType: customFieldDefinitionEntityType,
      entityId: id,
      action: 'delete',
      payload: const {},
      clientChangedAt: DateTime.now().toUtc(),
    );

CustomFieldDefinition customFieldDefinitionFromSync(
  String id,
  Map<String, dynamic> payload,
) =>
    CustomFieldDefinition.fromJson({'id': id, ...payload});
