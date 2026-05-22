import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

const gamesLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Version',
    publisher: 'Publisher / Studio',
    variant: 'Platform / Edition',
    barcode: 'UPC / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Version...',
    publisherHint: 'Publisher / Studio...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher / Studio',
    anyPublisher: 'Any publisher / studio',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher / Studio',
    publisherPlural: 'Publishers / Studios',
    unknownPublisher: 'Unknown publisher / studio',
  ),
  builder: gamesLibraryMediaBuilder,
  previewLabels: defaultPreviewLabels,
  statsLabels: gameStatsLabels,
  groupModes: [
    LibraryGroupMode.publisher,
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.location,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);