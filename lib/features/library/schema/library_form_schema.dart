import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

export 'package:collectarr_app/features/library/schema/library_field_spec.dart';

/// Kind-owned field structure shared by local Add and Edit forms.
final class LibraryFormSchema<TDraft> {
  const LibraryFormSchema({
    required this.sections,
    this.title,
    this.validate,
  });

  final List<LibraryFormSectionSpec<TDraft>> sections;
  final String? Function(TDraft draft)? title;
  final String? Function(TDraft draft)? validate;
}

/// A responsive group of fields in a kind-owned form.
final class LibraryFormSectionSpec<TDraft> {
  const LibraryFormSectionSpec({
    required this.id,
    required this.label,
    required this.fields,
    this.maxColumns = 2,
    this.fullWidthFieldIds = const <String>{},
    this.fieldColumnSpans = const <String, int>{},
    this.rightAlignedFieldIds = const <String>{},
    this.visibleWhen,
  });

  final String id;
  final String label;
  final List<LibraryFieldSpec<TDraft>> fields;
  final int maxColumns;
  final Set<String> fullWidthFieldIds;
  final Map<String, int> fieldColumnSpans;
  final Set<String> rightAlignedFieldIds;
  final LibraryFieldVisibility<TDraft>? visibleWhen;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;
}

List<LibraryFormSectionSpec<TDraft>> filterLibraryFormSections<TDraft>({
  required List<LibraryFormSectionSpec<TDraft>> sections,
  Set<String>? fieldIds,
  Map<String, String> sectionLabels = const {},
  String? sectionLabel,
}) {
  if (fieldIds == null && sectionLabels.isEmpty && sectionLabel == null) {
    return sections;
  }

  return [
    for (final section in sections)
      if (section.fields
          .where((field) => fieldIds == null || fieldIds.contains(field.id))
          .isNotEmpty)
        LibraryFormSectionSpec<TDraft>(
          id: section.id,
          label: sectionLabels[section.id] ?? sectionLabel ?? section.label,
          fields: [
            for (final field in section.fields)
              if (fieldIds == null || fieldIds.contains(field.id)) field,
          ],
          maxColumns: section.maxColumns,
          fullWidthFieldIds: section.fullWidthFieldIds,
          fieldColumnSpans: section.fieldColumnSpans,
          rightAlignedFieldIds: section.rightAlignedFieldIds,
          visibleWhen: section.visibleWhen,
        ),
  ];
}
