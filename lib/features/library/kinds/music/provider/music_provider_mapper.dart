import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/contracts/music_contracts.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

class MusicLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<MusicCatalog> {
  const MusicLibraryKindProviderMapper();

  @override
  MusicCatalog catalogFromEnvelope(NormalizedProviderEnvelopeV1 envelope) {
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

  @override
  LibraryMetadataItem metadataItemFromEnvelope(
      NormalizedProviderEnvelopeV1 envelope) {
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final synopsis = norm['synopsis']?.toString();
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    DateTime? releaseDate;
    if (norm['release_date'] != null) {
      releaseDate = DateTime.tryParse(norm['release_date'].toString());
    }

    final musicMetadata = MusicCatalogMetadata.fromJson(norm);

    return LibraryMetadataItem(
      identity: LibraryItemIdentity(
        id: envelope.providerItemId,
        mediaKind: CatalogMediaKind.music,
      ),
      common: LibraryCommonMetadata(
        title: title,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: coverImageUrl,
        releaseDate: releaseDate,
        releaseYear: releaseDate?.year,
      ),
      kindMetadata: musicMetadata,
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
    final previewPayload = preview.kindMetadata.toSyncPayload();
    final editedPayload = edited.kindMetadata.toSyncPayload();
    for (final entry in editedPayload.entries) {
      if (previewPayload[entry.key] != entry.value) {
        corrections[entry.key] = entry.value;
      }
    }
    return corrections;
  }
}
