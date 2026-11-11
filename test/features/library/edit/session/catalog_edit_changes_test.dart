import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/edit/session/catalog_edit_changes.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('snapshot owns nested data and ignores map insertion order', () {
    final fields = <String, Object?>{
      'title': 'Reference',
      'credits': [
        {'name': 'Author', 'role': 'author'}
      ],
    };
    final changes = LibraryCatalogEditChanges(
      initialCatalogFields: fields,
      customFieldValues: const [],
    );
    expect(
        changes.hasChanges({
          'credits': [
            {'role': 'author', 'name': 'Author'}
          ],
          'title': 'Reference',
        }),
        isFalse);
    (fields['credits'] as List).clear();
    expect(changes.hasChanges(fields), isTrue);
  });

  test('custom fields compare by value and can return to their baseline', () {
    final changes = LibraryCatalogEditChanges(
      initialCatalogFields: const {},
      customFieldValues: [
        for (final id in ['first', 'second'])
          CustomFieldValue(
            id: id,
            targetId: 'entry',
            targetScope: CustomFieldTargetScope.libraryEntry,
            fieldDefinitionId: id,
            value: id,
            updatedAt: DateTime.utc(2026),
          ),
      ],
    );
    final values = {'second': 'second', 'first': 'first'};
    changes.customFields = values;
    values.clear();
    expect(changes.hasChanges(const {}), isFalse);
    changes.customFields = {'second': 'second', 'first': null};
    expect(changes.hasChanges(const {}), isTrue);
    changes.customFields = {'first': 'first', 'second': 'second'};
    expect(changes.hasChanges(const {}), isFalse);
    expect(() => changes.customFields.clear(), throwsUnsupportedError);
  });

  test('cover and personal image edits independently keep the editor dirty',
      () {
    final changes = LibraryCatalogEditChanges(
      initialCatalogFields: const {},
      customFieldValues: const [],
    );
    final edits = [const ItemImageEdit(id: 'cover', deleted: true)];
    changes.covers = edits;
    edits.clear();
    expect(changes.hasChanges(const {}), isTrue);
    changes.images = [const ItemImageEdit(id: 'personal', caption: 'Updated')];
    changes.covers = [];
    expect(changes.hasChanges(const {}), isTrue);
    changes.images = [];
    expect(changes.hasChanges(const {}), isFalse);
  });
}
