import 'package:collectarr_app/features/library/forms/schema.dart';
import '../config/field_identities.dart';

LibraryFormSectionSpec<TDraft> bookMainFormSection<TDraft>({
  required Iterable<LibraryFieldSpec<TDraft>> fields,
}) {
  const columns = [
    LibraryFormColumnSpec(rows: [
      ['catalog_title'],
      ['sort_title'],
      [BookFieldIdentities.subtitleId],
      [BookFieldIdentities.seriesId],
      ['number', 'volume_name'],
      ['box_set'],
      ['authors'],
    ]),
    LibraryFormColumnSpec(rows: [
      [BookFieldIdentities.isbnId, BookFieldIdentities.pageCountId],
      [BookFieldIdentities.publisherId, 'country'],
      [BookFieldIdentities.formatId, BookFieldIdentities.releaseDateId],
      ['language', 'publication_place'],
      ['genres'],
      ['subjects'],
    ]),
  ];
  final byId = {for (final field in fields) field.id: field};
  return LibraryFormSectionSpec<TDraft>(
    id: 'catalog_item',
    label: '',
    columns: columns,
    fields: [
      for (final column in columns)
        for (final row in column.rows)
          for (final id in row) byId[id]!
    ],
  );
}
