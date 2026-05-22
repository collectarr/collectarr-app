import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

const animeLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Season / Volume',
    publisher: 'Studio / Publisher',
    variant: 'Edition / Format',
    barcode: 'UPC / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Season / Volume...',
    publisherHint: 'Studio / Publisher...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Studio / Publisher',
    anyPublisher: 'Any studio / publisher',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Studio / Publisher',
    publisherPlural: 'Studios / Publishers',
    unknownPublisher: 'Unknown studio / publisher',
  ),
  builder: animeLibraryMediaBuilder,
  previewLabels: seasonsPreviewLabels,
  statsLabels: franchiseStatsLabels,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.publisher,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);