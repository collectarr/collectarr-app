import '../vocabulary/game_toy_vocabularies.dart';
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
import 'package:collectarr_app/features/library/config/edit_capability.dart';
import 'package:flutter/material.dart';
import '../domain/game_toy_completeness.dart';
import '../entries/game_toy_entry_details.dart';

abstract interface class GameToyValueBindings {
  GameToyEntryDetails get details;
  int? get valueCents;
  String get currency;
  void setDetails(GameToyEntryDetails details);
  void setValueCents(int? value);
  String? get condition;
  void setCondition(String? value);
}

Map<String, Widget> gameToyValueFields(GameToyValueBindings b) => {
      'condition': LibraryManagedVocabularyField(
        label: 'Condition',
        listName: GameToyVocabularies.condition.id.value,
        mediaKind: 'game_toy',
        value: b.condition,
        onChanged: b.setCondition,
      ),
      'completeness': LibrarySegmentedChoiceField<GameToyCompleteness>(
          label: 'Completeness',
          options: [
            for (final tier in GameToyCompleteness.values) (tier, tier.label)
          ],
          value: b.details.completeness,
          onChanged: (tier) {
            final included = tier == GameToyCompleteness.newSealed;
            b.setDetails(b.details.copyWith(
              completeness: tier,
              hasBox: included,
            ));
          }),
      'box_manual': Wrap(spacing: 18, children: [
        _checkField('Box', b.details.hasBox ?? false,
            (value) => b.setDetails(b.details.copyWith(hasBox: value))),
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
Widget gameToyValueLayout(Map<String, Widget> fields, Widget? history) {
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

/// Loose/New and Box of the reference Toys pre-fill.
List<LibraryPrefillField> gameToyPrefillFields(LibraryEntryEditDraft draft) {
  final fields = gameToyValueFields(_EntryBindings(draft));
  return [
    LibraryPrefillField(
        id: 'game_toy_completeness',
        label: 'Completeness',
        keys: const ['game_toy_completeness', 'game_toy_has_box'],
        field:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          fields['completeness']!,
          const SizedBox(height: 12),
          fields['box_manual']!,
        ])),
    LibraryPrefillField(
        id: 'condition',
        label: 'Condition',
        shownByDefault: false,
        fullWidth: false,
        field: fields['condition']!),
  ];
}

final class GameToyValueTab extends StatelessWidget {
  const GameToyValueTab({super.key, required this.draft});
  final LibraryEntryEditDraft draft;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      // The fields read the draft when built, so a choice must rebuild them.
      animation: draft,
      builder: (context, _) => LibraryEntryPersonalSection(
          draft: draft,
          additionalFields: gameToyValueFields(_EntryBindings(draft)),
          layoutBuilder: gameToyValueLayout));
}

final class _EntryBindings implements GameToyValueBindings {
  const _EntryBindings(this.draft);
  final LibraryEntryEditDraft draft;
  @override
  GameToyEntryDetails get details => GameToyEntryDetails.fromJson(draft.values);
  @override
  int? get valueCents => draft.number('market_value_cents');
  @override
  String get currency => draft.text('currency').isEmpty
      ? AppFormats.current.currency
      : draft.text('currency');
  @override
  void setDetails(GameToyEntryDetails details) {
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
      listName: GameToyVocabularies.condition.id.value,
      value: value,
      mediaKind: 'game_toy',
    );
  }
}
