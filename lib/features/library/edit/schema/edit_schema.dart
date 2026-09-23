import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:flutter/widgets.dart';

export 'package:collectarr_app/features/library/schema/library_field_spec.dart';

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
  final LibraryFieldVisibility<TDraft>? visibleWhen;

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
  final List<LibraryFieldSpec<TDraft>> fields;
  final LibraryFieldVisibility<TDraft>? visibleWhen;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;
}
