import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'package:uuid/uuid.dart';

class LibraryAddWorkflowService {
  const LibraryAddWorkflowService();

  CatalogSearchCandidate metadataItemFromPreview(
    AdminProviderPreview preview, {
    String? itemId,
  }) {
    final mediaKind = catalogMediaKindFromApiValue(preview.kind);
    final id = itemId ??
        buildPreviewCatalogItemId(
          kind: preview.kind,
          provider: preview.provider,
          providerItemId: preview.providerItemId,
        );
    final mapper = libraryKindProviderMetadataMapperForKind(mediaKind);
    if (mapper == null) {
      throw StateError('No provider mapper registered for ${preview.kind}');
    }
    return CatalogSearchCandidate.fromItem(
      mapper(
        ProviderMetadataEnvelope.fromAdminPreview(
          preview,
          itemId: id,
        ),
      ),
    );
  }

  String buildPreviewCatalogItemId({
    required String kind,
    required String provider,
    required String providerItemId,
  }) {
    final previewKey = '$kind:$provider:$providerItemId';
    return 'preview-$kind-${const Uuid().v5(Namespace.url.value, previewKey)}';
  }
}
