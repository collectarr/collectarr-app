import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

const genericLibraryMediaBuilder = GenericLibraryMediaPresentationBuilder();

const genericPreviewLabels = LibraryMediaPreviewLabels(
  values: {'item_count': 'Items'},
);

const genericLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
  LibraryFilterDefinition<dynamic>(
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
  ),
];

const genericLibraryGroupLabels = LibraryMediaGroupLabels(
  values: {},
);

const genericLibraryBucketLabelOverrides =
    LibraryBucketLabelOverrides(values: {});

String genericLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return _simpleLibraryBucketLabel(
    context,
    genericLibraryGroupLabels,
    genericLibraryBucketLabelOverrides,
  );
}

String _simpleLibraryBucketLabel(
  LibraryBucketingContext context,
  LibraryMediaGroupLabels labels,
  LibraryBucketLabelOverrides overrides,
) {
  final dto = context.item.dto;
  final adapter = dto is WorkspaceDtoAdapter ? dto : null;
  final seriesTitle = adapter?.seriesTitle?.trim();
  return switch (context.groupMode) {
    'series' => (seriesTitle != null && seriesTitle.isNotEmpty)
        ? seriesTitle
        : labels.labelFor('unknown_series', fallback: 'Unknown series'),
    'location' => _locationBucket(context.source.locationPath),
    'title' => _titleBucket(dto.title),
    'ownership' => context.source.isOwned
        ? overrides.labelFor('owned', fallback: 'Owned')
        : context.source.isWishlisted
            ? overrides.labelFor('wishlist', fallback: 'Wishlist')
            : overrides.labelFor('catalog_only', fallback: 'Catalog only'),
    _ => context.groupMode,
  };
}

String _locationBucket(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'No location';
  }
  return normalized;
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.substring(0, 1).toUpperCase();
}

const genericLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Search catalog...',
    emptySearchMessage: 'Enter a search query.',
  ),
  filterLabels: LibraryMediaFilterLabels(
    values: {},
  ),
  groupLabels: genericLibraryGroupLabels,
  builder: genericLibraryMediaBuilder,
  projector: GenericWorkspaceProjector(),
  bucketLabelBuilder: genericLibraryBucketLabelBuilder,
  previewLabels: genericPreviewLabels,
  filterDefinitions: genericLibraryFilterDefinitions,
);
