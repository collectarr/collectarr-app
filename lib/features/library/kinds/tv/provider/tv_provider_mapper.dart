import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/contracts/tv_contracts.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'tv_provider_typed_mapper.dart';

class TvLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<TvCatalog> {
  const TvLibraryKindProviderMapper();

  @override
  TvCatalog catalogFromEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    return TvCatalog.fromJson(
      TvProviderTypedMapper.payloadFromEnvelope(envelope),
    );
  }

  @override
  LibraryMetadataItem metadataItemFromEnvelope(
      NormalizedProviderEnvelopeV1 envelope) {
    final tvMetadata = TvSeriesMetadata.fromJson(
      TvProviderTypedMapper.payloadFromEnvelope(envelope),
    );

    return LibraryMetadataItem(
      identity: LibraryItemIdentity(
        id: envelope.providerItemId,
        mediaKind: CatalogMediaKind.tv,
      ),
      kindMetadata: tvMetadata,
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
