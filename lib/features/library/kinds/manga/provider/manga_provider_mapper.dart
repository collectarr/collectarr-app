import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/manga/contracts/manga_contracts.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

class MangaLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<MangaCatalog> {
  const MangaLibraryKindProviderMapper();

  MangaMetadata metadataFromEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    _validateMangaEnvelope(envelope);
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
  MangaCatalog catalogFromEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    _validateMangaEnvelope(envelope);
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

  @override
  LibraryMetadataItem metadataItemFromEnvelope(
      NormalizedProviderEnvelopeV1 envelope) {
    return LibraryMetadataItem(
      identity: LibraryItemIdentity(
        id: envelope.providerItemId,
        mediaKind: CatalogMediaKind.manga,
      ),
      kindMetadata: metadataFromEnvelope(envelope),
    );
  }

  @override
  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
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
    return corrections;
  }

  void _validateMangaEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    if (envelope.kind.trim().toLowerCase() != CatalogMediaKind.manga.apiValue) {
      throw StateError(
        'Manga provider integration received ${envelope.kind} data',
      );
    }
  }
}
