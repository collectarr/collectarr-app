import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

const mangaLibraryMediaPresentation = LibraryMediaPresentation(
  fieldLabels: LibraryMediaFieldLabels(
    number: 'Volume / Chapter',
    publisher: 'Publisher',
    variant: 'Edition / Variant',
    barcode: 'ISBN / Barcode',
  ),
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Volume / Chapter...',
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
  builder: mangaLibraryMediaBuilder,
  defaultVisibleColumns: issueVisibleColumns,
  previewLabels: volumesPreviewLabels,
  usesTreeProviderCandidates: true,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.publisher,
    LibraryGroupMode.year,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);