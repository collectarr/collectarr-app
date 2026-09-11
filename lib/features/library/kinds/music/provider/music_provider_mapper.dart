import 'package:collectarr_app/features/library/kinds/music/contracts/music_contracts.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';

class MusicLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<MusicCatalog> {
  const MusicLibraryKindProviderMapper();

  @override
  MusicCatalog catalogFromEnvelope(ProviderMetadataEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.music,
    );
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return MusicCatalog.fromJson({
      'id': envelope.providerItemId,
      'title': title,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': coverImageUrl,
      ...norm,
    });
  }

  CatalogSearchCandidate catalogCandidateFromEnvelope(
    ProviderMetadataEnvelope envelope,
  ) {
    final catalog = catalogFromEnvelope(envelope);
    final metadata = MusicCatalogMetadata.fromJson({
      ...envelope.normalized,
      'id': envelope.providerItemId,
      'title': catalog.title,
      if (catalog.coverImageUrl != null)
        'cover_image_url': catalog.coverImageUrl,
      if (catalog.thumbnailImageUrl != null)
        'thumbnail_image_url': catalog.thumbnailImageUrl,
    });
    return providerCandidateFromTypedPayload(
      kind: CatalogMediaKind.music,
      id: envelope.providerItemId,
      payload: metadata.toJson(),
      typedMetadata: metadata,
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    final corrections = <String, Object?>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    final previewPayload = preview.mapTransport((dto) => dto.payload);
    final editedPayload = edited.mapTransport((dto) => dto.payload);
    for (final entry in editedPayload.entries) {
      if (previewPayload[entry.key] != entry.value) {
        corrections[entry.key] = entry.value;
      }
    }
    return ProviderCorrectionPatch(corrections);
  }
}
