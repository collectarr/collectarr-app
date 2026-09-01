import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

const genericLibraryMediaBuilder = GenericLibraryMediaPresentationBuilder();

const genericPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);

const genericLibraryGroupModes = [
  'series',
  'title',
  'publisher',
  'year',
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
  final adapter = dto is WorkspaceDtoAdapter ? dto : null;
  final publisher = adapter?.publisher?.trim();
  return switch (context.groupMode) {
    'series' => adapter?.seriesTitle?.trim().isNotEmpty == true
        ? adapter!.seriesTitle!.trim()
        : labels.unknownSeries,
    'year' => adapter?.releaseDate?.year.toString() ?? 'Unknown year',
    'publisher' => publisher == null || publisher.isEmpty
        ? labels.unknownPublisher
        : publisher,
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
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'No. / Vol....',
    publisherHint: 'Publisher / Studio / Creator...',
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
