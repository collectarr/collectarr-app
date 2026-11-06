import '../domain/game_packaging_selection.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/entry_personal_section.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import '../domain/game_completeness_selection.dart';
import '../entries/game_entry_details.dart';
import 'market_links.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/field_selection.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/responsive_form_row.dart';
import 'package:collectarr_app/features/library/ui/primitives/segmented_choice_field.dart';
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
  String get currency;

  /// Title and platform searched by the eBay link.
  String get marketQuery;

  void setCompleteness(String? value);
  void setHasBox(bool value);
  void setHasManual(bool value);
  void setValueCents(int? value);
  void setValueLocked(bool value);
  void setCondition(String? value);
  void setPriceChartingId(String? value);
}

/// Game controls of the reference Value tab, laid out with the purchase
/// fields ('price_paid_cents', 'purchase_store', 'purchase_date') that the
/// shared personal section renders.
Map<String, Widget> gameValueFields(GameValueBindings bindings) => {
      'completeness': LibrarySegmentedChoiceField<String>(
        label: 'Completeness',
        options: gameCompletenessOptions,
        value: bindings.completeness ?? 'na',
        onChanged: (tier) =>
            bindings.setCompleteness(tier == 'na' ? null : tier),
      ),
      'box_manual': _GameBoxAndManual(bindings: bindings),
      'market_value_cents': _GameValueField(bindings: bindings),
      'ebay_link': Align(
        alignment: Alignment.centerRight,
        child: GameEbaySoldLink(query: bindings.marketQuery, fontSize: 13),
      ),
      'condition': LibraryManagedVocabularyField(
        label: 'Condition',
        listName: GameVocabularyIds.condition.value,
        mediaKind: 'game',
        value: bindings.condition,
        builtIns: GameVocabularies.condition.builtIns,
        onChanged: bindings.setCondition,
      ),
      'pricecharting_id': LibraryFormField(
        label: 'PriceCharting ID',
        child: LibraryTextFormControl(
          key: const ValueKey('game-pricecharting-id'),
          initialValue: bindings.priceChartingId ?? '',
          onChanged: (value) => bindings
              .setPriceChartingId(value.trim().isEmpty ? null : value.trim()),
        ),
      ),
    };

/// Value layout: the copy and its value in two columns, over the purchase
/// facts.
Widget gameValueLayout(Map<String, Widget> fields, Widget? _) {
  Widget field(String key) => fields[key] ?? const SizedBox.shrink();
  Widget row(List<String> keys) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (index, key) in keys.indexed) ...[
            if (index > 0) const SizedBox(width: 14),
            Expanded(child: field(key)),
          ],
        ]),
      );
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      row(['completeness', 'market_value_cents']),
      row(['box_manual', 'ebay_link']),
      row(['condition', 'pricecharting_id']),
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

/// Completeness and Box/Manual of the reference Games pre-fill.
List<Widget> gamePrefillFields(LibraryEntryEditDraft draft) {
  final fields = gameValueFields(_EntryDraftValueBindings(draft));
  return [fields['completeness']!, fields['box_manual']!];
}

/// Editor Value tab over the entry's personal draft.
final class GameValueTab extends StatelessWidget {
  const GameValueTab({super.key, required this.draft});

  final LibraryEntryEditDraft draft;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        // The fields read the draft when built, so a choice such as the
        // completeness must rebuild them to show the new value.
        animation: draft,
        builder: (context, _) => LibraryEntryPersonalSection(
          draft: draft,
          additionalFields: gameValueFields(_EntryDraftValueBindings(draft)),
          layoutBuilder: gameValueLayout,
        ),
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
  String get currency =>
      _text('currency')?.toUpperCase() ?? AppFormats.current.currency;
  @override
  String get marketQuery {
    final catalog = draft.record.catalogData;
    return [
      catalog['title'],
      if (catalog['platforms'] case [final platform, ...]) platform,
    ].whereType<String>().join(' ');
  }

  @override
  void setCompleteness(String? value) {
    final selection = GameCompletenessSelection(
      current: GameEntryDetails.fromJson(draft.values),
      valueCents: valueCents,
      completeness: value,
    );
    draft.set('game_completeness', selection.details.completeness);
    draft.set('game_has_box', selection.details.hasBox);
    draft.set('game_has_manual', selection.details.hasManual);
    draft.set('market_value_cents', selection.valueCents);
  }

  @override
  void setHasBox(bool value) => _setPackaging(value, hasManual);
  @override
  void setHasManual(bool value) => _setPackaging(hasBox, value);

  void _setPackaging(bool box, bool manual) {
    final selection = GamePackagingSelection(
        current: GameEntryDetails.fromJson(draft.values),
        valueCents: valueCents,
        currency: currency,
        hasBox: box,
        hasManual: manual);
    draft.set('game_has_box', selection.details.hasBox);
    draft.set('game_has_manual', selection.details.hasManual);
    draft.set('market_value_cents', selection.valueCents);
  }

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
  Widget build(BuildContext context) => LibraryLockableMoneyField(
        // Rebuilt when a completeness choice replaces the amount.
        fieldKey: ValueKey('game-value-${bindings.valueCents}'),
        amountMinorUnits: bindings.valueCents,
        currency: bindings.currency,
        locked: bindings.valueLocked,
        lockedMessage: 'Value is locked: completeness does not change it',
        onLockedChanged: bindings.setValueLocked,
        onChanged: bindings.setValueCents,
      );
}
