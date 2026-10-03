/// Structural schema-v1 columns entry by the generic Collection host.
///
/// Rich catalog and Entry columns are deliberately absent. A homogeneous
/// export uses the selected kind's CSV profile; mixed exports use this
/// structural projection and preserve the complete catalog target as JSON.
abstract final class CollectionCsvV1Schema {
  static const header = <String>[
    'catalog_item_ref',
    'kind',
    'title',
    'status',
    'location_id',
    'notes',
    'quantity',
    'library_entry_json',
  ];

  static const clzFriendlyHeader = <String>[
    'Catalog Item Ref',
    'Media Type',
    'Title',
    'Collection Status',
    'Location ID',
    'Notes',
  ];
}
