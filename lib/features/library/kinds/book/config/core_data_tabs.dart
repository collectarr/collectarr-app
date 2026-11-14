import 'package:collectarr_app/features/library/core_data/settings.dart';

/// The Book edit tabs and the Core fields each one shows, for Add/Update
/// from Core Settings.
const bookCoreDataTabs = <CoreDataSettingsTab>[
  (
    id: 'main',
    label: 'Main',
    fields: [
      (label: 'Title', keys: ['title']),
      (label: 'Box Set', keys: ['box_set']),
      (label: 'Publication Place', keys: ['publication_place']),
      (label: 'Subtitle', keys: ['subtitle']),
      (
        label: 'Series',
        keys: ['series_title', 'series_memberships', 'series_group']
      ),
      (label: 'Volume', keys: ['volume_number']),
      (label: 'Volume Name', keys: ['volume_name']),
      (label: 'Authors', keys: ['creators']),
      (label: 'ISBN', keys: ['isbn', 'isbn10', 'isbn13']),
      (label: 'No. of Pages', keys: ['page_count']),
      (label: 'Publisher', keys: ['publisher']),
      (label: 'Country', keys: ['country']),
      (label: 'Format', keys: ['physical_format', 'binding']),
      (label: 'Release Date', keys: ['release_date', 'release_date_parts']),
      (label: 'Language', keys: ['language']),
      (label: 'Genre', keys: ['genres']),
      (label: 'Subject', keys: ['subjects']),
    ]
  ),
  (
    id: 'details',
    label: 'Details',
    fields: [
      (label: 'Printed By', keys: ['printed_by']),
      (label: 'Paper Type', keys: ['paper_type']),
      (label: 'Printing', keys: ['printing_number', 'printings']),
      (label: 'Extras', keys: ['extras']),
      (label: 'Number Line', keys: ['number_line']),
      (
        label: 'Dimensions',
        keys: ['width_mm', 'height_mm', 'spine_thickness_mm', 'dimensions']
      ),
      (label: 'Weight', keys: ['weight_grams']),
      (label: 'Original Title', keys: ['original_title']),
      (label: 'Original Subtitle', keys: ['original_subtitle']),
      (label: 'Original Language', keys: ['original_language']),
      (label: 'Original Country', keys: ['original_country']),
      (label: 'Original Publisher', keys: ['original_publisher']),
      (
        label: 'Original Publication Place',
        keys: ['original_publication_place']
      ),
      (
        label: 'Original Publication Date',
        keys: ['original_publication_date', 'first_publication_date']
      ),
      (label: 'Edition', keys: ['edition_statement']),
      (label: 'First Edition', keys: ['first_edition']),
      (label: 'Barcode', keys: ['barcode']),
    ]
  ),
  (
    id: 'credits',
    label: 'Credits',
    fields: [
      (label: 'Credits', keys: ['contributors']),
      (label: 'Audio Length', keys: ['audio_length_minutes']),
      (label: 'Abridged', keys: ['audio_abridged']),
    ]
  ),
  (
    id: 'covers',
    label: 'Covers',
    fields: [
      (label: 'Front Cover', keys: ['cover_image_url']),
      (label: 'Back Cover', keys: ['back_cover_image_url']),
    ]
  ),
  (
    id: 'plot',
    label: 'Plot',
    fields: [
      (
        label: 'Plot',
        keys: ['description', 'synopsis', 'plot_description', 'plot_summary']
      ),
    ]
  ),
  (
    id: 'links',
    label: 'Links',
    fields: [
      (label: 'Links', keys: ['external_links']),
    ]
  ),
];
