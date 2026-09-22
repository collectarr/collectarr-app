import 'package:collectarr_app/features/library/kinds/movie/contracts/movie_contracts.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'movie_provider_correction_patch.dart';

class MovieLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<MovieCatalog> {
  const MovieLibraryKindProviderMapper();

  @override
  MovieCatalog catalogFromEnvelope(ProviderRawEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.movie,
    );
    final norm = envelope.payload;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return MovieCatalog.fromJson({
      ...norm.toJson(),
      'id': envelope.providerItemId,
      'title': title,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': coverImageUrl,
    });
  }

  CatalogSearchCandidate catalogCandidateFromEnvelope(
    ProviderRawEnvelope envelope,
  ) {
    final catalog = catalogFromEnvelope(envelope);
    final release = catalog.releases.firstOrNull;
    return providerCandidateFromTypedTransport(
      CatalogItemDto.raw(
        id: catalog.id,
        mediaKind: catalog.mediaKind,
        common: CatalogCommonDto(
          title: catalog.title,
          originalTitle: catalog.originalTitle,
          synopsis: catalog.synopsis,
          coverImageUrl: catalog.displayCoverUrl,
          releaseDate: catalog.releaseDate ?? release?.releaseDate,
        ),
        payload: const <String, dynamic>{},
        kindMetadata: catalog,
      ),
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return MovieProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
