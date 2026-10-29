import 'package:collectarr_app/features/library/forms/library_form_schema.dart';

const comicMainColumns = [
  LibraryFormColumnSpec(rows: [
    ['comic.series'],
    ['barcode', 'physical_format'],
    ['series_group'],
  ]),
  LibraryFormColumnSpec(rows: [
    ['comic.issue_number', 'comic.variant', 'variant_description'],
    ['cover_date', 'release_date'],
    ['publisher', 'comic.imprint'],
  ], fieldFlex: {
    'comic.issue_number': 2,
    'comic.variant': 1,
    'variant_description': 4
  }),
];

List<LibraryFormColumnSpec> comicDetailsColumns(String titleField) => [
      LibraryFormColumnSpec(rows: [
        ['crossover'],
        ['story_arcs'],
        [titleField],
        ['subtitle'],
        ['edition_title', 'isbn', 'upc'],
      ]),
      const LibraryFormColumnSpec(rows: [
        ['country', 'language'],
        ['publication_age', 'comic.page_count'],
        ['genres'],
        ['age_rating'],
      ]),
    ];
