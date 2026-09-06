import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

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
    required LibraryKindModule type,
    required ProviderCandidate candidate,
    required CatalogItem proposalItem,
  }) {
    return createAndRecordLibraryMetadataProposal(
      api: api,
      type: type,
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
      query: proposalItem.title,
      title: proposalItem.title,
      summary: proposalItem.synopsis ?? candidate.summary,
      imageUrl: proposalItem.displayCoverUrl,
      metadataPayload: proposalItem.toSyncPayload(),
      source: 'Add ${type.identity.pluralLabel} provider result',
    );
  }
}
