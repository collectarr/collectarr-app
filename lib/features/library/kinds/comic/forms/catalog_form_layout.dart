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

/// One-column reading order for the native editor, with the reference's
/// rows, so no label is cut off. The same field specs and draft are used by
/// desktop and mobile; only the arrangement changes.
const comicMobileMainColumns = [
  LibraryFormColumnSpec(
    rows: [
      ['comic.series'],
      ['comic.issue_number', 'comic.variant'],
      ['variant_description'],
      ['cover_date', 'release_date'],
      ['barcode'],
      ['physical_format', 'comic.page_count'],
      ['crossover'],
      ['story_arcs'],
      ['title'],
      ['subtitle'],
      ['publisher', 'comic.imprint'],
      ['series_group', 'publication_age'],
      ['country', 'language'],
      ['genres'],
      ['comic.plot'],
    ],
    fieldFlex: {
      'physical_format': 2,
      'comic.page_count': 1,
    },
  ),
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
