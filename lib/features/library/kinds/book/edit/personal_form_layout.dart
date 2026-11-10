import 'package:flutter/material.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/ui/primitives/money_amount_field.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/personal_fields_layout.dart';
import 'package:collectarr_app/features/library/ui/primitives/segmented_choice_field.dart';
import '../vocabulary/book_vocabularies.dart';

void _setDetail(LibraryEntryEditDraft draft, String key, Object? value) =>
    draft.set(key, value);

Map<String, Widget> bookPersonalAdditionalFields(LibraryEntryEditDraft draft) {
  final details = draft.values;
  return {
    'condition': LibraryManagedVocabularyField(
      label: 'Book Condition',
      listName: BookVocabularyIds.condition.value,
      mediaKind: 'book',
      value: draft.text('condition'),
      builtIns: BookVocabularies.condition.builtIns,
      onChanged: (value) => draft.set('condition', value),
    ),
    'dust_jacket': LibrarySegmentedChoiceField<bool>(
      label: 'Dust Jacket',
      options: const [(false, 'No'), (true, 'Yes')],
      value: details['dust_jacket_present'] == true,
      onChanged: (value) => _setDetail(draft, 'dust_jacket_present', value),
    ),
    'dust_jacket_condition': LibraryManagedVocabularyField(
      label: 'Dust Jacket Condition',
      listName: BookVocabularyIds.condition.value,
      mediaKind: 'book',
      value: details['dust_jacket_condition'] as String?,
      builtIns: BookVocabularies.condition.builtIns,
      onChanged: (value) => _setDetail(draft, 'dust_jacket_condition', value),
    ),
  };
}

Map<String, Widget> bookValueAdditionalFields(LibraryEntryEditDraft draft) => {
      'market_value_cents': LibraryMoneyAmountField(
          label: 'My Value',
          amountMinorUnits: draft.number('market_value_cents'),
          currency: draft.text('currency').isEmpty
              ? AppFormats.current.currency
              : draft.text('currency'),
          onChanged: (value) => draft.set('market_value_cents', value)),
      'retail_price_cents': LibraryMoneyAmountField(
          label: 'Retail Price',
          amountMinorUnits:
              (draft.values['retail_price_cents'] as num?)?.toInt(),
          currency: draft.text('currency').isEmpty
              ? AppFormats.current.currency
              : draft.text('currency'),
          onChanged: (value) => _setDetail(draft, 'retail_price_cents', value)),
      'sell_price_cents': LibraryMoneyAmountField(
          label: 'Sold Price',
          amountMinorUnits: draft.number('sell_price_cents'),
          currency: draft.text('currency').isEmpty
              ? AppFormats.current.currency
              : draft.text('currency'),
          onChanged: (value) => draft.set('sell_price_cents', value)),
      'sold_at': LibraryPartialDateField.fullDate(
          label: 'Sold Date',
          date: DateTime.tryParse(draft.text('sold_at')),
          onDateChanged: (value) =>
              draft.set('sold_at', value?.toIso8601String())),
      'signed_by': LibraryFormField(
          label: 'Signed by',
          child: LibraryTextFormControl(
            initialValue: draft.values['signed_by'] as String? ?? '',
            onChanged: (value) => _setDetail(
                draft, 'signed_by', value.trim().isEmpty ? null : value.trim()),
          )),
    };

Widget bookPersonalFormLayout(Map<String, Widget> fields, Widget? history) {
  Widget stack(List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i],
          ]
        ],
      );
  Widget? field(String key) => fields[key];
  return LayoutBuilder(builder: (context, constraints) {
    final jacket = [
      if (field('dust_jacket') case final item?) item,
      if (field('dust_jacket_condition') case final item?) item
    ];
    final left = <Widget>[
      if (field('owner_label') case final item?) item,
      if (field('condition') case final item?) item,
      if (jacket.isNotEmpty)
        LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth < 300
                ? stack(jacket)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < jacket.length; i++) ...[
                        if (i > 0) const SizedBox(width: 14),
                        Expanded(child: jacket[i]),
                      ]
                    ],
                  )),
      if (field('tags') case final item?) item,
    ];
    final right = <Widget>[
      if (field('rating') case final item?) item,
      if (field('personal_notes') case final item?) item,
      if (history != null) history,
    ];
    if (constraints.maxWidth < 680) return stack([...left, ...right]);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: stack(left)),
      const SizedBox(width: 14),
      Expanded(child: stack(right)),
    ]);
  });
}

Widget bookValueFormLayout(Map<String, Widget> fields, Widget? history) =>
    LibraryPersonalFieldsLayout(
      fields: [
        for (final key in [
          'market_value_cents',
          'retail_price_cents',
          'price_paid_cents',
          'sell_price_cents',
          'purchase_date',
          'sold_at',
          'purchase_store',
          'signed_by'
        ])
          if (fields[key] != null) fields[key]!
      ],
    );
