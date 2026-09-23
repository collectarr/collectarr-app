import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

export 'package:collectarr_app/features/library/schema/library_field_spec.dart';

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
  final List<LibraryFieldSpec<TDraft>> fields;
  final LibraryFieldVisibility<TDraft>? visibleWhen;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;
}
