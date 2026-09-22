import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

class LibraryProviderActionService {
  const LibraryProviderActionService();

  Future<AdminProviderIngestJob> queueIngest({
    required ApiClient api,
    required ProviderSearchCandidate candidate,
  }) {
    if (candidate.previewOnly) {
      throw StateError('Select a concrete release before queueing ingest.');
    }
    return api.adminCreateProviderIngestJob(
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
    );
  }

  Future<AdminProviderIngestResult> ingestCandidate({
    required ApiClient api,
    required ProviderSearchCandidate candidate,
  }) {
    if (candidate.previewOnly) {
      throw StateError('Select a concrete release before ingesting metadata.');
    }
    return api.adminProviderIngest(
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
    );
  }

  Future<void> proposeMetadata({
    required ApiClient api,
    required LibraryKindRegistration type,
    required ProviderSearchCandidate candidate,
    required CatalogSearchCandidate proposalItem,
  }) {
    if (candidate.previewOnly) {
      throw StateError('Select a concrete release before proposing metadata.');
    }
    return createAndRecordLibraryMetadataProposal(
      api: api,
      kind: type.kind,
      defaultProvider: libraryMetadataForKind(type.kind).defaultProviderId,
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
      query: proposalItem.primaryLabel,
      title: proposalItem.primaryLabel,
      summary: proposalItem.editMetadata.synopsis ?? candidate.summary,
      imageUrl: proposalItem.editMetadata.displayCoverUrl,
      metadataPayload: proposalItem.mapTransport(
        (transport) => transport.toSyncPayload(),
      ),
      source: 'Add ${type.identity.pluralLabel} provider result',
    );
  }
}
