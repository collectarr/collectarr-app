import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late CustomFieldRepository repo;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repo = CustomFieldRepository(db);
  });

  tearDown(() => db.close());

  group('definitions', () {
    test('listDefinitions returns empty initially', () async {
      expect(await repo.listDefinitions(), isEmpty);
    });

    test('upsertDefinition inserts and retrieves', () async {
      final def = CustomFieldDefinition(
        id: 'def-1',
        name: 'Location',
        fieldType: 'text',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await repo.upsertDefinition(def);
      final defs = await repo.listDefinitions();
      expect(defs, hasLength(1));
      expect(defs.single.id, 'def-1');
      expect(defs.single.name, 'Location');
      expect(defs.single.fieldType, 'text');
      expect(defs.single.mediaKind, isNull);
    });

    test('upsertDefinition updates existing', () async {
      final def = CustomFieldDefinition(
        id: 'def-1',
        name: 'Location',
        fieldType: 'text',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await repo.upsertDefinition(def);
      await repo.upsertDefinition(def.copyWith(name: 'Storage Location'));
      final defs = await repo.listDefinitions();
      expect(defs, hasLength(1));
      expect(defs.single.name, 'Storage Location');
    });

    test('listDefinitions filters by mediaKind', () async {
      await repo.upsertDefinition(CustomFieldDefinition(
        id: 'def-1',
        name: 'CGC Grade',
        fieldType: 'text',
        mediaKind: 'comic',
        createdAt: DateTime.utc(2026, 1, 1),
      ));
      await repo.upsertDefinition(CustomFieldDefinition(
        id: 'def-2',
        name: 'Platform',
        fieldType: 'singleSelect',
        mediaKind: 'game',
        createdAt: DateTime.utc(2026, 1, 1),
      ));
      await repo.upsertDefinition(CustomFieldDefinition(
        id: 'def-3',
        name: 'Favourite',
        fieldType: 'boolean',
        createdAt: DateTime.utc(2026, 1, 1),
      ));

      final comicDefs = await repo.listDefinitions(mediaKind: 'comic');
      expect(comicDefs.map((d) => d.name),
          containsAll(['CGC Grade', 'Favourite']));
      expect(comicDefs.map((d) => d.name), isNot(contains('Platform')));

      final gameDefs = await repo.listDefinitions(mediaKind: 'game');
      expect(
          gameDefs.map((d) => d.name), containsAll(['Platform', 'Favourite']));
    });

    test('listDefinitions filters by editScope', () async {
      await repo.upsertDefinition(CustomFieldDefinition(
        id: 'def-1',
        name: 'Release Notes',
        fieldType: 'text',
        editScope: 'release',
        createdAt: DateTime.utc(2026, 1, 1),
      ));
      await repo.upsertDefinition(CustomFieldDefinition(
        id: 'def-2',
        name: 'Shelf Note',
        fieldType: 'text',
        editScope: 'media',
        createdAt: DateTime.utc(2026, 1, 1),
      ));
      await repo.upsertDefinition(CustomFieldDefinition(
        id: 'def-3',
        name: 'Shared Note',
        fieldType: 'text',
        createdAt: DateTime.utc(2026, 1, 1),
      ));

      final releaseDefs = await repo.listDefinitions(editScope: 'release');
      expect(
        releaseDefs.map((d) => d.name),
        containsAll(['Release Notes', 'Shared Note']),
      );
      expect(releaseDefs.map((d) => d.name), isNot(contains('Shelf Note')));

      final mediaDefs = await repo.listDefinitions(editScope: 'media');
      expect(
        mediaDefs.map((d) => d.name),
        containsAll(['Shelf Note', 'Shared Note']),
      );
      expect(mediaDefs.map((d) => d.name), isNot(contains('Release Notes')));
    });

    test('target scope is derived from editScope', () async {
      final def = CustomFieldDefinition(
        id: 'def-1',
        name: 'Storage Box',
        fieldType: 'text',
        editScope: CustomFieldTargetScope.ownedCopy.apiValue,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await repo.upsertDefinition(def);
      final defs = await repo.listDefinitions(
        targetScope: CustomFieldTargetScope.ownedCopy,
      );
      expect(defs, hasLength(1));
      expect(defs.single.targetScope, CustomFieldTargetScope.ownedCopy);
    });

    test('deleteDefinition removes definition', () async {
      await repo.upsertDefinition(CustomFieldDefinition(
        id: 'def-1',
        name: 'Location',
        fieldType: 'text',
        createdAt: DateTime.utc(2026, 1, 1),
      ));
      await repo.deleteDefinition('def-1');
      expect(await repo.listDefinitions(), isEmpty);
    });
  });

  group('values', () {
    test('listValuesForTarget returns empty initially', () async {
      expect(
        await repo.listValuesForTarget(
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
        ),
        isEmpty,
      );
    });

    test('upsertValue inserts and retrieves', () async {
      final value = CustomFieldValue(
        id: 'val-1',
        targetId: 'owned-1',
        targetScope: CustomFieldTargetScope.ownedCopy,
        fieldDefinitionId: 'def-1',
        value: 'Shelf A',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      await repo.upsertValue(value);
      final values = await repo.listValuesForTarget(
        targetId: 'owned-1',
        targetScope: CustomFieldTargetScope.ownedCopy,
      );
      expect(values, hasLength(1));
      expect(values.single.value, 'Shelf A');
      expect(values.single.fieldDefinitionId, 'def-1');
    });

    test('upsertValues batch inserts', () async {
      await repo.upsertValues([
        CustomFieldValue(
          id: 'val-1',
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-1',
          value: 'A',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        CustomFieldValue(
          id: 'val-2',
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-2',
          value: 'B',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      final values = await repo.listValuesForTarget(
        targetId: 'owned-1',
        targetScope: CustomFieldTargetScope.ownedCopy,
      );
      expect(values, hasLength(2));
    });

    test('listAllValues groups by target id', () async {
      await repo.upsertValues([
        CustomFieldValue(
          id: 'val-1',
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-1',
          value: 'A',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        CustomFieldValue(
          id: 'val-2',
          targetId: 'owned-2',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-1',
          value: 'B',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        CustomFieldValue(
          id: 'val-3',
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-2',
          value: 'C',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      final all = await repo.listAllValues();
      expect(all.keys, containsAll(['owned-1', 'owned-2']));
      expect(all['owned-1'], hasLength(2));
      expect(all['owned-2'], hasLength(1));
    });

    test('upsertValueForTarget preserves explicit target id', () async {
      final value = CustomFieldValue(
        id: 'val-1',
        targetId: 'target-99',
        targetScope: CustomFieldTargetScope.trackingEntry,
        fieldDefinitionId: 'def-1',
        value: 'Shelf A',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      await repo.upsertValueForTarget(value);
      final values = await repo.listValuesForTarget(
        targetId: 'target-99',
        targetScope: CustomFieldTargetScope.trackingEntry,
      );
      expect(values, hasLength(1));
      expect(values.single.targetId, 'target-99');
      expect(values.single.targetScope, CustomFieldTargetScope.trackingEntry);
    });

    test('deleteValuesForTarget removes all values for target', () async {
      await repo.upsertValues([
        CustomFieldValue(
          id: 'val-1',
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-1',
          value: 'A',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        CustomFieldValue(
          id: 'val-2',
          targetId: 'owned-2',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-1',
          value: 'B',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      await repo.deleteValuesForTarget(
        targetId: 'owned-1',
        targetScope: CustomFieldTargetScope.ownedCopy,
      );
      expect(
        await repo.listValuesForTarget(
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
        ),
        isEmpty,
      );
      expect(
        await repo.listValuesForTarget(
          targetId: 'owned-2',
          targetScope: CustomFieldTargetScope.ownedCopy,
        ),
        hasLength(1),
      );
    });

    test('upsertValues with empty list is no-op', () async {
      await repo.upsertValues([]);
      expect(await repo.listAllValues(), isEmpty);
    });
  });
}
