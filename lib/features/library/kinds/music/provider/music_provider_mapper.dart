import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';

/// Maps the provider transport envelope into the canonical Music release
/// group. Native provider DTOs are decoded by the provider integration; this
/// class only owns Music's semantic interpretation of the envelope.
final class MusicLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<MusicReleaseGroup> {
  const MusicLibraryKindProviderMapper();

  @override
  MusicReleaseGroup catalogFromEnvelope(ProviderMetadataEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.music,
    );
    final payload = {
      ...envelope.payload.toJson(),
      'id': envelope.providerItemId,
      'kind': CatalogMediaKind.music.apiValue,
      if (envelope.images.isNotEmpty &&
          envelope.payload['cover_image_url'] == null)
        'cover_image_url': envelope.images.first.url,
    };
    return MusicCatalogMapper.mapMetadataItemToMusic(
      CatalogItemDto.fromJson(payload),
    );
  }

  CatalogSearchCandidate catalogCandidateFromEnvelope(
    ProviderMetadataEnvelope envelope,
  ) {
    final group = catalogFromEnvelope(envelope);
    return providerCandidateFromTypedPayload(
      kind: CatalogMediaKind.music,
      id: envelope.providerItemId,
      payload: group.toJson(),
      typedMetadata: group,
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
