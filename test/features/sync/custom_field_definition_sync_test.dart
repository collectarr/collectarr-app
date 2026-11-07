import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/sync/custom_field_definition_sync.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late CustomFieldRepository repository;
  final definition = CustomFieldDefinition(
    id: 'f1',
    name: 'Signed by',
    fieldType: 'text',
    mediaKind: 'comic',
    createdAt: DateTime.utc(2026, 11, 7),
  );

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = CustomFieldRepository(db);
  });
  tearDown(() => db.close());

  test('saving and deleting a definition queue Sync changes', () async {
    final queue = SyncQueueRepository(db);
    await repository.upsertDefinition(definition);
    final saved = (await queue.listPending()).single;
    expect(saved.action, 'upsert');
    expect(saved.entityType, customFieldDefinitionEntityType);
    expect(saved.payload['name'], 'Signed by');

    // The queue keeps an entity's latest change.
    await repository.deleteDefinition('f1');
    final deleted = (await queue.listPending()).single;
    expect(deleted.action, 'delete');
    expect(deleted.entityId, 'f1');
  });

  test('reordering queues only the definitions that moved', () async {
    await repository.upsertDefinition(definition);
    await repository.upsertDefinition(CustomFieldDefinition(
      id: 'f2',
      name: 'Box',
      fieldType: 'text',
      sortOrder: 1,
      createdAt: DateTime.utc(2026, 11, 7),
    ));
    final queue = SyncQueueRepository(db);
    await queue.deleteMany([for (final c in await queue.listPending()) c.id]);

    await repository.reorderDefinitions(['f2', 'f1']);

    final changes = await queue.listPending();
    expect(changes.map((change) => change.entityId).toSet(), {'f1', 'f2'});
  });

  test('a definition from Sync is stored without queueing it back', () async {
    final payload = customFieldDefinitionChange(definition).payload;

    await repository
        .applySyncedDefinition(customFieldDefinitionFromSync('f1', payload));
    expect((await repository.listDefinitions()).single.name, 'Signed by');

    await repository.applySyncedDefinitionDelete('f1');
    expect(await repository.listDefinitions(), isEmpty);
    expect(await SyncQueueRepository(db).listPending(), isEmpty);
  });
}
