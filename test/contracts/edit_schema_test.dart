import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

final class _Draft {
  String title = 'Fixture';
  num? quantity = 1;
  DateTime? date = DateTime(2026);
  int? priceCents = 100;
  String currency = 'EUR';
  bool enabled = true;
  String? status = 'active';
  Set<String> tags = {'one'};
  String? image = 'cover';
}

void main() {
  test('EditSchema composes typed tabs, sections, and field specs', () {
    final schema = EditSchema<int, _Draft>(
      title: (model) => 'Item $model',
      isDirty: (_, draft) => draft.title != 'Fixture',
      validate: (_, draft) => draft.title.isEmpty ? 'Title required' : null,
      tabs: [
        EditTabSpec<_Draft>(
          id: 'details',
          label: 'Details',
          sections: [
            EditSectionSpec<_Draft>(
              id: 'main',
              label: 'Main',
              fields: [
                LibraryTextFieldSpec<_Draft>(
                  id: 'title',
                  label: 'Title',
                  value: (draft) => draft.title,
                  setValue: (draft, value) => draft.title = value,
                ),
                LibraryNumberFieldSpec<_Draft>(
                  id: 'quantity',
                  label: 'Quantity',
                  value: (draft) => draft.quantity,
                  setValue: (draft, value) => draft.quantity = value,
                ),
                LibraryDateFieldSpec<_Draft>(
                  id: 'date',
                  label: 'Date',
                  value: (draft) => draft.date,
                  setValue: (draft, value) => draft.date = value,
                ),
                LibraryMoneyFieldSpec<_Draft>(
                  id: 'price',
                  label: 'Price',
                  cents: (draft) => draft.priceCents,
                  setCents: (draft, value) => draft.priceCents = value,
                  currency: (draft) => draft.currency,
                ),
                LibraryToggleFieldSpec<_Draft>(
                  id: 'enabled',
                  label: 'Enabled',
                  value: (draft) => draft.enabled,
                  setValue: (draft, value) => draft.enabled = value,
                ),
                LibrarySelectFieldSpec<_Draft, String>(
                  id: 'status',
                  label: 'Status',
                  value: (draft) => draft.status,
                  setValue: (draft, value) => draft.status = value,
                  options: const [
                    LibraryFieldOption(value: 'active', label: 'Active'),
                    LibraryFieldOption(value: 'archived', label: 'Archived'),
                  ],
                ),
                LibraryVocabularyFieldSpec<_Draft, String>(
                  id: 'vocabulary',
                  label: 'Vocabulary',
                  value: (draft) => draft.status,
                  setValue: (draft, value) => draft.status = value,
                  options: const [
                    LibraryFieldOption(value: 'active', label: 'Active'),
                  ],
                ),
                LibraryMultiVocabularyFieldSpec<_Draft, String>(
                  id: 'tags',
                  label: 'Tags',
                  values: (draft) => draft.tags,
                  setValues: (draft, values) => draft.tags = values,
                  options: const [
                    LibraryFieldOption(value: 'one', label: 'One'),
                    LibraryFieldOption(value: 'two', label: 'Two'),
                  ],
                ),
                LibraryImageFieldSpec<_Draft, String>(
                  id: 'image',
                  label: 'Image',
                  value: (draft) => draft.image,
                  setValue: (draft, value) => draft.image = value,
                ),
                LibraryReadOnlyFieldSpec<_Draft, String>(
                  id: 'readOnly',
                  label: 'Read only',
                  value: (draft) => draft.status,
                  display: (value) => value ?? 'None',
                ),
                LibraryCustomFieldSpec<_Draft>(
                  id: 'custom',
                  label: 'Custom',
                  builder: (context, draft) => Text(draft.title),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final draft = _Draft();

    expect(schema.tabs, hasLength(1));
    expect(schema.tabs.single.sections.single.fields, hasLength(11));
    expect(schema.title!(7), 'Item 7');
    expect(schema.isDirty!(7, draft), isFalse);
    expect(schema.validate!(7, draft), isNull);
    expect(schema.tabs.single.isVisible(draft), isTrue);

    final title = schema.tabs.single.sections.single.fields.first
        as LibraryTextFieldSpec<_Draft>;
    title.setValue(draft, 'Updated');
    expect(title.value(draft), 'Updated');
    expect(schema.isDirty!(7, draft), isTrue);
  });

  test('visibility and validation stay structural and draft-driven', () {
    final draft = _Draft()..title = '';
    final field = LibraryTextFieldSpec<_Draft>(
      id: 'title',
      label: 'Title',
      value: (value) => value.title,
      setValue: (value, text) => value.title = text,
      visibleWhen: (value) => value.enabled,
      validator: (value) => value.title.isEmpty ? 'Required' : null,
    );

    expect(field.isVisible(draft), isTrue);
    expect(field.validate(draft), 'Required');
    draft.enabled = false;
    expect(field.isVisible(draft), isFalse);
  });
}
