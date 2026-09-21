import 'package:collectarr_app/features/library/kinds/anime/contracts/anime_contracts.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'anime_provider_correction_patch.dart';

class AnimeLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<AnimeCatalog> {
  const AnimeLibraryKindProviderMapper();

  @override
  AnimeCatalog catalogFromEnvelope(ProviderRawEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.anime,
    );
    final norm = envelope.payload;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return AnimeCatalog.fromJson({
      'id': envelope.providerItemId,
      'title': title,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': coverImageUrl,
      ...norm.toJson(),
    });
  }

  CatalogSearchCandidate catalogCandidateFromEnvelope(
    ProviderRawEnvelope envelope,
  ) {
    final catalog = catalogFromEnvelope(envelope);
    return providerCandidateFromTypedProjection(
      kind: catalog.mediaKind,
      id: catalog.id,
      title: catalog.title,
      synopsis: catalog.synopsis,
      coverImageUrl: catalog.displayCoverUrl,
      releaseDate: catalog.startDate,
      releaseYear: catalog.seasonYear,
      kindMetadata: catalog,
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return AnimeProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
