import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/inspector/inspector_custom_fields_section.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'inspector refreshes tab title and multi-value display after settings change',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CustomFieldRepository(db),
        entry = LibraryEntryRef.fromKey('music:album');
    await repo.upsertDefinition(CustomFieldDefinition(
        id: 'tags',
        name: 'Tags',
        fieldType: 'multiSelect',
        mediaKind: 'music',
        createdAt: DateTime.utc(2026)));
    await repo.upsertValue(CustomFieldValue(
        id: 'value',
        targetId: entry.key,
        targetScope: CustomFieldTargetScope.libraryEntry,
        fieldDefinitionId: 'tags',
        value: encodeCustomFieldMultiValues(['Red', 'Blue']),
        updatedAt: DateTime.utc(2026)));
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: Scaffold(
                body: InspectorCustomFieldsSection(
      libraryEntryRef: entry,
      db: db,
    )))));
    await tester.pumpAndSettle();
    expect(find.text('Red, Blue'), findsOneWidget);
    await const CustomFieldDisplaySettings(
            multiValueDisplay: CustomFieldMultiValueDisplay.list)
        .save('tags');
    await const CustomFieldsDisplaySettings(tabName: 'My Details')
        .save('music');
    final container = ProviderScope.containerOf(
        tester.element(find.byType(InspectorCustomFieldsSection)));
    invalidateInspectorCustomFields(container);
    await tester.pumpAndSettle();
    expect(find.text('My Details'), findsOneWidget);
    expect(find.text('Red\nBlue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
