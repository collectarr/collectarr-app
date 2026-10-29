import 'package:collectarr_app/features/library/edit/fields/edit_value_fields.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_segmented_choice_field.dart';
import '../domain/comic_personal_data.dart';
import 'entry/entry_draft.dart';
import 'entry/fields.dart';
import '../vocabulary/comic_vocabularies.dart';
import 'package:flutter/material.dart';

class ComicPersonalForm extends StatelessWidget {
  const ComicPersonalForm(
      {super.key,
      required this.personal,
      required this.entry,
      required this.valueTab,
      required this.currency,
      required this.update,
      required this.commonFields});
  final ComicPersonalData personal;
  final ComicEntryEditDraft entry;
  final bool valueTab;
  final String currency;
  final ValueChanged<ComicPersonalData> update;
  final Map<String, Widget> commonFields;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: valueTab
            ? [
                LibraryManagedVocabularyField(
                  label: 'Grade',
                  listName: ComicVocabularyIds.grade.value,
                  mediaKind: 'comic',
                  value: personal.grade ?? 'Ungraded',
                  builtIns: ComicVocabularies.grade.builtIns,
                  onChanged: (value) => update(personal.copyWith(grade: value)),
                ),
                const SizedBox(height: 12),
                buildComicEntryFields(
                    draft: entry,
                    onChanged: () =>
                        update(personal.copyWith(details: entry.toDetails()))),
                const SizedBox(height: 12),
                LibraryMoneyAmountField(
                    label: 'My Value',
                    amountMinorUnits: personal.marketValueCents,
                    currency: currency,
                    onChanged: (value) =>
                        update(personal.copyWith(marketValueCents: value))),
                ..._common(commonFields, const [
                  'price_paid_cents',
                  'purchase_date',
                  'purchase_store',
                  'currency'
                ]),
                LibraryMoneyAmountField(
                    label: 'Price Sold',
                    amountMinorUnits: personal.sellPriceCents,
                    currency: currency,
                    onChanged: (value) =>
                        update(personal.copyWith(sellPriceCents: value))),
                const SizedBox(height: 12),
                LibraryDateFieldButton(
                    label: 'Sold Date',
                    value: personal.soldAt,
                    onChanged: (value) =>
                        update(personal.copyWith(soldAt: value))),
              ]
            : [
                LibrarySegmentedChoiceField<bool>(
                    label: 'Read',
                    options: const [(false, 'No'), (true, 'Yes')],
                    value: personal.reading.status == 'Read',
                    onChanged: (value) => update(personal.copyWith(
                        reading: personal.reading
                            .copyWith(status: value ? 'Read' : 'Unread')))),
                const SizedBox(height: 12),
                LibraryDateFieldButton(
                    label: 'Read Date',
                    value: personal.reading.finishedAt,
                    onChanged: (value) => update(personal.copyWith(
                        reading:
                            personal.reading.copyWith(finishedAt: value)))),
                ..._common(
                    commonFields, const ['personal_notes', 'owner_label']),
                LibraryFormField(
                    label: 'My Rating',
                    child: LibraryTextFormControl(
                        initialValue: personal.reading.rating?.toString() ?? '',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return null;
                          final rating = int.tryParse(value);
                          return rating == null || rating < 0 || rating > 10
                              ? 'Use a rating from 0 to 10'
                              : null;
                        },
                        onChanged: (value) => update(personal.copyWith(
                            reading: personal.reading
                                .copyWith(rating: int.tryParse(value)))))),
                ..._common(commonFields, const ['tags']),
                LibraryDateFieldButton(
                    label: 'Bag/Board Date',
                    value: entry.lastBagBoardDate,
                    onChanged: (value) {
                      entry.lastBagBoardDate = value;
                      update(personal.copyWith(details: entry.toDetails()));
                    }),
              ],
      );
}

List<Widget> _common(Map<String, Widget> fields, List<String> keys) => [
      for (final key in keys)
        if (fields[key] case final field?)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 6), child: field),
    ];
