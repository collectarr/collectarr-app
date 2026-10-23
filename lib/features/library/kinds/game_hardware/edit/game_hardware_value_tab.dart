import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/library_entry_personal_section.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_segmented_choice_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../domain/game_hardware_completeness.dart';
import '../entries/game_hardware_entry_details.dart';

abstract interface class GameHardwareValueBindings {
  GameHardwareEntryDetails get details;
  int? get valueCents;
  String get currency;
  void setDetails(GameHardwareEntryDetails details);
  void setValueCents(int? value);
}

Map<String, Widget> gameHardwareValueFields(GameHardwareValueBindings b) => {
      'completeness': LibrarySegmentedChoiceField<GameHardwareCompleteness?>(
          label: 'Completeness',
          options: [
            (null, 'N/A'),
            for (final tier in GameHardwareCompleteness.values)
              (tier, tier.label)
          ],
          value: b.details.completeness,
          onChanged: (tier) {
            final included =
                tier != null && tier != GameHardwareCompleteness.loose;
            b.setDetails(b.details.copyWith(
              completeness: tier,
              hasBox: included,
              hasManual: included,
            ));
          }),
      'box_manual': Wrap(spacing: 18, children: [
        _checkField('Box', b.details.hasBox ?? false,
            (value) => b.setDetails(b.details.copyWith(hasBox: value))),
        _checkField('Manual', b.details.hasManual ?? false,
            (value) => b.setDetails(b.details.copyWith(hasManual: value))),
      ]),
      'market_value_cents': Builder(
          builder: (context) => Stack(children: [
                LibraryMoneyAmountField(
                    label: 'Value',
                    amountMinorUnits: b.valueCents,
                    currency: b.currency,
                    onChanged: b.setValueCents),
                Positioned(
                    right: 0,
                    top: 2,
                    child: Tooltip(
                        message: b.details.valueIsLocked == true
                            ? 'Unlock the value'
                            : 'Lock the value',
                        child: InkWell(
                            onTap: () => b.setDetails(b.details.copyWith(
                                valueIsLocked:
                                    b.details.valueIsLocked != true)),
                            child: Icon(
                                b.details.valueIsLocked == true
                                    ? AppIcons.lock
                                    : AppIcons.lockOpen,
                                size: 14,
                                color: appPalette(context).textMuted)))),
              ])),
      'valuations': Builder(
          builder: (context) => Container(
              height: 310,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border.all(color: appPalette(context).divider),
                  borderRadius: BorderRadius.circular(4)),
              child: Column(children: [
                const Text('Values from PriceCharting'),
                Expanded(
                    child: Center(
                        child: Text('No PriceCharting values recorded',
                            style: TextStyle(
                                color: appPalette(context).textMuted))))
              ]))),
      'pricecharting_id': LibraryFormField(
          label: 'PriceCharting ID',
          child: LibraryTextFormControl(
              initialValue: b.details.priceChartingId ?? '',
              onChanged: (text) => b.setDetails(b.details.copyWith(
                  priceChartingId: text.trim().isEmpty ? null : text.trim())))),
    };
Widget _checkField(String label, bool checked, ValueChanged<bool> onChanged) =>
    Builder(
        builder: (context) => Semantics(
            label: label,
            checked: checked,
            child: InkWell(
                onTap: () => onChanged(!checked),
                child: SizedBox(
                    height: 24,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      LibraryFieldCheckbox(
                          state: checked
                              ? LibraryFieldCheckState.all
                              : LibraryFieldCheckState.none),
                      const SizedBox(width: 6),
                      Text(label,
                          style: TextStyle(
                              fontSize: 14,
                              color: appPalette(context).textPrimary))
                    ])))));
Widget gameHardwareValueLayout(Map<String, Widget> fields, Widget? history) {
  Widget field(String key) => fields[key] ?? const SizedBox.shrink();
  Widget row(List<String> keys) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final (index, key) in keys.indexed) ...[
          if (index > 0) const SizedBox(width: 14),
          Expanded(child: field(key))
        ]
      ]));
  final left =
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    row(['completeness', 'market_value_cents']),
    row(['box_manual']),
    row(['condition', '']),
    row(['price_paid_cents', 'purchase_store']),
    row(['purchase_date', ''])
  ]);
  final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        field('valuations'),
        const SizedBox(height: 12),
        field('pricecharting_id')
      ]);
  return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 900
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [left, right])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 69, child: left),
              const SizedBox(width: 14),
              Expanded(flex: 48, child: right)
            ]));
}

/// Completeness and Box/Manual of the reference Hardware pre-fill.
List<Widget> gameHardwarePrefillFields(LibraryEntryEditDraft draft) {
  final fields = gameHardwareValueFields(_EntryBindings(draft));
  return [fields['completeness']!, fields['box_manual']!];
}

final class GameHardwareValueTab extends StatelessWidget {
  const GameHardwareValueTab({super.key, required this.draft});
  final LibraryEntryEditDraft draft;
  @override
  Widget build(BuildContext context) => LibraryEntryPersonalSection(
      draft: draft,
      additionalFields: gameHardwareValueFields(_EntryBindings(draft)),
      layoutBuilder: gameHardwareValueLayout);
}

final class _EntryBindings implements GameHardwareValueBindings {
  const _EntryBindings(this.draft);
  final LibraryEntryEditDraft draft;
  @override
  GameHardwareEntryDetails get details =>
      GameHardwareEntryDetails.fromJson(draft.values);
  @override
  int? get valueCents => draft.number('market_value_cents');
  @override
  String get currency => draft.text('currency').isEmpty
      ? AppFormats.current.currency
      : draft.text('currency');
  @override
  void setDetails(GameHardwareEntryDetails details) {
    final previous = this.details.toJson();
    final next = details.toJson();
    for (final key in {...previous.keys, ...next.keys}) {
      draft.set(key, next[key]);
    }
  }

  @override
  void setValueCents(int? value) => draft.set('market_value_cents', value);
}
