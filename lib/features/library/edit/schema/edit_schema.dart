import 'dart:async';

import 'package:flutter/widgets.dart';

typedef EditFieldVisibility<TDraft> = bool Function(TDraft draft);
typedef EditFieldValidator<TDraft> = String? Function(TDraft draft);

final class EditSchema<TModel, TDraft> {
  const EditSchema({
    required this.tabs,
    this.title,
    this.isDirty,
    this.validate,
  });

  final List<EditTabSpec<TDraft>> tabs;
  final String Function(TModel model)? title;
  final bool Function(TModel model, TDraft draft)? isDirty;
  final String? Function(TModel model, TDraft draft)? validate;
}

final class EditTabSpec<TDraft> {
  const EditTabSpec({
    required this.id,
    required this.label,
    required this.sections,
    this.icon,
    this.visibleWhen,
  });

  final String id;
  final String label;
  final IconData? icon;
  final List<EditSectionSpec<TDraft>> sections;
  final EditFieldVisibility<TDraft>? visibleWhen;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;
}

final class EditSectionSpec<TDraft> {
  const EditSectionSpec({
    required this.id,
    required this.label,
    required this.fields,
    this.visibleWhen,
  });

  final String id;
  final String label;
  final List<EditFieldSpec<TDraft>> fields;
  final EditFieldVisibility<TDraft>? visibleWhen;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;
}

abstract base class EditFieldSpec<TDraft> {
  const EditFieldSpec({
    required this.id,
    required this.label,
    this.visibleWhen,
    this.validator,
  });

  final String id;
  final String label;
  final EditFieldVisibility<TDraft>? visibleWhen;
  final EditFieldValidator<TDraft>? validator;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;

  String? validate(TDraft draft) => validator?.call(draft);
}

final class TextEditField<TDraft> extends EditFieldSpec<TDraft> {
  const TextEditField({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    super.visibleWhen,
    super.validator,
    this.maxLines = 1,
    this.obscureText = false,
  });

  final String Function(TDraft draft) value;
  final void Function(TDraft draft, String value) setValue;
  final int maxLines;
  final bool obscureText;
}

final class NumberEditField<TDraft> extends EditFieldSpec<TDraft> {
  const NumberEditField({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    super.visibleWhen,
    super.validator,
    this.minimum,
    this.maximum,
    this.decimalPlaces,
  });

  final num? Function(TDraft draft) value;
  final void Function(TDraft draft, num? value) setValue;
  final num? minimum;
  final num? maximum;
  final int? decimalPlaces;
}

final class DateEditField<TDraft> extends EditFieldSpec<TDraft> {
  const DateEditField({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    super.visibleWhen,
    super.validator,
    this.includeTime = false,
  });

  final DateTime? Function(TDraft draft) value;
  final void Function(TDraft draft, DateTime? value) setValue;
  final bool includeTime;
}

final class MoneyEditField<TDraft> extends EditFieldSpec<TDraft> {
  const MoneyEditField({
    required super.id,
    required super.label,
    required this.cents,
    required this.setCents,
    required this.currency,
    super.visibleWhen,
    super.validator,
  });

  final int? Function(TDraft draft) cents;
  final void Function(TDraft draft, int? cents) setCents;
  final String Function(TDraft draft) currency;
}

final class ToggleEditField<TDraft> extends EditFieldSpec<TDraft> {
  const ToggleEditField({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    super.visibleWhen,
    super.validator,
  });

  final bool Function(TDraft draft) value;
  final void Function(TDraft draft, bool value) setValue;
}

final class EditOption<TValue> {
  const EditOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final TValue value;
  final String label;
  final bool enabled;
}

final class SelectEditField<TDraft, TValue> extends EditFieldSpec<TDraft> {
  const SelectEditField({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    required this.options,
    super.visibleWhen,
    super.validator,
  });

  final TValue? Function(TDraft draft) value;
  final void Function(TDraft draft, TValue? value) setValue;
  final List<EditOption<TValue>> options;

  TValue? currentValue(TDraft draft) => value(draft);

  void updateValue(TDraft draft, TValue? nextValue) =>
      setValue(draft, nextValue);
}

final class VocabularyEditField<TDraft, TValue> extends EditFieldSpec<TDraft> {
  const VocabularyEditField({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    required this.options,
    super.visibleWhen,
    super.validator,
  });

  final TValue? Function(TDraft draft) value;
  final void Function(TDraft draft, TValue? value) setValue;
  final List<EditOption<TValue>> options;

  TValue? currentValue(TDraft draft) => value(draft);

  void updateValue(TDraft draft, TValue? nextValue) =>
      setValue(draft, nextValue);
}

final class MultiVocabularyEditField<TDraft, TValue>
    extends EditFieldSpec<TDraft> {
  const MultiVocabularyEditField({
    required super.id,
    required super.label,
    required this.values,
    required this.setValues,
    required this.options,
    super.visibleWhen,
    super.validator,
  });

  final Set<TValue> Function(TDraft draft) values;
  final void Function(TDraft draft, Set<TValue> values) setValues;
  final List<EditOption<TValue>> options;
}

final class ImageEditField<TDraft, TValue> extends EditFieldSpec<TDraft> {
  const ImageEditField({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    this.select,
    super.visibleWhen,
    super.validator,
  });

  final TValue? Function(TDraft draft) value;
  final void Function(TDraft draft, TValue? value) setValue;
  final FutureOr<TValue?> Function(TDraft draft)? select;
}

final class ReadOnlyEditField<TDraft, TValue> extends EditFieldSpec<TDraft> {
  const ReadOnlyEditField({
    required super.id,
    required super.label,
    required this.value,
    required this.display,
    super.visibleWhen,
    super.validator,
  });

  final TValue? Function(TDraft draft) value;
  final String Function(TValue? value) display;
}

final class CustomEditField<TDraft> extends EditFieldSpec<TDraft> {
  const CustomEditField({
    required super.id,
    required super.label,
    required this.builder,
    super.visibleWhen,
    super.validator,
  });

  final Widget Function(BuildContext context, TDraft draft) builder;
}
