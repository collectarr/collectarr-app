import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/settings/custom_fields_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('custom fields settings renders scoped rows without tile warnings',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CustomFieldRepository(db);
    await repo.upsertDefinition(
      CustomFieldDefinition(
        id: 'def-1',
        name: 'Release Notes',
        fieldType: 'text',
        mediaKind: 'movie',
        editScope: 'release',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomFieldsSettings(db: db),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Release Notes'), findsOneWidget);
    expect(find.text('Movie'), findsOneWidget);
    expect(find.text('Release'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
  });
}
