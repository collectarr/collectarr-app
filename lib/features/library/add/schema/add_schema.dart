import 'dart:async';

import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:flutter/widgets.dart';

typedef AddFieldVisibility<TDraft> = bool Function(TDraft draft);
typedef AddFieldValidator<TDraft> = String? Function(TDraft draft);

final class AddSchema<TDraft> {
  const AddSchema({
    required this.sections,
    this.title,
    this.validate,
  });

  final List<AddSectionSpec<TDraft>> sections;
  final String? Function(TDraft draft)? title;
  final String? Function(TDraft draft)? validate;
}

final class AddSectionSpec<TDraft> {
  const AddSectionSpec({
    required this.id,
    required this.label,
    required this.fields,
    this.visibleWhen,
  });

  final String id;
  final String label;
  final List<AddFieldSpec<TDraft>> fields;
  final AddFieldVisibility<TDraft>? visibleWhen;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;
}

abstract base class AddFieldSpec<TDraft> {
  const AddFieldSpec({
    required this.id,
    required this.label,
    this.visibleWhen,
    this.validator,
  });

  final String id;
  final String label;
  final AddFieldVisibility<TDraft>? visibleWhen;
  final AddFieldValidator<TDraft>? validator;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;

  String? validate(TDraft draft) => validator?.call(draft);
}

final class TextAddField<TDraft> extends AddFieldSpec<TDraft> {
  const TextAddField({
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

final class NumberAddField<TDraft> extends AddFieldSpec<TDraft> {
  const NumberAddField({
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

final class DateAddField<TDraft> extends AddFieldSpec<TDraft> {
  const DateAddField({
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

final class MoneyAddField<TDraft> extends AddFieldSpec<TDraft> {
  const MoneyAddField({
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

final class ToggleAddField<TDraft> extends AddFieldSpec<TDraft> {
  const ToggleAddField({
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

final class SelectAddField<TDraft, TValue> extends AddFieldSpec<TDraft> {
  const SelectAddField({
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

final class VocabularyAddField<TDraft, TValue> extends AddFieldSpec<TDraft> {
  const VocabularyAddField({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    required this.options,
    this.onManage,
    super.visibleWhen,
    super.validator,
  });

  final TValue? Function(TDraft draft) value;
  final void Function(TDraft draft, TValue? value) setValue;
  final List<EditOption<TValue>> options;
  final FutureOr<void> Function(TDraft draft)? onManage;

  TValue? currentValue(TDraft draft) => value(draft);

  void updateValue(TDraft draft, TValue? nextValue) =>
      setValue(draft, nextValue);
}

final class MultiVocabularyAddField<TDraft, TValue>
    extends AddFieldSpec<TDraft> {
  const MultiVocabularyAddField({
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

  Set<TValue> currentValues(TDraft draft) => values(draft);

  void updateValues(TDraft draft, Set<TValue> nextValues) =>
      setValues(draft, nextValues);
}

final class ImageAddField<TDraft, TValue> extends AddFieldSpec<TDraft> {
  const ImageAddField({
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

  TValue? currentValue(TDraft draft) => value(draft);

  void updateValue(TDraft draft, TValue? nextValue) =>
      setValue(draft, nextValue);
}

final class ReadOnlyAddField<TDraft, TValue> extends AddFieldSpec<TDraft> {
  const ReadOnlyAddField({
    required super.id,
    required super.label,
    required this.value,
    required this.display,
    super.visibleWhen,
    super.validator,
  });

  final TValue? Function(TDraft draft) value;
  final String Function(TValue? value) display;

  String displayValue(TDraft draft) => display(value(draft));
}

final class CustomAddField<TDraft> extends AddFieldSpec<TDraft> {
  const CustomAddField({
    required super.id,
    required super.label,
    required this.builder,
    super.visibleWhen,
    super.validator,
  });

  final Widget Function(BuildContext context, TDraft draft) builder;
}
