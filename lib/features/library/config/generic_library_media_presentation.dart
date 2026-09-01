import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';

const genericLibraryMediaBuilder = GenericLibraryMediaPresentationBuilder();

const genericPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);

const genericLibraryGroupModes = [
  'series',
  'title',
  'location',
  'ownership',
];

const genericLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher',
  publisherPlural: 'Publishers',
  unknownPublisher: 'Unknown publisher',
);

const genericLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

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
  final seriesRaw = context.item.source.catalogItem?.payload['series'];
  final seriesTitle =
      seriesRaw is Map ? (seriesRaw['series_title'] as String?)?.trim() : null;
  return switch (context.groupMode) {
    'series' => (seriesTitle != null && seriesTitle.isNotEmpty)
        ? seriesTitle
        : labels.unknownSeries,
    'location' => _locationBucket(context.source.locationPath),
    'title' => _titleBucket(dto.title),
    'ownership' => context.source.isOwned
        ? overrides.owned
        : context.source.isWishlisted
            ? overrides.wishlist
            : overrides.catalogOnly,
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
    seriesHint: 'Series...',
    numberHint: 'Number...',
    publisherHint: 'Publisher...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: genericLibraryGroupLabels,
  builder: genericLibraryMediaBuilder,
  projector: GenericWorkspaceProjector(),
  bucketLabelBuilder: genericLibraryBucketLabelBuilder,
  previewLabels: genericPreviewLabels,
);
