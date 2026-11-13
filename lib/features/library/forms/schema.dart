import 'package:collectarr_app/features/library/forms/field_spec.dart';

export 'package:collectarr_app/features/library/forms/field_spec.dart';

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
    this.columns = const <LibraryFormColumnSpec>[],
    this.wideColumns = const <LibraryFormColumnSpec>[],
    this.visibleWhen,
    this.layoutColumn,
    this.columnBreakpoint = 680,
    this.outlined = false,
  }) : assert(layoutColumn == null || layoutColumn == 0 || layoutColumn == 1);

  final String id;
  final String label;
  final List<LibraryFieldSpec<TDraft>> fields;
  final int maxColumns;
  final Set<String> fullWidthFieldIds;
  final Map<String, int> fieldColumnSpans;
  final Set<String> rightAlignedFieldIds;

  /// Replaces [columns] from 600 dp wide, when not empty.
  final List<LibraryFormColumnSpec> wideColumns;

  /// Independently stacked columns; each row contains one or more field IDs.
  /// Empty means the section uses the regular responsive field grid.
  final List<LibraryFormColumnSpec> columns;

  /// Optional column for consecutive sections in a responsive two-column group.
  final int? layoutColumn;
  final double columnBreakpoint;
  final bool outlined;
  final LibraryFieldVisibility<TDraft>? visibleWhen;

  bool isVisible(TDraft draft) => visibleWhen?.call(draft) ?? true;
}

final class LibraryFormColumnSpec {
  const LibraryFormColumnSpec({
    required this.rows,
    this.fieldFlex = const {},
    this.flex = 1,
    this.rowBreakpoint = 300,
  });

  final List<List<String>> rows;

  /// Relative width of this column beside the others.
  final int flex;

  /// Relative widths of fields that share a row; unlisted fields weigh 1.
  final Map<String, int> fieldFlex;

  /// Width below which fields that share a row stack instead.
  final double rowBreakpoint;
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
          columns: [
            for (final column in section.columns)
              if (column.rows.any((row) => row.any(
                    (id) => fieldIds == null || fieldIds.contains(id),
                  )))
                LibraryFormColumnSpec(
                    fieldFlex: column.fieldFlex,
                    rowBreakpoint: column.rowBreakpoint,
                    rows: [
                      for (final row in column.rows)
                        if (row.any(
                            (id) => fieldIds == null || fieldIds.contains(id)))
                          [
                            for (final id in row)
                              if (fieldIds == null || fieldIds.contains(id)) id,
                          ],
                    ]),
          ],
          layoutColumn: section.layoutColumn,
          columnBreakpoint: section.columnBreakpoint,
          outlined: section.outlined,
          visibleWhen: section.visibleWhen,
        ),
  ];
}
