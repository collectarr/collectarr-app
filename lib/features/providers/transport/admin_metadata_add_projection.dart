import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';

/// Decodes the provider-ingest response into the Add transport wrapper.
///
/// This is deliberately kept at the provider transport boundary.  The Add
/// host receives an opaque [LibraryAddCatalogTransport] and dispatches it to the
/// owning kind before constructing any canonical domain object.
LibraryAddCatalogTransport libraryAddCatalogItemFromIngestResult(
  AdminMetadataItem item,
) {
  final primaryEdition = item.primaryEdition;
  final primaryVariant = item.primaryVariant;
  final releaseDate = primaryEdition?.releaseDate;
  return LibraryAddCatalogTransport.fromJson({
    'id': item.id,
    'kind': item.kind,
    'title': item.title,
    'item_number': item.itemNumber,
    'synopsis': item.synopsis,
    'cover_image_url': primaryVariant?.coverImageUrl ?? item.displayCoverUrl,
    'thumbnail_image_url':
        primaryVariant?.thumbnailImageUrl ?? item.displayCoverUrl,
    'publisher': primaryEdition?.publisher ?? item.publisher,
    'edition_title': primaryEdition?.title,
    'physical_format': primaryEdition?.physicalFormat,
    'physical_format_label': primaryEdition?.physicalFormatLabel,
    'release_date': releaseDate?.toUtc().toIso8601String(),
    'barcode': primaryVariant?.identifierCode ?? item.identifierCode,
    'variant': primaryVariant?.name,
    if (item.series != null) 'series_title': item.series!.seriesTitle,
  });
}
