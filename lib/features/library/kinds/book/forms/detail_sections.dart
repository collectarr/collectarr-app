import 'package:collectarr_app/features/library/forms/schema.dart';

List<LibraryFormSectionSpec<TDraft>> bookDetailsFormSections<TDraft>(
  Iterable<LibraryFieldSpec<TDraft>> fields,
) {
  final byId = {for (final field in fields) field.id: field};
  const groups = {
    'Edition': [
      'edition_statement',
      'printed_by',
      'paper_type',
      'printing_number',
      'first_edition',
      'extras',
      'number_line'
    ],
    'Dimensions': [
      'width_mm',
      'height_mm',
      'spine_thickness_mm',
      'weight_grams'
    ],
    'Classification': ['lc_control_number', 'lc_classification', 'dewey'],
    'Original': [
      'original_title',
      'original_subtitle',
      'original_country',
      'original_language',
      'original_publisher',
      'original_publication_date',
      'original_publication_place'
    ],
    'Additional metadata': [
      'title',
      'binding',
      'dimensions',
      'localized_title',
      'variant',
      'series_group',
      'volume_number',
      'imprint',
      'distributor',
      'first_publication_date',
      'search_aliases',
      'characters',
      'age_rating',
      'region',
      'release_status',
      'publication_year',
      'barcode'
    ],
  };
  return [
    for (final group in groups.entries)
      LibraryFormSectionSpec<TDraft>(
        id: group.key.toLowerCase().replaceAll(' ', '_'),
        label: group.key,
        layoutColumn: switch (group.key) {
          'Edition' || 'Dimensions' => 0,
          'Classification' || 'Original' => 1,
          _ => null,
        },
        fullWidthFieldIds: switch (group.key) {
          'Classification' => const {'dewey'},
          'Original' => const {
              'original_title',
              'original_subtitle',
              'original_publication_place'
            },
          _ => const {},
        },
        columns: group.key == 'Edition'
            ? const [
                LibraryFormColumnSpec(rows: [
                  ['edition_statement'],
                  ['paper_type'],
                  ['extras']
                ]),
                LibraryFormColumnSpec(rows: [
                  ['printed_by'],
                  ['printing_number', 'first_edition'],
                  ['number_line']
                ]),
              ]
            : const [],
        fields: [for (final id in group.value) byId[id]!],
      )
  ];
}

List<LibraryFormSectionSpec<TDraft>> bookCreditFormSections<TDraft>(
  Iterable<LibraryFieldSpec<TDraft>> fields,
) {
  final byId = {for (final field in fields) field.id: field};
  return [
    LibraryFormSectionSpec<TDraft>(id: 'credits', label: '', fields: [
      for (final id in [
        'credit:Editor',
        'credit:Illustrator',
        'credit:Cover Artist',
        'credit:Photographer',
        'credit:Foreword Author',
        'translators',
        'credit:Ghost Writer'
      ])
        byId[id]!,
    ]),
    LibraryFormSectionSpec<TDraft>(
        id: 'audiobook',
        label: 'Audiobook',
        fields: [
          byId['credit:Narrator']!,
          byId['audio_length_minutes']!,
          byId['audio_abridged']!,
        ]),
  ];
}
