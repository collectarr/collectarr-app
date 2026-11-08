import '../vocabulary/game_hardware_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/managed_vocabulary_field.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/entry_personal_section.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/responsive_form_row.dart';
import 'package:collectarr_app/features/library/ui/primitives/segmented_choice_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/field_selection.dart';
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
  String? get condition;
  void setCondition(String? value);
}

Map<String, Widget> gameHardwareValueFields(GameHardwareValueBindings b) => {
      'condition': LibraryManagedVocabularyField(
        label: 'Condition',
        listName: GameHardwareVocabularies.condition.id.value,
        mediaKind: 'game_hardware',
        value: b.condition,
        onChanged: b.setCondition,
      ),
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
      'market_value_cents': LibraryLockableMoneyField(
          amountMinorUnits: b.valueCents,
          currency: b.currency,
          locked: b.details.valueIsLocked == true,
          onLockedChanged: (locked) =>
              b.setDetails(b.details.copyWith(valueIsLocked: locked)),
          onChanged: b.setValueCents),
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
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      row(['completeness', 'pricecharting_id']),
      row(['box_manual', '']),
      row(['condition', 'market_value_cents']),
      LibraryResponsiveFormRow(
        breakpoint: 560,
        horizontalGap: 14,
        verticalGap: 12,
        children: [
          LibraryResponsiveFormItem(child: field('price_paid_cents')),
          LibraryResponsiveFormItem(child: field('purchase_store')),
          LibraryResponsiveFormItem(child: field('purchase_date')),
        ],
      ),
    ],
  );
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
  Widget build(BuildContext context) => AnimatedBuilder(
      // The fields read the draft when built, so a choice must rebuild them.
      animation: draft,
      builder: (context, _) => LibraryEntryPersonalSection(
          draft: draft,
          additionalFields: gameHardwareValueFields(_EntryBindings(draft)),
          layoutBuilder: gameHardwareValueLayout));
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
  @override
  String? get condition {
    final value = draft.text('condition');
    return value.isEmpty ? null : value;
  }

  @override
  void setCondition(String? value) {
    draft.set('condition', value);
    draft.vocabularyEdits.replaceValue(
      fieldId: 'personal:condition',
      listName: GameHardwareVocabularies.condition.id.value,
      value: value,
      mediaKind: 'game_hardware',
    );
  }
}
