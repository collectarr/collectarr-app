import 'package:collectarr_app/features/library/forms/library_form_schema.dart';

/// CLZ Main composition shared by Music Manual Add and Edit.
LibraryFormSectionSpec<TDraft> musicMainFormSection<TDraft>({
  required Iterable<LibraryFieldSpec<TDraft>> fields,
  String titleFieldId = 'title',
}) {
  final columns = [
    LibraryFormColumnSpec(rows: [
      [titleFieldId],
      ['sort_title'],
      ['subtitle'],
      ['artist'],
    ]),
    const LibraryFormColumnSpec(rows: [
      ['release_date', 'original_release_date'],
      ['record_label', 'recording_date'],
      ['format', 'barcode'],
      ['catalog_number'],
      ['genres'],
    ]),
  ];
  final fieldsById = {for (final field in fields) field.id: field};
  return LibraryFormSectionSpec<TDraft>(
    id: 'catalog_item',
    label: '',
    columns: columns,
    fields: [
      for (final column in columns)
        for (final row in column.rows)
          for (final id in row) fieldsById[id]!,
    ],
  );
}
