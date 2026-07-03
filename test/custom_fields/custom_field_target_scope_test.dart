import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('custom field values persist target and catalog ref payloads', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CustomFieldRepository(db);

    final ref = CatalogEntityRef(
      kind: 'book',
      entityType: CatalogEntityType.edition,
      id: 'book-edition-1',
    );
    final value = CustomFieldValue(
      id: 'val-1',
      targetId: 'book-edition-1',
      targetScope: CustomFieldTargetScope.edition,
      catalogRef: ref,
      fieldDefinitionId: 'def-1',
      value: 'Shelf A',
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await repo.upsertValueForTarget(value);

    final row = await (db.select(db.customFieldValuesCache)
          ..where((tbl) => tbl.id.equals('val-1')))
        .getSingle();

    expect(row.targetId, 'book-edition-1');
    expect(row.targetScope, 'edition');
    expect(row.catalogRefJson, jsonEncode(ref.toJson()));

    final values = await repo.listValuesForTarget(
      catalogRef: ref,
    );
    expect(values, hasLength(1));
    expect(values.single.catalogRef!.toJson(), ref.toJson());
  });
}
