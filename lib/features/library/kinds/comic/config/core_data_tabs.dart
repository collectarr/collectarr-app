import 'package:collectarr_app/features/library/core_data/settings.dart';

/// The Comic edit tabs and the Core fields each one shows, for Add/Update
/// from Core Settings.
const comicCoreDataTabs = <CoreDataSettingsTab>[
  (
    id: 'main',
    label: 'Main',
    fields: [
      (label: 'Barcode', keys: ['barcode']),
      (label: 'Format', keys: ['physical_format']),
      (label: 'Series Group', keys: ['series_group']),
      (label: 'Variant Description', keys: ['variant_description']),
      (label: 'Cover Date', keys: ['cover_date']),
      (label: 'Release Date', keys: ['release_date', 'release_date_parts']),
      (label: 'Publisher', keys: ['publisher']),
      (label: 'Imprint', keys: ['imprint']),
    ]
  ),
  (
    id: 'details',
    label: 'Details',
    fields: [
      (label: 'Crossover', keys: ['crossover']),
      (label: 'Story Arc', keys: ['story_arcs']),
      (label: 'Title', keys: ['title']),
      (label: 'Subtitle', keys: ['subtitle']),
      (label: 'Country', keys: ['country']),
      (label: 'Language', keys: ['language']),
      (label: 'Age', keys: ['publication_age']),
      (label: 'No. of Pages', keys: ['page_count']),
      (label: 'Genre', keys: ['genres']),
    ]
  ),
  (
    id: 'value',
    label: 'Value',
    fields: [
      (label: 'Cover Price', keys: ['cover_price_cents']),
    ]
  ),
  (
    id: 'covers',
    label: 'Covers',
    fields: [
      (label: 'Cover', keys: ['cover_image_url']),
    ]
  ),
  (
    id: 'plot',
    label: 'Plot',
    fields: [
      (label: 'Plot', keys: ['plot_description']),
    ]
  ),
  (
    id: 'key',
    label: 'Key',
    fields: [
      (label: 'Key Reason', keys: ['key_reason']),
    ]
  ),
  (
    id: 'creators',
    label: 'Creators',
    fields: [
      (label: 'Creators', keys: ['creators']),
    ]
  ),
  (
    id: 'characters',
    label: 'Characters',
    fields: [
      (label: 'Characters', keys: ['characters']),
    ]
  ),
];
