import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

const booksLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Volume...',
    publisherHint: 'Publisher...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher',
    publisherPlural: 'Publishers',
    unknownPublisher: 'Unknown publisher',
  ),
  builder: BookLibraryMediaPresentationBuilder(
    showSummary: true,
    showVolumeHierarchy: true,
  ),
  previewLabels: volumesPreviewLabels,
  groupModes: [
    LibraryGroupMode.publisher,
    LibraryGroupMode.series,
    LibraryGroupMode.year,
    LibraryGroupMode.creator,
    LibraryGroupMode.location,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);