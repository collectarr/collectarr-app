import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';

const musicMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Album identity',
  contextSectionTitle: 'Album context',
  creditsSectionTitle: 'Contributors & Discovery',
  values: {
    'creators': 'Contributors',
    'characters': 'Featured artists',
    'genres': 'Genres',
  },
);

const musicLibraryMediaBuilder = MusicLibraryMediaPresentationBuilder(
  metadataLabels: musicMetadataLabels,
);

const musicPreviewLabels = LibraryMediaPreviewLabels(
  values: {'series': 'Artist', 'item_count': 'Releases'},
);

const musicStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Artists', 'top_publisher': 'Top Labels'},
);

const musicLibraryGroupLabels = LibraryMediaGroupLabels(
  values: {
    'series': 'Artist',
    'series_plural': 'Artists',
    'unknown_series': 'Unknown artist',
    'publisher': 'Label',
    'publisher_plural': 'Labels',
    'unknown_publisher': 'Unknown label',
  },
);

const musicLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

final musicLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
  LibraryFilterDefinition<dynamic>(
    id: 'series',
    label: 'Artist',
    anyLabel: 'Any artist',
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
    label: 'Label',
    anyLabel: 'Any label',
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

String musicLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    musicLibraryGroupLabels,
    musicLibraryBucketLabelOverrides,
  );
}

final musicLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter album, artist, release, or label...',
    emptySearchMessage: 'Enter an album, artist, release, or label.',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    values: {
      'series': 'Artist',
      'series_any': 'Any artist',
      'publisher': 'Label',
      'publisher_any': 'Any label',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: musicLibraryGroupLabels,
  builder: musicLibraryMediaBuilder,
  projector: const MusicWorkspaceProjector(),
  bucketLabelBuilder: musicLibraryBucketLabelBuilder,
  previewLabels: musicPreviewLabels,
  statsLabels: musicStatsLabels,
  filterDefinitions: musicLibraryFilterDefinitions,
  referenceLabels: const LibraryReferenceLabels(values: {'item': 'Album'}),
  fieldDefinitions: musicLibraryFieldDefinitions,
);
