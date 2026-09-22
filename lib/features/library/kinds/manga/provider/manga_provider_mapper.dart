import 'package:collectarr_app/features/library/kinds/manga/contracts/manga_contracts.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'manga_provider_correction_patch.dart';

class MangaLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<MangaCatalog> {
  const MangaLibraryKindProviderMapper();

  MangaMetadata metadataFromEnvelope(ProviderRawEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.manga,
    );
    final norm = envelope.payload;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return MangaMetadata.fromJson({
      ...norm.toJson(),
      'id': envelope.providerItemId,
      'title': title,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (coverImageUrl != null) 'thumbnail_image_url': coverImageUrl,
    });
  }

  @override
  MangaCatalog catalogFromEnvelope(ProviderRawEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.manga,
    );
    final norm = envelope.payload;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return MangaCatalog.fromJson({
      ...norm.toJson(),
      'id': envelope.providerItemId,
      'title': title,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (coverImageUrl != null) 'thumbnail_image_url': coverImageUrl,
    });
  }

  CatalogSearchCandidate catalogCandidateFromEnvelope(
    ProviderRawEnvelope envelope,
  ) {
    final catalog = catalogFromEnvelope(envelope);
    final metadata = metadataFromEnvelope(envelope);
    final releaseDate =
        catalog.localizedReleaseDate ?? catalog.originalPublicationDate;
    return CatalogSearchCandidate.fromItem(
      CatalogItemDto.raw(
        id: catalog.id,
        mediaKind: catalog.mediaKind,
        common: CatalogCommonDto(
          title: catalog.title,
          synopsis: catalog.synopsis,
          coverImageUrl: catalog.displayCoverUrl,
          releaseDate: releaseDate,
          releaseYear: releaseDate?.year,
        ),
        payload: const <String, dynamic>{},
        kindMetadata: metadata,
      ),
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return MangaProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
