import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_field_identities.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';

const booksPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Volumes',
    'item_number': 'Volume',
    'publisher': 'Publisher',
    'variant': 'Edition / Binding',
    'barcode': 'ISBN / Barcode',
  },
);

const booksMetadataLabels = LibraryMetadataLabels(
  values: {'creators': 'Creators', 'genres': 'Genres'},
);

const bookLibraryGroupLabels = LibraryPresentationLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Publisher',
    'publisher_plural': 'Publishers',
    'unknown_publisher': 'Unknown publisher',
  },
);

const bookLibraryBucketLabelOverrides = LibraryPresentationLabels();

final bookLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  LibraryFilterDefinition<Object?>(
    id: BookFieldIdentities.seriesId,
    label: BookFieldIdentities.seriesLabel,
    anyLabel: 'Any series',
    value: (item) => (item.dto is BookWorkspaceDto)
        ? (item.dto as BookWorkspaceDto).seriesTitle
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<Object?>(
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
    value: (item) => BookLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.tags?.split(','),
  ),
  LibraryFilterDefinition<Object?>(
    id: BookFieldIdentities.publisherId,
    label: BookFieldIdentities.publisherLabel,
    anyLabel: 'Any publisher',
    value: (item) => (item.dto is BookWorkspaceDto)
        ? (item.dto as BookWorkspaceDto).publisher
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is BookWorkspaceDto)
        ? (item.dto as BookWorkspaceDto).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => BookLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.condition,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is BookWorkspaceDto)
        ? (item.dto as BookWorkspaceDto).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is BookWorkspaceDto)
        ? (item.dto as BookWorkspaceDto).language
        : null,
  ),
];

String bookLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    bookLibraryGroupLabels,
    bookLibraryBucketLabelOverrides,
  );
}

final bookLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
  ),
  filterLabels: const LibraryPresentationLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Publisher',
      'publisher_any': 'Any publisher',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: bookLibraryGroupLabels,
  builder: const BookLibraryMediaPresentationBuilder(
    showSummary: true,
    showVolumeHierarchy: true,
    metadataLabels: booksMetadataLabels,
  ),
  bucketLabelBuilder: bookLibraryBucketLabelBuilder,
  previewLabels: booksPreviewLabels,
  filterDefinitions: bookLibraryFilterDefinitions,
);
