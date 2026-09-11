import 'package:collectarr_app/features/library/kinds/boardgame/contracts/boardgame_contracts.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';

class BoardGameLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<BoardGameCatalog> {
  const BoardGameLibraryKindProviderMapper();

  @override
  BoardGameCatalog catalogFromEnvelope(ProviderMetadataEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.boardgame,
    );
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return BoardGameCatalog.fromJson({
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
    return providerCandidateFromTypedPayload(
      kind: CatalogMediaKind.boardgame,
      id: envelope.providerItemId,
      payload: catalog.toJson(),
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
