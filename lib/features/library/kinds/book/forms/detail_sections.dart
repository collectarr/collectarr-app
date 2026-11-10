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
  };
  return [
    for (final group in groups.entries)
      LibraryFormSectionSpec<TDraft>(
        id: group.key.toLowerCase().replaceAll(' ', '_'),
        label: group.key,
        columnBreakpoint: 300,
        outlined: true,
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
    LibraryFormSectionSpec<TDraft>(
      id: 'credits_primary',
      label: '',
      layoutColumn: 0,
      maxColumns: 1,
      fields: [
        for (final id in [
          'credit:Editor',
          'credit:Illustrator',
          'credit:Cover Artist',
          'credit:Photographer',
          'credit:Foreword Author',
        ])
          byId[id]!
      ],
    ),
    LibraryFormSectionSpec<TDraft>(
      id: 'credits_secondary',
      label: '',
      layoutColumn: 1,
      maxColumns: 1,
      fields: [byId['translators']!, byId['credit:Ghost Writer']!],
    ),
    LibraryFormSectionSpec<TDraft>(
      id: 'audiobook',
      label: 'Audiobook',
      layoutColumn: 1,
      fullWidthFieldIds: const {'credit:Narrator'},
      fields: [
        byId['credit:Narrator']!,
        byId['audio_length_minutes']!,
        byId['audio_abridged']!
      ],
    ),
  ];
}
