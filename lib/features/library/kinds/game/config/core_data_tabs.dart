import 'package:collectarr_app/features/library/core_data/settings.dart';

/// The Game edit tabs and the Core fields each one shows, for Add/Update
/// from Core Settings.
const gameCoreDataTabs = <CoreDataSettingsTab>[
  (
    id: 'main',
    label: 'Main',
    fields: [
      (label: 'Title', keys: ['title']),
      (label: 'Platform', keys: ['platforms']),
      (label: 'Release Date', keys: ['release_date', 'release_date_parts']),
      (label: 'Developer', keys: ['developers']),
      (label: 'Publisher', keys: ['publisher']),
      (label: 'Series', keys: ['series_title', 'franchise']),
      (label: 'Barcode', keys: ['barcode']),
      (label: 'Format', keys: ['physical_format', 'physical_format_label']),
      (label: 'Edition', keys: ['edition_title']),
      (label: 'Region', keys: ['release_region']),
      (label: 'Audience Rating', keys: ['audience_rating', 'age_rating']),
      (label: 'Genre', keys: ['genres']),
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
    id: 'description',
    label: 'Description',
    fields: [
      (
        label: 'Description',
        keys: ['description', 'synopsis', 'plot_description']
      ),
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
