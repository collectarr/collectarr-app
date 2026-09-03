import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'add_contract.dart';

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

AddSchema<_Draft> _buildSchema() {
  return AddSchema<_Draft>(
    title: (draft) => 'Add ${draft.title}',
    validate: (draft) => draft.title.isEmpty ? 'Title required' : null,
    sections: [
      AddSectionSpec<_Draft>(
        id: 'main',
        label: 'Main',
        fields: [
          TextAddField<_Draft>(
            id: 'title',
            label: 'Title',
            value: (draft) => draft.title,
            setValue: (draft, value) => draft.title = value,
          ),
          NumberAddField<_Draft>(
            id: 'quantity',
            label: 'Quantity',
            value: (draft) => draft.quantity,
            setValue: (draft, value) => draft.quantity = value,
          ),
          DateAddField<_Draft>(
            id: 'date',
            label: 'Date',
            value: (draft) => draft.date,
            setValue: (draft, value) => draft.date = value,
          ),
          MoneyAddField<_Draft>(
            id: 'price',
            label: 'Price',
            cents: (draft) => draft.priceCents,
            setCents: (draft, value) => draft.priceCents = value,
            currency: (draft) => draft.currency,
          ),
          ToggleAddField<_Draft>(
            id: 'enabled',
            label: 'Enabled',
            value: (draft) => draft.enabled,
            setValue: (draft, value) => draft.enabled = value,
          ),
          SelectAddField<_Draft, String>(
            id: 'status',
            label: 'Status',
            value: (draft) => draft.status,
            setValue: (draft, value) => draft.status = value,
            options: const [
              EditOption(value: 'active', label: 'Active'),
              EditOption(value: 'archived', label: 'Archived'),
            ],
          ),
          VocabularyAddField<_Draft, String>(
            id: 'vocabulary',
            label: 'Vocabulary',
            value: (draft) => draft.status,
            setValue: (draft, value) => draft.status = value,
            options: const [EditOption(value: 'active', label: 'Active')],
          ),
          MultiVocabularyAddField<_Draft, String>(
            id: 'tags',
            label: 'Tags',
            values: (draft) => draft.tags,
            setValues: (draft, values) => draft.tags = values,
            options: const [
              EditOption(value: 'one', label: 'One'),
              EditOption(value: 'two', label: 'Two'),
            ],
          ),
          ImageAddField<_Draft, String>(
            id: 'image',
            label: 'Image',
            value: (draft) => draft.image,
            setValue: (draft, value) => draft.image = value,
          ),
          ReadOnlyAddField<_Draft, String>(
            id: 'readOnly',
            label: 'Read only',
            value: (draft) => draft.status,
            display: (value) => value ?? 'None',
          ),
          CustomAddField<_Draft>(
            id: 'custom',
            label: 'Custom',
            builder: (context, draft) => Text(draft.title),
          ),
        ],
      ),
    ],
  );
}

void main() {
  defineAddContract<AddSchema<_Draft>>(
    name: 'structural add schema',
    create: _buildSchema,
    fieldIds: (schema) => [
      for (final section in schema.sections)
        for (final field in section.fields) field.id,
    ],
    label: (schema, fieldId) => [
      for (final section in schema.sections)
        for (final field in section.fields)
          if (field.id == fieldId) field.label,
    ].single,
  );

  test('AddSchema keeps typed fields structural and draft-driven', () {
    final schema = _buildSchema();
    final draft = _Draft();

    expect(schema.sections, hasLength(1));
    expect(schema.sections.single.fields, hasLength(11));
    expect(schema.title!(draft), 'Add Fixture');
    expect(schema.validate!(draft), isNull);
    expect(schema.sections.single.isVisible(draft), isTrue);

    final title = schema.sections.single.fields.first as TextAddField<_Draft>;
    title.setValue(draft, 'Updated');
    expect(title.value(draft), 'Updated');

    final tags = schema.sections.single.fields[7]
        as MultiVocabularyAddField<_Draft, String>;
    tags.setValues(draft, {'two'});
    expect(tags.values(draft), {'two'});
  });

  test('AddSchema supports visibility and field validation', () {
    final draft = _Draft()..title = '';
    final field = TextAddField<_Draft>(
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
