import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_field_specs.dart';

/// Reference Main composition shared by Game Manual Add and Edit.
LibraryFormSectionSpec<TDraft> gameMainFormSection<TDraft>({
  required Iterable<LibraryFieldSpec<TDraft>> fields,
  String titleFieldId = GameMainFieldIds.title,
}) {
  final columns = [
    LibraryFormColumnSpec(rows: [
      [titleFieldId],
      [GameMainFieldIds.sortTitle],
      [GameMainFieldIds.platform, GameMainFieldIds.releaseDate],
      [GameMainFieldIds.developer],
      [GameMainFieldIds.publisher],
    ]),
    const LibraryFormColumnSpec(rows: [
      [GameMainFieldIds.series],
      [GameMainFieldIds.barcode, GameMainFieldIds.format],
      [GameMainFieldIds.edition, GameMainFieldIds.region],
      [GameMainFieldIds.audienceRating],
      [GameMainFieldIds.genre],
    ], fieldFlex: {
      // The reference gives Edition 331 px and Region 233 px.
      GameMainFieldIds.edition: 10,
      GameMainFieldIds.region: 7,
    }),
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
