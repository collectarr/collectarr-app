import 'package:collectarr_app/features/library/core_data/settings.dart';

/// The Hardware edit tabs and the Core fields each one shows, for Add/Update
/// from Core Settings.
const gameHardwareCoreDataTabs = <CoreDataSettingsTab>[
  (
    id: 'main',
    label: 'Main',
    fields: [
      (label: 'Title', keys: ['title']),
      (label: 'Platform', keys: ['platform']),
      (label: 'Hardware Type', keys: ['hardware_type']),
      (label: 'Release Date', keys: ['release_date', 'release_date_parts']),
      (label: 'Series', keys: ['series_title']),
      (label: 'Barcode', keys: ['barcode']),
    ]
  ),
  (
    id: 'covers',
    label: 'Image',
    fields: [
      (label: 'Image', keys: ['cover_image_url']),
    ]
  ),
  (
    id: 'description',
    label: 'Description',
    fields: [
      (label: 'Description', keys: ['description']),
    ]
  ),
  (
    id: 'links',
    label: 'Links',
    fields: [
      (label: 'Links', keys: ['external_links']),
      (label: 'Trailers', keys: ['trailer_urls']),
    ]
  ),
];
