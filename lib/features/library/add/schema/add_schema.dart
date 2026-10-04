import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';

export 'package:collectarr_app/features/library/schema/library_field_spec.dart';

LibraryTextFieldSpec<TDraft>
    libraryAddCatalogTitleField<TDraft extends LibraryKindAddDraft>() =>
        LibraryTextFieldSpec<TDraft>(
          id: 'catalog_title',
          label: 'Title',
          value: (draft) => draft.catalogTitle,
          setValue: (draft, value) => draft.catalogTitle = value,
          validator: (draft) =>
              draft.catalogTitle.trim().isEmpty ? 'Enter a title' : null,
        );

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

List<AddSectionSpec<TDraft>> filterAddSchemaSections<TDraft>({
  required List<AddSectionSpec<TDraft>> sections,
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
        AddSectionSpec<TDraft>(
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
