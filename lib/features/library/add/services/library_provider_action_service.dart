import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class LibraryProviderActionService {
  const LibraryProviderActionService();

  Future<AdminProviderPreview> fetchPreview({
    required ApiClient api,
    required ProviderCandidate candidate,
  }) {
    return api.adminProviderPreview(
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
    );
  }

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
    required LibraryTypeConfig type,
    required ProviderCandidate candidate,
    required LibraryMetadataItem proposalItem,
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
      source: 'Add ${type.pluralLabel} provider result',
    );
  }
}
