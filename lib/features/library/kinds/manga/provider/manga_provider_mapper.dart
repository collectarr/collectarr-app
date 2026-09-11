import 'package:collectarr_app/features/library/kinds/manga/contracts/manga_contracts.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';

class MangaLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<MangaCatalog> {
  const MangaLibraryKindProviderMapper();

  MangaMetadata metadataFromEnvelope(ProviderMetadataEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.manga,
    );
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return MangaMetadata.fromJson({
      ...norm,
      'title': title,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (coverImageUrl != null) 'thumbnail_image_url': coverImageUrl,
    });
  }

  @override
  MangaCatalog catalogFromEnvelope(ProviderMetadataEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.manga,
    );
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return MangaCatalog.fromJson({
      ...norm,
      'id': envelope.providerItemId,
      'title': title,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (coverImageUrl != null) 'thumbnail_image_url': coverImageUrl,
    });
  }

  CatalogItemDto metadataItemFromEnvelope(ProviderMetadataEnvelope envelope) {
    return CatalogItemDto(
      identity: LibraryItemIdentity(
        id: envelope.providerItemId,
        mediaKind: CatalogMediaKind.manga,
      ),
      kindMetadata: metadataFromEnvelope(envelope),
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogItemDto preview,
    required CatalogItemDto edited,
  }) {
    final corrections = <String, Object?>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    final previewPayload = preview.payload;
    final editedPayload = edited.payload;
    for (final entry in editedPayload.entries) {
      if (previewPayload[entry.key] != entry.value) {
        corrections[entry.key] = entry.value;
      }
    }
    return ProviderCorrectionPatch(corrections);
  }
}
