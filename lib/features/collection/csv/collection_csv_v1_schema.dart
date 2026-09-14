/// Structural schema-v1 columns owned by the generic Collection host.
///
/// Rich catalog and Owned columns are deliberately absent. A homogeneous
/// export uses the selected kind's CSV profile; mixed exports use this
/// structural projection and preserve the complete catalog target as JSON.
abstract final class CollectionCsvV1Schema {
  static const header = <String>[
    'catalog_ref',
    'kind',
    'title',
    'status',
    'quantity',
    'location_id',
    'notes',
  ];

  static const clzFriendlyHeader = <String>[
    'Catalog Ref',
    'Media Type',
    'Title',
    'Collection Status',
    'Quantity',
    'Location ID',
    'Notes',
  ];
}
