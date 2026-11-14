import 'package:collectarr_app/features/library/forms/schema.dart';
import '../config/field_identities.dart';

LibraryFormSectionSpec<TDraft> bookMainFormSection<TDraft>({
  required Iterable<LibraryFieldSpec<TDraft>> fields,
}) {
  const columns = [
    LibraryFormColumnSpec(fieldFlex: {
      BookFieldIdentities.seriesId: 2,
      'box_set': 15,
      'box_set_edit': 1
    }, rows: [
      ['catalog_title'],
      ['sort_title'],
      [BookFieldIdentities.subtitleId],
      [BookFieldIdentities.seriesId, 'number', 'volume_name'],
      ['box_set', 'box_set_edit'],
    ]),
    LibraryFormColumnSpec(fieldFlex: {
      BookFieldIdentities.isbnId: 183,
      BookFieldIdentities.pageCountId: 85,
      BookFieldIdentities.formatId: 282
    }, rows: [
      ['authors'],
      [
        BookFieldIdentities.isbnId,
        BookFieldIdentities.pageCountId,
        BookFieldIdentities.formatId
      ],
      [BookFieldIdentities.publisherId, BookFieldIdentities.releaseDateId],
      ['country', 'language'],
      ['publication_place'],
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
