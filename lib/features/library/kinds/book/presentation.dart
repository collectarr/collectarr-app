import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';

const booksPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Volumes',
);

const bookLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher',
  publisherPlural: 'Publishers',
  unknownPublisher: 'Unknown publisher',
);

const bookLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

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
    seriesHint: 'Series...',
    numberHint: 'Volume...',
    publisherHint: 'Publisher...',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: bookLibraryGroupLabels,
  builder: const BookLibraryMediaPresentationBuilder(
    showSummary: true,
    showVolumeHierarchy: true,
  ),
  projector: const BookWorkspaceProjector(),
  bucketLabelBuilder: bookLibraryBucketLabelBuilder,
  previewLabels: booksPreviewLabels,
  fieldDefinitions: bookLibraryFieldDefinitions,
);
