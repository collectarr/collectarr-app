import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_item_types.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildBookReleaseWorkspaceEntry(
  LibraryReleaseEntryRequest request,
) {
  final titleEntry = request.titleEntry as BookWorkspaceEntry;
  final edition = BookEdition(
    id: request.edition.id,
    title: request.edition.title,
    format: request.edition.format,
    publisher: request.edition.publisher,
    isbn: request.edition.isbn,
    upc: request.edition.upc,
    language: request.edition.language,
    region: request.edition.region,
    releaseDate: request.edition.releaseDate,
    physicalFormat: request.edition.physicalFormat,
    physicalFormatLabel: request.edition.physicalFormatLabel,
    variants: request.edition.variants
        .map(
          (variant) => BookVariant(
            id: variant.id,
            name: variant.name,
            variantType: variant.variantType,
            sku: variant.sku,
            barcode: variant.barcode,
            isbn: variant.isbn,
            region: variant.region,
            coverImageUrl: variant.coverImageUrl,
            thumbnailImageUrl: variant.thumbnailImageUrl,
            description: variant.description,
            physicalFormat: variant.physicalFormat,
            physicalFormatLabel: variant.physicalFormatLabel,
            isPrimary: variant.isPrimary,
          ),
        )
        .toList(growable: false),
  );
  final primaryVariant = edition.variants.firstWhere(
    (variant) => variant.isPrimary,
    orElse: () => edition.variants.isNotEmpty
        ? edition.variants.first
        : const BookVariant(id: '', name: ''),
  );
  return buildBookEditionWorkspaceEntry(
    titleEntry: titleEntry,
    edition: edition,
    variant: primaryVariant.id.isEmpty ? null : primaryVariant,
    overlay: BookPersonalOverlay(
      ownedItem: null,
      trackingEntry: null,
      wishlistItem: null,
      updatedAt: request.updatedAt,
    ),
    isOwned: request.isOwned,
    isTracked: request.isTracked,
    isWishlisted: request.isWishlisted,
    referenceEditionId: request.referenceEditionId,
    referenceVariantId: request.referenceVariantId,
    referenceBundleReleaseId: request.referenceBundleReleaseId,
    updatedAt: request.updatedAt,
  );
}

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
  groupLabels: bookLibraryGroupLabels,
  builder: BookLibraryMediaPresentationBuilder(
    showSummary: true,
    showVolumeHierarchy: true,
  ),
  workspaceEntryBuilder: (ShelfEntry source) => buildBookWorkspaceEntry(
    _bookWorkFromMetadataItem(source.catalogItem!),
    BookPersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      watchSessions: source.watchSessions,
      itemImages: source.itemImages,
      updatedAt: source.updatedAt,
      fallbackOwnerLabel: source.fallbackOwnerLabel,
    ),
  ),
  releaseEntryBuilder: buildBookReleaseWorkspaceEntry,
  bucketLabelBuilder: bookLibraryBucketLabelBuilder,
  previewLabels: booksPreviewLabels,
  fieldDefinitions: bookLibraryFieldDefinitions,
  sortColumnDefinitions: bookLibrarySortColumnDefinitions,
  groupModeDefinitions: bookLibraryGroupModeDefinitions,
  groupModes: bookLibraryGroupModes,
);

BookWork _bookWorkFromMetadataItem(LibraryMetadataItem item) {
  return BookWork(
    id: item.id,
    title: item.title,
    displayTitle: item.displayTitle,
    localizedTitle: item.localizedTitle,
    originalTitle: item.originalTitle,
    searchAliases: List<String>.unmodifiable(item.searchAliases ?? const []),
    itemNumber: item.itemNumber,
    synopsis: item.synopsis,
    coverImageUrl: item.coverImageUrl,
    thumbnailImageUrl: item.thumbnailImageUrl,
    publisher: item.publisher,
    coverDate: item.coverDate,
    releaseDate: item.releaseDate,
    releaseYear: item.releaseYear,
    barcode: item.barcode,
    variant: item.variant,
    crossover: item.crossover,
    series: item.series,
    publishing: item.publishing,
    editions: [
      for (final edition in item.editions)
        _bookEditionFromCatalogEdition(edition),
    ],
    trailerUrls: List.unmodifiable(item.trailerUrls),
    plotSummary: item.plotSummary,
    plotDescription: item.plotDescription,
    creators: item.creators == null
        ? null
        : List<Map<String, dynamic>>.unmodifiable(
            item.creators!
                .map((value) => Map<String, dynamic>.unmodifiable(value)),
          ),
    characters: List<String>.unmodifiable(item.characters ?? const []),
    storyArcs: List<String>.unmodifiable(item.storyArcs ?? const []),
    genres: List<String>.unmodifiable(item.genres ?? const []),
    country: item.country,
    language: item.language,
    ageRating: item.ageRating,
    audienceRating: item.audienceRating,
    physicalFormatLabel: item.physicalFormatLabel,
  );
}

BookEdition _bookEditionFromCatalogEdition(CatalogEdition edition) {
  return BookEdition(
    id: edition.id,
    title: edition.title,
    format: edition.format,
    publisher: edition.publisher,
    isbn: edition.isbn,
    upc: edition.upc,
    language: edition.language,
    region: edition.region,
    releaseDate: edition.releaseDate,
    physicalFormat: edition.physicalFormat,
    physicalFormatLabel: edition.physicalFormatLabel,
    variants: [
      for (final variant in edition.variants)
        _bookVariantFromCatalogVariant(variant),
    ],
  );
}

BookVariant _bookVariantFromCatalogVariant(CatalogVariant variant) {
  return BookVariant(
    id: variant.id,
    name: variant.name,
    variantType: variant.variantType,
    sku: variant.sku,
    barcode: variant.barcode,
    isbn: variant.isbn,
    region: variant.region,
    coverImageUrl: variant.coverImageUrl,
    thumbnailImageUrl: variant.thumbnailImageUrl,
    description: variant.description,
    physicalFormat: variant.physicalFormat,
    physicalFormatLabel: variant.physicalFormatLabel,
    isPrimary: variant.isPrimary,
  );
}
