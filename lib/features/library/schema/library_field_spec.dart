import 'dart:async';

import 'package:flutter/widgets.dart';

typedef LibraryFieldVisibility<TDraft> = bool Function(TDraft draft);
typedef LibraryFieldValidator<TDraft> = String? Function(TDraft draft);

abstract interface class LibraryFieldSpecVisitor<TDraft, TResult> {
  TResult visitText(LibraryTextFieldSpec<TDraft> field);
  TResult visitNumber(LibraryNumberFieldSpec<TDraft> field);
  TResult visitDate(LibraryDateFieldSpec<TDraft> field);
  TResult visitMoney(LibraryMoneyFieldSpec<TDraft> field);
  TResult visitToggle(LibraryToggleFieldSpec<TDraft> field);
  TResult visitSelect<TValue>(LibrarySelectFieldSpec<TDraft, TValue> field);
  TResult visitVocabulary<TValue>(
    LibraryVocabularyFieldSpec<TDraft, TValue> field,
  );
  TResult visitMultiVocabulary<TValue>(
    LibraryMultiVocabularyFieldSpec<TDraft, TValue> field,
  );
  TResult visitImage<TValue>(LibraryImageFieldSpec<TDraft, TValue> field);
  TResult visitReadOnly<TValue>(LibraryReadOnlyFieldSpec<TDraft, TValue> field);
  TResult visitCustom(LibraryCustomFieldSpec<TDraft> field);
}

sealed class LibraryFieldSpec<TDraft> {
  const LibraryFieldSpec({
    required this.id,
    required this.label,
    this.visibleWhen,
    this.validator,
  });

  final String id;
  final String label;
  final LibraryFieldVisibility<TDraft>? visibleWhen;
  final LibraryFieldValidator<TDraft>? validator;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;

  String? validate(TDraft draft) => validator?.call(draft);

  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor);
}

final class LibraryFieldOption<TValue> {
  const LibraryFieldOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final TValue value;
  final String label;
  final bool enabled;
}

final class LibraryTextFieldSpec<TDraft> extends LibraryFieldSpec<TDraft> {
  const LibraryTextFieldSpec({
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

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitText(this);
}

final class LibraryNumberFieldSpec<TDraft> extends LibraryFieldSpec<TDraft> {
  const LibraryNumberFieldSpec({
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

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitNumber(this);
}

final class LibraryDateFieldSpec<TDraft> extends LibraryFieldSpec<TDraft> {
  const LibraryDateFieldSpec({
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

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitDate(this);
}

final class LibraryMoneyFieldSpec<TDraft> extends LibraryFieldSpec<TDraft> {
  const LibraryMoneyFieldSpec({
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

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitMoney(this);
}

final class LibraryToggleFieldSpec<TDraft> extends LibraryFieldSpec<TDraft> {
  const LibraryToggleFieldSpec({
    required super.id,
    required super.label,
    required this.value,
    required this.setValue,
    super.visibleWhen,
    super.validator,
  });

  final bool Function(TDraft draft) value;
  final void Function(TDraft draft, bool value) setValue;

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitToggle(this);
}

sealed class LibrarySingleValueField<TDraft, TValue>
    extends LibraryFieldSpec<TDraft> {
  const LibrarySingleValueField({
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
  final List<LibraryFieldOption<TValue>> options;

  TValue? currentValue(TDraft draft) => value(draft);

  void updateValue(TDraft draft, TValue? nextValue) =>
      setValue(draft, nextValue);
}

final class LibrarySelectFieldSpec<TDraft, TValue>
    extends LibrarySingleValueField<TDraft, TValue> {
  const LibrarySelectFieldSpec({
    required super.id,
    required super.label,
    required super.value,
    required super.setValue,
    required super.options,
    super.visibleWhen,
    super.validator,
  });

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitSelect(this);
}

final class LibraryVocabularyFieldSpec<TDraft, TValue>
    extends LibrarySingleValueField<TDraft, TValue> {
  const LibraryVocabularyFieldSpec({
    required super.id,
    required super.label,
    required super.value,
    required super.setValue,
    required super.options,
    this.onManage,
    this.pickListKey,
    super.visibleWhen,
    super.validator,
  });

  final FutureOr<void> Function(TDraft draft)? onManage;
  final String? pickListKey;

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitVocabulary(this);
}

final class LibraryMultiVocabularyFieldSpec<TDraft, TValue>
    extends LibraryFieldSpec<TDraft> {
  const LibraryMultiVocabularyFieldSpec({
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
  final List<LibraryFieldOption<TValue>> options;

  Set<TValue> currentValues(TDraft draft) => values(draft);

  void updateValues(TDraft draft, Set<TValue> nextValues) =>
      setValues(draft, nextValues);

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitMultiVocabulary(this);
}

final class LibraryImageFieldSpec<TDraft, TValue>
    extends LibraryFieldSpec<TDraft> {
  const LibraryImageFieldSpec({
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

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitImage(this);
}

final class LibraryReadOnlyFieldSpec<TDraft, TValue>
    extends LibraryFieldSpec<TDraft> {
  const LibraryReadOnlyFieldSpec({
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

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitReadOnly(this);
}

final class LibraryCustomFieldSpec<TDraft> extends LibraryFieldSpec<TDraft> {
  const LibraryCustomFieldSpec({
    required super.id,
    required super.label,
    required this.builder,
    super.visibleWhen,
    super.validator,
  });

  final Widget Function(BuildContext context, TDraft draft) builder;

  @override
  TResult accept<TResult>(LibraryFieldSpecVisitor<TDraft, TResult> visitor) =>
      visitor.visitCustom(this);
}
