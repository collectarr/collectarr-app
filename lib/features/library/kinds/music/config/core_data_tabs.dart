import 'package:collectarr_app/features/library/core_data/settings.dart';

/// The Album edit tabs and the Core fields each one shows, for Add/Update
/// from Core Settings.
const musicCoreDataTabs = <CoreDataSettingsTab>[
  (
    id: 'main',
    label: 'Main',
    fields: [
      (label: 'Title', keys: ['title']),
      (label: 'Sort Title', keys: ['sort_title']),
      (label: 'Subtitle', keys: ['subtitle']),
      (label: 'Artist', keys: ['artist', 'artist_credits']),
      (label: 'Original Release Date', keys: ['original_release_date']),
      (label: 'Genre', keys: ['genres']),
      (label: 'Release Date', keys: ['release_date']),
      (label: 'Label', keys: ['label']),
      (label: 'Catalog Number', keys: ['catalog_number']),
      (label: 'Barcode', keys: ['barcode']),
      (label: 'Extra', keys: ['extra']),
      (label: 'Country', keys: ['country']),
      (label: 'Packaging', keys: ['packaging']),
      (label: 'Box Set', keys: ['box_set']),
    ]
  ),
  (
    id: 'details',
    label: 'Details',
    fields: [
      (label: 'Discs', keys: ['discs']),
    ]
  ),
  (
    id: 'credits',
    label: 'Credits',
    fields: [
      (label: 'Album Credits', keys: ['credits']),
      (label: 'Disc Credits', keys: ['discs.credits']),
    ]
  ),
  (
    id: 'tracks',
    label: 'Tracks',
    fields: [
      (label: 'Tracks', keys: ['discs.tracks']),
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
    id: 'links',
    label: 'Links',
    fields: [
      (label: 'Links', keys: ['external_links']),
    ]
  ),
];
