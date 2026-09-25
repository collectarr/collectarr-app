import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';

const comicsMetadataLabels = LibraryMetadataLabels(
  values: {
    'creators': 'Creators',
    'characters': 'Characters',
    'story_arcs_inline': 'Story arcs',
    'genres': 'Genres',
  },
);

const comicLibraryMediaBuilder = ComicLibraryMediaPresentationBuilder(
  showSummary: true,
  metadataLabels: comicsMetadataLabels,
);

const comicsPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Issues',
    'item_number': 'No. / Vol.',
    'publisher': 'Publisher / Studio / Creator',
    'variant': 'Edition / Variant / Format',
    'barcode': 'Barcode / UPC / ISBN',
    'media_scope': 'Series',
    'export_title': 'Series',
  },
);

const comicsIssueVisibleColumns = {
  'status',
  'cover',
  'title',
  'issue',
  'publisher',
  'release_date',
  'barcode',
  'condition',
  'price',
  'location',
  'wishlist',
  'updated',
};

const comicLibraryGroupLabels = LibraryPresentationLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Publisher',
    'publisher_plural': 'Publishers',
    'unknown_publisher': 'Unknown publisher',
    'media_scope': 'Series',
    'export_title': 'Series',
  },
);

const comicLibraryBucketLabelOverrides = LibraryPresentationLabels();

final comicLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  LibraryFilterDefinition<Object?>(
    id: 'series',
    label: 'Series',
    anyLabel: 'Any series',
    value: (item) => (item.dto is ComicWorkspaceDto)
        ? (item.dto as ComicWorkspaceDto).seriesTitle
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
    value: (item) => ComicOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.tags?.split(','),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'publisher',
    label: 'Publisher',
    anyLabel: 'Any publisher',
    value: (item) => (item.dto is ComicWorkspaceDto)
        ? (item.dto as ComicWorkspaceDto).publisher
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is ComicWorkspaceDto)
        ? (item.dto as ComicWorkspaceDto).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'grade',
    label: 'Grade',
    anyLabel: 'Any grade',
    missingValueLabel: 'Missing grade',
    value: (item) => ComicOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.grade,
    matches: (item, value) => value == LibraryFilterDefinition.missingValue
        ? item.source.isOwned &&
            (ComicOwnedItemProjection.fromDispatch(
                            item.source.ownedItemDispatch)
                        ?.grade ==
                    null ||
                ComicOwnedItemProjection.fromDispatch(
                        item.source.ownedItemDispatch)!
                    .grade!
                    .trim()
                    .isEmpty)
        : ComicOwnedItemProjection.fromDispatch(item.source.ownedItemDispatch)
                ?.grade
                ?.trim() ==
            value,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => ComicOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.condition,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is ComicWorkspaceDto)
        ? (item.dto as ComicWorkspaceDto).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is ComicWorkspaceDto)
        ? (item.dto as ComicWorkspaceDto).language
        : null,
  ),
];

String comicLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    comicLibraryGroupLabels,
    comicLibraryBucketLabelOverrides,
  );
}

final comicLibraryMediaPresentation = LibraryMediaPresentation(
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
  groupLabels: comicLibraryGroupLabels,
  builder: comicLibraryMediaBuilder,
  bucketLabelBuilder: comicLibraryBucketLabelBuilder,
  cardPresentationBuilder: buildComicCardPresentation,
  quickViewMatcher: comicQuickViewMatcher,
  previewLabels: comicsPreviewLabels,
  filterDefinitions: comicLibraryFilterDefinitions,
);

bool? comicQuickViewMatcher(
  LibraryProjectionView item,
  LibraryQuickView view,
) {
  return switch (view) {
    LibraryQuickView.missingGrade => item.source.isOwned &&
        (ComicOwnedItemProjection.fromDispatch(item.source.ownedItemDispatch)
                    ?.grade ==
                null ||
            ComicOwnedItemProjection.fromDispatch(
                    item.source.ownedItemDispatch)!
                .grade!
                .trim()
                .isEmpty),
    _ => null,
  };
}
