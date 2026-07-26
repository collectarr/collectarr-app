import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildBookReleaseWorkspaceEntry(
  LibraryReleaseEntryRequest request,
) {
  final titleEntry = request.titleEntry as BookWorkspaceEntry;
  final edition = BookRelease(
    id: request.edition.id,
    title: request.edition.title,
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
          (variant) => BookVariantRef(
            id: variant.id,
            name: variant.name,
            variantType: variant.variantType,
            sku: variant.sku,
            barcode: variant.barcode,
            isbn: variant.isbn,
            region: variant.region,
            coverImageUrl: variant.coverImageUrl,
            physicalFormat: variant.physicalFormat,
            physicalFormatLabel: variant.physicalFormatLabel,
            isPrimary: variant.isPrimary,
          ),
        )
        .toList(),
  );
  final primaryVariant = edition.variants.firstWhere(
    (variant) => variant.isPrimary,
    orElse: () => edition.variants.isNotEmpty
        ? edition.variants.first
        : const BookVariantRef(id: '', name: ''),
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

LibraryWorkspaceEntry buildBookLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  final work = item == null
      ? BookWork(
          id: source.itemId,
          work: BookWorkMetadata(
            title: source.itemId,
          ),
          publishing: const BookPublishingMetadata(),
          releases: const [],
        )
      : BookCatalogMapper.mapMetadataItemToBook(item);
  final overlay = BookPersonalOverlay(
    ownedItem: source.ownedItem,
    trackingEntry: source.trackingEntry,
    wishlistItem: source.wishlistItem,
    locationPath: source.locationPath,
    watchSessions: source.watchSessions,
    itemImages: source.itemImages,
    updatedAt: source.updatedAt,
    fallbackOwnerLabel: source.fallbackOwnerLabel,
  );
  return buildBookWorkspaceEntry(work, overlay);
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
  workspaceEntryBuilder: buildBookLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildBookReleaseWorkspaceEntry,
  bucketLabelBuilder: bookLibraryBucketLabelBuilder,
  previewLabels: booksPreviewLabels,
  fieldDefinitions: bookLibraryFieldDefinitions,
);

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

BookWork _bookWorkFromMetadataItem(LibraryMetadataItem item) {
  return BookCatalogMapper.mapMetadataItemToBook(item);
}

LibraryWorkspaceEntry _bookWorkWorkspaceEntryFromMetadataItem(
  LibraryMetadataItem item,
) {
  return buildBookWorkspaceEntry(
    _bookWorkFromMetadataItem(item),
    const BookPersonalOverlay(),
  );
}

BookRelease _bookEditionFromCatalogEdition(CatalogEdition edition) {
  return BookRelease(
    id: edition.id,
    title: edition.title,
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

BookVariantRef _bookVariantFromCatalogVariant(CatalogVariant variant) {
  return BookVariantRef(
    id: variant.id,
    name: variant.name,
    variantType: variant.variantType,
    sku: variant.sku,
    barcode: variant.barcode,
    isbn: variant.isbn,
    region: variant.region,
    coverImageUrl: variant.coverImageUrl,
    physicalFormat: variant.physicalFormat,
    physicalFormatLabel: variant.physicalFormatLabel,
    isPrimary: variant.isPrimary,
  );
}
