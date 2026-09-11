import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/tv/contracts/tv_contracts.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'tv_provider_typed_mapper.dart';

class TvLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<TvCatalog> {
  const TvLibraryKindProviderMapper();

  @override
  TvCatalog catalogFromEnvelope(ProviderMetadataEnvelope envelope) {
    return TvCatalog.fromJson(
      TvProviderTypedMapper.payloadFromEnvelope(envelope),
    );
  }

  CatalogItemDto metadataItemFromEnvelope(ProviderMetadataEnvelope envelope) {
    final tvMetadata = TvSeriesMetadata.fromJson(
      TvProviderTypedMapper.payloadFromEnvelope(envelope),
    );

    return CatalogItemDto(
      identity: LibraryItemIdentity(
        id: envelope.providerItemId,
        mediaKind: CatalogMediaKind.tv,
      ),
      kindMetadata: tvMetadata,
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required LibraryAddCatalogTransport preview,
    required LibraryAddCatalogTransport edited,
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
