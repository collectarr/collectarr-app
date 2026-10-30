import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_segmented_choice_field.dart';
import '../domain/comic_personal_data.dart';
import 'entry_draft.dart';
import 'entry_fields.dart';
import '../vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_responsive_form_row.dart';
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

  void _collectorChanged() =>
      update(personal.copyWith(details: entry.toDetails()));
  Widget _collector(String id) =>
      buildComicEntryField(id: id, draft: entry, onChanged: _collectorChanged);
  Widget _common(String id) => commonFields[id] ?? const SizedBox.shrink();

  @override
  Widget build(BuildContext context) => valueTab ? _value() : _personal();

  Widget _value() => _stack([
        _row([
          _stack([
            _row([
              LibraryManagedVocabularyField(
                  label: 'Grade',
                  listName: ComicVocabularyIds.grade.value,
                  mediaKind: 'comic',
                  value: personal.grade ?? 'Ungraded',
                  builtIns: ComicVocabularies.grade.builtIns,
                  onChanged: (value) =>
                      update(personal.copyWith(grade: value))),
              LibrarySegmentedChoiceField<String>(
                  label: 'Raw / Slabbed',
                  value: entry.rawOrSlabbed ?? 'Raw',
                  options: const [('Raw', 'Raw'), ('Slabbed', 'Slabbed')],
                  onChanged: (value) {
                    entry.rawOrSlabbed = value;
                    _collectorChanged();
                  }),
            ]),
            _row([
              LibraryMoneyAmountField(
                  label: 'My Value',
                  amountMinorUnits: personal.marketValueCents,
                  currency: currency,
                  onChanged: (value) =>
                      update(personal.copyWith(marketValueCents: value))),
              _common('currency'),
            ]),
            _collector('signed_by'),
          ]),
          _stack([
            _row([
              _collector('grading_company'),
              _collector('certification_number')
            ]),
            _collector('grader_notes'),
          ]),
        ], breakpoint: 720),
        _row([
          _collector('label_type'),
          _collector('custom_label'),
          _collector('page_quality')
        ]),
        _row([
          LibrarySegmentedChoiceField<String>(
              label: 'Key',
              value: entry.keyComic ? entry.keySeverity : 'No',
              options: const [
                ('Major', 'Major'),
                ('Minor', 'Minor'),
                ('Trivia', 'Trivia'),
                ('No', 'No')
              ],
              onChanged: (value) {
                entry.keyComic = value != 'No';
                entry.keySeverity = entry.keyComic ? value : null;
                _collectorChanged();
              }),
          _collector('key_reason'),
          _collector('key_category'),
        ]),
        _row([
          _common('price_paid_cents'),
          _common('purchase_date'),
          _common('purchase_store'),
          LibraryMoneyAmountField(
              label: 'Cover Price',
              amountMinorUnits: entry.coverPriceCents,
              currency: currency,
              onChanged: (value) {
                entry.coverPriceCents = value;
                _collectorChanged();
              }),
        ]),
        _row([
          LibraryMoneyAmountField(
              label: 'Price Sold',
              amountMinorUnits: personal.sellPriceCents,
              currency: currency,
              onChanged: (value) =>
                  update(personal.copyWith(sellPriceCents: value))),
          LibraryPartialDateField.fullDate(
              label: 'Sold Date',
              date: personal.soldAt,
              onDateChanged: (value) =>
                  update(personal.copyWith(soldAt: value))),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
        ]),
      ]);

  Widget _personal() => _row([
        _stack([
          _row([
            LibrarySegmentedChoiceField<bool>(
                label: 'Read',
                options: const [(false, 'No'), (true, 'Yes')],
                value: personal.reading.status == 'Read',
                onChanged: (value) => update(personal.copyWith(
                    reading: personal.reading
                        .copyWith(status: value ? 'Read' : 'Unread')))),
            LibraryPartialDateField.fullDate(
                label: 'Read Date',
                date: personal.reading.finishedAt,
                onDateChanged: (value) => update(personal.copyWith(
                    reading: personal.reading.copyWith(finishedAt: value)))),
          ]),
          _common('personal_notes'),
        ]),
        _stack([
          _row([
            _common('owner_label'),
            LibraryFormField(
                label: 'My Rating',
                child: LibraryTextFormControl(
                    initialValue: personal.reading.rating?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }
                      final rating = int.tryParse(value);
                      return rating == null || rating < 0 || rating > 10
                          ? 'Use a rating from 0 to 10'
                          : null;
                    },
                    onChanged: (value) => update(personal.copyWith(
                        reading: personal.reading
                            .copyWith(rating: int.tryParse(value)))))),
          ]),
          _common('tags'),
          LibraryPartialDateField.fullDate(
              label: 'Bag/Board Date',
              date: entry.lastBagBoardDate,
              onDateChanged: (value) {
                entry.lastBagBoardDate = value;
                _collectorChanged();
              }),
        ]),
      ], breakpoint: 720);
}

Widget _stack(List<Widget> children) =>
    Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) const SizedBox(height: 12),
        children[index],
      ]
    ]);
Widget _row(List<Widget> children, {double breakpoint = 300}) =>
    LibraryResponsiveFormRow(
      breakpoint: children.length >= 4
          ? 800
          : children.length == 3
              ? 600
              : breakpoint,
      horizontalGap: 14,
      verticalGap: 12,
      children: [
        for (final child in children) LibraryResponsiveFormItem(child: child)
      ],
    );
