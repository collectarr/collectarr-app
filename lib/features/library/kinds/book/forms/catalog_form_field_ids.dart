import 'package:collectarr_app/features/library/kinds/book/config/book_field_identities.dart';

const bookMainFieldIds = {
  'catalog_title',
  'sort_title',
  BookFieldIdentities.subtitleId,
  'original_title',
  'localized_title',
  'number',
  'variant',
  'title',
  'binding',
  BookFieldIdentities.formatId,
  BookFieldIdentities.releaseDateId,
  BookFieldIdentities.publisherId,
  'imprint',
  'language',
  'publication_year',
  'series_group',
  'distributor',
  BookFieldIdentities.pageCountId,
  'characters',
  'genres',
  'subjects',
  'age_rating',
  'country',
  'region',
  'release_status',
  'edition_statement',
  'dimensions',
  'first_edition',
  'audio_length_minutes',
  'original_language',
  'first_publication_date',
  'original_publication_date',
  'search_aliases',
  BookFieldIdentities.seriesId,
};

const bookCreditFieldIds = {'authors', 'translators'};
const bookLinkFieldIds = {BookFieldIdentities.isbnId, 'barcode'};
const bookCoverFieldIds = {'cover_image_url', 'back_cover_image_url'};
const bookPlotFieldIds = {'description'};
