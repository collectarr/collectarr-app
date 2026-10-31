import 'package:collectarr_app/features/library/forms/schema.dart';

// The reference's Main tab: a 479 px column beside a 677 px one, with
// Issue No., Variant and Variant Description at 159, 101 and 389 px.
const comicMainColumns = [
  LibraryFormColumnSpec(flex: 479, rows: [
    ['comic.series'],
    ['barcode', 'physical_format'],
    ['series_group'],
  ]),
  LibraryFormColumnSpec(flex: 677, rows: [
    ['comic.issue_number', 'comic.variant', 'variant_description'],
    ['cover_date', 'release_date'],
    ['publisher', 'comic.imprint'],
  ], fieldFlex: {
    'comic.issue_number': 159,
    'comic.variant': 101,
    'variant_description': 389
  }),
];

List<LibraryFormColumnSpec> comicDetailsColumns(String titleField) => [
      LibraryFormColumnSpec(rows: [
        ['crossover'],
        [titleField],
        ['country'],
        ['publication_age', 'comic.page_count'],
      ]),
      const LibraryFormColumnSpec(rows: [
        ['story_arcs'],
        ['subtitle'],
        ['language'],
        ['genres'],
      ]),
    ];
