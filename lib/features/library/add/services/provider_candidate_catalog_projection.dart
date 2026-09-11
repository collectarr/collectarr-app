import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';

/// Projects a provider candidate into a provisional catalog transport item.
///
/// Provider candidates are transport data. The kind registry is consulted only
/// here, at the Library Add composition boundary, to attach the owning kind's
/// typed metadata decoder. Provider transport code must not depend on kinds.
LibraryAddCatalogTransport catalogItemFromProviderCandidate(
  ProviderCandidate candidate,
) {
  final item = CatalogItemDto.fromJson({
    'id': candidate.localCatalogId,
    'kind': candidate.kind.apiValue,
    'title': candidate.title,
    'item_number': candidate.issueNumber,
    'issue_number': candidate.issueNumber,
    'synopsis': candidate.summary,
    'cover_image_url': candidate.imageUrl,
    'variant': candidate.variantName,
    'publisher': candidate.publisher,
    if (candidate.series != null) 'series_title': candidate.series!.seriesTitle,
    if (candidate.series != null)
      'volume_start_year': candidate.series!.volumeStartYear,
    if (candidate.series != null)
      'release_year': candidate.series!.volumeStartYear,
  });
  final decoder = libraryKindCatalogMetadataDecoderForKind(candidate.kind);
  return LibraryAddCatalogTransport.fromItem(
    decoder == null ? item : item.withKindMetadata(decoder(item.payload)),
  );
}
