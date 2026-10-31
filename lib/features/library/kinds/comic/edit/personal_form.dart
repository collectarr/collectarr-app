import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/fixed_select_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/segmented_choice_field.dart';
import '../domain/comic_personal_data.dart';
import 'entry_draft.dart';
import 'entry_fields.dart';
import 'grading_options.dart';
import 'package:collectarr_app/features/library/ui/primitives/responsive_form_row.dart';
import 'package:flutter/material.dart';

class ComicPersonalForm extends StatelessWidget {
  const ComicPersonalForm(
      {super.key,
      required this.personal,
      required this.entry,
      required this.valueTab,
      required this.update,
      required this.commonFields});
  final ComicPersonalData personal;
  final ComicEntryEditDraft entry;
  final bool valueTab;

  /// Prices are in the currency chosen in Settings and store it with them.
  String get currency => AppFormats.current.currency;
  final ValueChanged<ComicPersonalData> update;
  final Map<String, Widget> commonFields;

  void _collectorChanged() =>
      update(personal.copyWith(details: entry.toDetails()));
  Widget _collector(String id) =>
      buildComicEntryField(id: id, draft: entry, onChanged: _collectorChanged);
  Widget _common(String id) => commonFields[id] ?? const SizedBox.shrink();

  @override
  Widget build(BuildContext context) => valueTab ? _value() : _personal();

  // The reference's Value tab, 1170 px wide: two 578 px halves, then rows
  // whose widths follow its 282 / 381 / 479 px columns.
  Widget _value() => _stack([
        _row([
          _stack([
            _row([
              LibraryFixedSelectField(
                  label: 'Grade',
                  value: personal.grade,
                  options: comicGradeOptions,
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
            ], flexes: const [
              331,
              233
            ]),
            // The reference shows its CovrPrice value before My Value.
            _row([
              const SizedBox.shrink(),
              LibraryMoneyAmountField(
                  label: 'My Value',
                  amountMinorUnits: personal.marketValueCents,
                  currency: currency,
                  onChanged: (value) => update(personal.copyWith(
                      marketValueCents: value, currency: currency))),
            ], flexes: const [
              381,
              183
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
          LibraryFixedSelectField(
              label: 'Label Type',
              value: entry.labelType,
              options: comicLabelTypeOptions,
              onChanged: (value) {
                entry.labelType = value;
                _collectorChanged();
              }),
          _collector('custom_label'),
          LibraryFixedSelectField(
              label: 'Page Quality',
              value: entry.pageQuality,
              options: comicPageQualityOptions,
              onChanged: (value) {
                entry.pageQuality = value;
                _collectorChanged();
              })
        ], flexes: const [
          381,
          479,
          282
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
        ], flexes: const [
          282,
          479,
          381
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
                update(personal.copyWith(
                    details: entry.toDetails(), currency: currency));
              }),
        ]),
        _row([
          LibraryMoneyAmountField(
              label: 'Price Sold',
              amountMinorUnits: personal.sellPriceCents,
              currency: currency,
              onChanged: (value) => update(personal.copyWith(
                  sellPriceCents: value, currency: currency))),
          LibraryPartialDateField.fullDate(
              label: 'Sold Date',
              date: personal.soldAt,
              onDateChanged: (value) =>
                  update(personal.copyWith(soldAt: value))),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
        ]),
      ]);

  // The reference's Personal tab: Read, Read Date and Notes on the left;
  // Owner, My Rating and Tags across the right half, Bag/Board Date in its
  // first 282 px.
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
          _common('owner_label'),
          _ComicRatingField(
              rating: personal.reading.rating,
              onChanged: (value) => update(personal.copyWith(
                  reading: personal.reading.copyWith(rating: value)))),
          _common('tags'),
          _row([
            LibraryPartialDateField.fullDate(
                label: 'Bag/Board Date',
                date: entry.lastBagBoardDate,
                onDateChanged: (value) {
                  entry.lastBagBoardDate = value;
                  _collectorChanged();
                }),
            const SizedBox.shrink(),
          ]),
        ]),
      ], breakpoint: 720);
}

/// My Rating as the reference's ten-step row, kept in the reading state.
class _ComicRatingField extends StatefulWidget {
  const _ComicRatingField({required this.rating, required this.onChanged});

  final int? rating;
  final ValueChanged<int?> onChanged;

  @override
  State<_ComicRatingField> createState() => _ComicRatingFieldState();
}

class _ComicRatingFieldState extends State<_ComicRatingField> {
  late final _controller = TextEditingController(text: '${widget.rating ?? 0}')
    ..addListener(_changed);

  void _changed() {
    final value = int.tryParse(_controller.text) ?? 0;
    final rating = value == 0 ? null : value;
    if (rating != widget.rating) widget.onChanged(rating);
  }

  @override
  void didUpdateWidget(_ComicRatingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = '${widget.rating ?? 0}';
    if (_controller.text != text) _controller.text = text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LibraryFormField(
      label: 'My Rating',
      child: MediaRatingField(
          controller: _controller, showLabel: false, compact: true));
}

Widget _stack(List<Widget> children) =>
    Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) const SizedBox(height: 12),
        children[index],
      ]
    ]);
Widget _row(List<Widget> children,
        {double breakpoint = 300, List<int>? flexes}) =>
    LibraryResponsiveFormRow(
      breakpoint: children.length >= 4
          ? 800
          : children.length == 3
              ? 600
              : breakpoint,
      horizontalGap: 14,
      verticalGap: 12,
      children: [
        for (var index = 0; index < children.length; index++)
          LibraryResponsiveFormItem(
              child: children[index], flex: flexes?[index] ?? 1)
      ],
    );
