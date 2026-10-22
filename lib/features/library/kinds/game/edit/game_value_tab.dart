import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/library_entry_personal_section.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_segmented_choice_field.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Value-tab state of one Game copy, from the editor or from Manual Add.
abstract interface class GameValueBindings {
  String? get completeness;
  bool get hasBox;
  bool get hasManual;
  int? get valueCents;
  bool get valueLocked;
  String? get condition;
  String? get priceChartingId;
  String? get coreRegion;
  GameValuationSet? get valuations;
  String get currency;

  void setCompleteness(String? value);
  void setHasBox(bool value);
  void setHasManual(bool value);
  void setValueCents(int? value);
  void setValueLocked(bool value);
  void setCondition(String? value);
  void setPriceChartingId(String? value);
  void setCoreRegion(String value);
}

/// Game controls of the reference Value tab, laid out with the purchase
/// fields ('price_paid_cents', 'purchase_store', 'purchase_date') that the
/// shared personal section renders.
Map<String, Widget> gameValueFields(GameValueBindings bindings) => {
      'completeness': LibrarySegmentedChoiceField<String>(
        label: 'Completeness',
        options: gameCompletenessOptions,
        value: bindings.completeness ?? 'na',
        onChanged: (tier) {
          bindings.setCompleteness(tier == 'na' ? null : tier);
          final amount = bindings.valuations?.amountForCompleteness(tier);
          // Choosing a tier takes its PriceCharting value unless locked.
          if (!bindings.valueLocked && amount != null) {
            bindings.setValueCents(amount);
          }
        },
      ),
      'box_manual': _GameBoxAndManual(bindings: bindings),
      'market_value_cents': _GameValueField(bindings: bindings),
      'condition': LibraryManagedVocabularyField(
        label: 'Condition',
        listName: GameVocabularyIds.condition.value,
        mediaKind: 'game',
        value: bindings.condition,
        builtIns: GameVocabularies.condition.builtIns,
        onChanged: bindings.setCondition,
      ),
      'valuations': _GameValuationChart(
          valuations: bindings.valuations, currency: bindings.currency),
      'pricecharting_id': LibraryFormField(
        label: 'PriceCharting ID',
        child: LibraryTextFormControl(
          key: const ValueKey('game-pricecharting-id'),
          initialValue: bindings.priceChartingId ?? '',
          onChanged: (value) => bindings
              .setPriceChartingId(value.trim().isEmpty ? null : value.trim()),
        ),
      ),
      'core_region': LibrarySegmentedChoiceField<String>(
        label: 'Core Region',
        options: const [('US', 'US'), ('EU', 'EU')],
        value: bindings.coreRegion ?? 'US',
        onChanged: bindings.setCoreRegion,
      ),
    };

/// Reference Value layout: completeness, value, purchase facts on the left;
/// PriceCharting values on the right.
Widget gameValueLayout(Map<String, Widget> fields, Widget? _) {
  Widget field(String key) => fields[key] ?? const SizedBox.shrink();
  Widget row(List<(String, int)> keys) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (index, (key, flex)) in keys.indexed) ...[
            if (index > 0) const SizedBox(width: 14),
            Expanded(flex: flex, child: field(key)),
          ],
        ]),
      );
  final left =
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    row([('completeness', 9), ('market_value_cents', 4)]),
    row([('box_manual', 1)]),
    row([('condition', 1), ('', 1)]),
    row([('price_paid_cents', 1), ('purchase_store', 1)]),
    row([('purchase_date', 1), ('', 1)]),
  ]);
  final right =
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    field('valuations'),
    const SizedBox(height: 12),
    row([('pricecharting_id', 1), ('core_region', 1)]),
  ]);
  return LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 900
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 69, child: left),
            const SizedBox(width: 14),
            Expanded(flex: 48, child: right),
          ])
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, right],
          ),
  );
}

/// Editor Value tab over the entry's personal draft.
final class GameValueTab extends StatelessWidget {
  const GameValueTab({super.key, required this.draft});

  final LibraryEntryEditDraft draft;

  @override
  Widget build(BuildContext context) => LibraryEntryPersonalSection(
        draft: draft,
        additionalFields: gameValueFields(_EntryDraftValueBindings(draft)),
        layoutBuilder: gameValueLayout,
      );
}

final class _EntryDraftValueBindings implements GameValueBindings {
  const _EntryDraftValueBindings(this.draft);

  final LibraryEntryEditDraft draft;

  String? _text(String key) =>
      draft.text(key).trim().isEmpty ? null : draft.text(key).trim();

