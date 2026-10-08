import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:flutter/widgets.dart';

export 'package:collectarr_app/features/library/forms/library_form_schema.dart';

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
    this.svgAsset,
    this.visibleWhen,
  });

  final String id;
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final List<LibraryFormSectionSpec<TDraft>> sections;
  final LibraryFieldVisibility<TDraft>? visibleWhen;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;
}
