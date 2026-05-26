import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

const boardGamesLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Edition...',
    publisherHint: 'Publisher / Designer...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher / Designer',
    anyPublisher: 'Any publisher / designer',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher / Designer',
    publisherPlural: 'Publishers / Designers',
    unknownPublisher: 'Unknown publisher / designer',
  ),
  builder: boardGamesLibraryMediaBuilder,
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