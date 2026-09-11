import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_bundle.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

class LibraryProviderActionService {
  const LibraryProviderActionService();

  Future<AdminProviderIngestJob> queueIngest({
    required ApiClient api,
    required ProviderCandidate candidate,
  }) {
    return api.adminCreateProviderIngestJob(
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
    );
  }

  Future<AdminProviderIngestResult> ingestCandidate({
    required ApiClient api,
    required ProviderCandidate candidate,
  }) {
    return api.adminProviderIngest(
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
    );
  }

  Future<void> proposeMetadata({
    required ApiClient api,
    required LibraryKindRegistration type,
    required ProviderCandidate candidate,
    required CatalogSearchCandidate proposalItem,
  }) {
    return createAndRecordLibraryMetadataProposal(
      api: api,
      kind: type.kind,
      defaultProvider: type.metadata.defaultProviderId,
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
      query: proposalItem.title,
      title: proposalItem.title,
      summary: proposalItem.synopsis ?? candidate.summary,
      imageUrl: proposalItem.displayCoverUrl,
      metadataPayload: proposalItem.mapTransport(
        (transport) => transport.toSyncPayload(),
      ),
      source: 'Add ${type.identity.pluralLabel} provider result',
    );
  }
}
