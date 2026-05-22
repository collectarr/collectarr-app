import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

const tvLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Season / Volume',
    publisher: 'Network / Studio',
    variant: 'Format / Edition',
    barcode: 'UPC / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Season / Volume...',
    publisherHint: 'Network / Studio...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Network / Studio',
    anyPublisher: 'Any network / studio',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Network / Studio',
    publisherPlural: 'Networks / Studios',
    unknownPublisher: 'Unknown network / studio',
  ),
  builder: tvLibraryMediaBuilder,
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