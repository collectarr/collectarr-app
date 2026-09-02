import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/serial_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

const mangaMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Manga identity',
  contextSectionTitle: 'Manga context',
  creditsSectionTitle: 'Creators & Discovery',
  values: {
    'creators': 'Creators',
    'characters': 'Characters',
    'story_arcs': 'Story Arcs',
    'story_arcs_inline': 'Story arcs',
    'genres': 'Genres',
  },
);

class MangaLibraryMediaPresentationBuilder
    extends SerialLibraryMediaPresentationBuilder {
  const MangaLibraryMediaPresentationBuilder()
      : super(
          showSummary: true,
          metadataLabels: mangaMetadataLabels,
          itemNumberLabel: 'Chapter / Vol.',
          publisherLabel: 'Publisher / Studio / Creator',
          variantLabel: 'Edition / Variant / Format',
          barcodeLabel: 'Barcode / UPC / ISBN',
        );
}

const mangaLibraryMediaBuilder = MangaLibraryMediaPresentationBuilder();

const mangaPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Chapters',
    'item_number': 'Chapter / Vol.',
    'publisher': 'Publisher / Studio / Creator',
    'variant': 'Edition / Variant / Format',
    'barcode': 'Barcode / UPC / ISBN',
  },
);

const mangaStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Series', 'top_publisher': 'Top Publishers'},
);

const mangaLibraryGroupLabels = LibraryMediaGroupLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Publisher',
    'publisher_plural': 'Publishers',
    'unknown_publisher': 'Unknown publisher',
    'publisher_mode': 'Publishers',
    'genre': 'Genre',
    'genre_plural': 'Genres',
    'media_scope': 'Series',
    'export_title': 'Series',
  },
);

const mangaLibraryBucketLabelOverrides = LibraryBucketLabelOverrides(
  values: {'story_arc': 'Story arc', 'character': 'Character'},
);

final mangaLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
  LibraryFilterDefinition<dynamic>(
    id: 'series',
    label: 'Series',
    anyLabel: 'Any series',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).seriesTitle
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'publisher',
    label: 'Publisher',
    anyLabel: 'Any publisher',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).publisher
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).country
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).language
        : null,
  ),
];

String mangaLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    mangaLibraryGroupLabels,
    mangaLibraryBucketLabelOverrides,
  );
}

final mangaLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Publisher',
      'publisher_any': 'Any publisher',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: mangaLibraryGroupLabels,
  builder: mangaLibraryMediaBuilder,
  bucketLabelBuilder: mangaLibraryBucketLabelBuilder,
  usesCompactTableLayout: true,
  previewLabels: mangaPreviewLabels,
  statsLabels: mangaStatsLabels,
  filterDefinitions: mangaLibraryFilterDefinitions,
);