  @override
  String? get completeness => _text('game_completeness');
  @override
  bool get hasBox => draft.values['game_has_box'] == true;
  @override
  bool get hasManual => draft.values['game_has_manual'] == true;
  @override
  int? get valueCents => draft.number('market_value_cents');
  @override
  bool get valueLocked => draft.values['game_value_is_locked'] == true;
  @override
  String? get condition => _text('condition');
  @override
  String? get priceChartingId => _text('game_pricecharting_id');
  @override
  String? get coreRegion => _text('game_core_region');
  @override
  GameValuationSet? get valuations => switch (draft.values['game_valuations']) {
        Map<dynamic, dynamic> value =>
          GameValuationSet.fromJson(Map<String, dynamic>.from(value)),
        _ => null,
      };
  @override
  String get currency =>
      _text('currency')?.toUpperCase() ?? AppFormats.current.currency;

  @override
  void setCompleteness(String? value) => draft.set('game_completeness', value);
  @override
  void setHasBox(bool value) => draft.set('game_has_box', value);
  @override
  void setHasManual(bool value) => draft.set('game_has_manual', value);
  @override
  void setValueCents(int? value) => draft.set('market_value_cents', value);
  @override
  void setValueLocked(bool value) => draft.set('game_value_is_locked', value);
  @override
  void setCondition(String? value) {
    draft.set('condition', value);
    draft.vocabularyEdits.replaceValue(
      fieldId: 'personal:condition',
      listName: GameVocabularyIds.condition.value,
      value: value,
      mediaKind: 'game',
    );
  }

  @override
  void setPriceChartingId(String? value) =>
      draft.set('game_pricecharting_id', value);
  @override
  void setCoreRegion(String value) => draft.set('game_core_region', value);
}

final class _GameBoxAndManual extends StatelessWidget {
  const _GameBoxAndManual({required this.bindings});

  final GameValueBindings bindings;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 24,
        child: Row(children: [
          _check(context, 'Box', bindings.hasBox, bindings.setHasBox),
          const SizedBox(width: 18),
          _check(context, 'Manual', bindings.hasManual, bindings.setHasManual),
        ]),
      );

  Widget _check(BuildContext context, String label, bool checked,
          ValueChanged<bool> onChanged) =>
      Semantics(
        checked: checked,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!checked),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              LibraryFieldCheckbox(
                state: checked
                    ? LibraryFieldCheckState.all
                    : LibraryFieldCheckState.none,
              ),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 14, color: appPalette(context).textPrimary)),
            ]),
          ),
        ),
      );
}

final class _GameValueField extends StatelessWidget {
  const _GameValueField({required this.bindings});

  final GameValueBindings bindings;

  @override
  Widget build(BuildContext context) {
    final locked = bindings.valueLocked;
    return Stack(children: [
      LibraryMoneyAmountField(
        // Rebuilt when a completeness choice replaces the amount.
        fieldKey: ValueKey('game-value-${bindings.valueCents}'),
        label: 'Value',
        amountMinorUnits: bindings.valueCents,
        currency: bindings.currency,
        onChanged: bindings.setValueCents,
      ),
      Positioned(
        right: 0,
        top: 2,
        child: Tooltip(
          message: locked
              ? 'Value is locked: completeness does not change it'
              : 'Lock the value',
          child: GestureDetector(
            onTap: () => bindings.setValueLocked(!locked),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Icon(
                locked ? AppIcons.lock : AppIcons.lockOpen,
                size: 14,
                color: appPalette(context).textMuted,
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// Bar chart of the recorded PriceCharting tiers.
final class _GameValuationChart extends StatelessWidget {
  const _GameValuationChart({required this.valuations, required this.currency});

  final GameValuationSet? valuations;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final bars = valuations?.chartTiers ?? const <(String, int)>[];
    final maximum =
        bars.fold<int>(0, (max, bar) => bar.$2 > max ? bar.$2 : max);
    return Container(
      height: 310,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: [
        Text('Values from PriceCharting',
            style: TextStyle(
                fontSize: 13,
                fontWeight: kAppBoldFontWeight,
                color: palette.textPrimary)),
        const SizedBox(height: 10),
        Expanded(
          child: bars.isEmpty
              ? Center(
                  child: Text('No PriceCharting values recorded',
                      style: TextStyle(color: palette.textMuted)))
              : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (final (label, cents) in bars)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                  AppFormats.current
                                      .formatMoney(cents, currency),
                                  style: TextStyle(
                                      fontSize: 11, color: palette.textMuted)),
                              const SizedBox(height: 2),
                              Container(
                                height:
                                    maximum == 0 ? 0 : 190 * cents / maximum,
                                color: const Color(0xFF8ED3EA),
                              ),
                              const SizedBox(height: 4),
                              Text(label,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: palette.textPrimary)),
                            ]),
                      ),
                    ),
                ]),
        ),
      ]),
    );
  }
}
