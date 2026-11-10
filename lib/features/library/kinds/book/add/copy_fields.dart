import 'package:flutter/material.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/ui/primitives/money_amount_field.dart';
import 'package:collectarr_app/features/library/forms/field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/selection_fields.dart';
import '../vocabulary/book_vocabularies.dart';
import 'draft.dart';

class BookManualCopyFields extends StatelessWidget {
  const BookManualCopyFields(
      {super.key, required this.draft, required this.onChanged});
  final BookAddDraft draft;
  final ValueChanged<BookAddDraft> onChanged;

  @override
  Widget build(BuildContext context) => Column(children: [
        LibrarySwitchField(
            label: 'Dust Jacket',
            value: draft.dustJacketPresent,
            onChanged: (value) =>
                onChanged(draft.copyWith(dustJacketPresent: value))),
        const SizedBox(height: 10),
        LibraryDropdownPickField<String>(
          label: 'Dust Jacket Condition',
          value: draft.dustJacketCondition,
          options: [
            for (final value in BookVocabularies.condition.builtIns)
              LibraryFieldOption(value: value, label: value)
          ],
          onChanged: (value) =>
              onChanged(draft.copyWith(dustJacketCondition: value ?? '')),
        ),
      ]);
}

Map<String, Widget> bookManualValueFields(
        BookAddDraft draft, ValueChanged<BookAddDraft> onChanged) =>
    {
      'market_value_cents': LibraryMoneyAmountField(
          label: 'My Value',
          amountMinorUnits: draft.marketValueCents,
          currency: AppFormats.current.currency,
          onChanged: (value) =>
              onChanged(draft.copyWith(marketValueCents: value))),
      'retail_price_cents': LibraryMoneyAmountField(
          label: 'Retail Price',
          amountMinorUnits: draft.retailPriceCents,
          currency: AppFormats.current.currency,
          onChanged: (value) =>
              onChanged(draft.copyWith(retailPriceCents: value))),
      'sell_price_cents': LibraryMoneyAmountField(
          label: 'Sold Price',
          amountMinorUnits: draft.sellPriceCents,
          currency: AppFormats.current.currency,
          onChanged: (value) =>
              onChanged(draft.copyWith(sellPriceCents: value))),
      'sold_at': LibraryPartialDateField.fullDate(
          label: 'Sold Date',
          date: draft.soldAt,
          onDateChanged: (value) => onChanged(draft.copyWith(soldAt: value))),
      'signed_by': LibraryFormField(
          label: 'Signed by',
          child: LibraryTextFormControl(
              initialValue: draft.signedBy ?? '',
              onChanged: (value) =>
                  onChanged(draft.copyWith(signedBy: value)))),
    };
