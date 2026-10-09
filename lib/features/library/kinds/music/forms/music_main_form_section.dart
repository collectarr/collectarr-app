import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';

/// CLZ Main composition shared by Music Manual Add and Edit.
LibraryFormSectionSpec<TDraft> musicMainFormSection<TDraft>({
  required Iterable<LibraryFieldSpec<TDraft>> fields,
  String titleFieldId = MusicFieldIdentities.titleId,
}) {
  final columns = [
    LibraryFormColumnSpec(rows: [
      [titleFieldId],
      ['sort_title'],
      ['subtitle'],
      [MusicFieldIdentities.artistId],
    ]),
    const LibraryFormColumnSpec(rows: [
      [MusicFieldIdentities.releaseDateId, 'original_release_date'],
      [MusicFieldIdentities.publisherId],
      [MusicFieldIdentities.formatId, MusicFieldIdentities.barcodeId],
      [MusicFieldIdentities.catalogNumberId],
      [MusicFieldIdentities.genreId],
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
