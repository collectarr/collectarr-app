import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';

Future<JsonMap> createLibraryMetadataProposal({
  required ApiClient api,
  required String kind,
  required JsonMap catalogItem,
}) {
  return api.createCatalogItemProposal(kind: kind, catalogItem: catalogItem);
}

Future<JsonMap> createAndRecordLibraryMetadataProposal({
  MetadataProposalStore store = const MetadataProposalStore(),
  required ApiClient api,
  required String kind,
  required JsonMap catalogItem,
  required String source,
}) async {
  final response = await createLibraryMetadataProposal(
    api: api,
    kind: kind,
    catalogItem: catalogItem,
  );
  await store.recordResponse(
    response: response,
    kind: kind,
    title: _proposalTitle(catalogItem),
    source: source,
  );
  return response;
}

Future<void> recordLibraryMetadataProposalResponse({
  MetadataProposalStore store = const MetadataProposalStore(),
  required JsonMap response,
  required String kind,
  required JsonMap catalogItem,
  required String source,
}) {
  return store.recordResponse(
    response: response,
    kind: kind,
    title: _proposalTitle(catalogItem),
    source: source,
  );
}

String? _proposalTitle(JsonMap item) {
  final title = item['primary_label'] ??
      item['primaryLabel'] ??
      item['title'] ??
      item['name'];
  final trimmed = title is String ? title.trim() : '';
  return trimmed.isEmpty ? null : trimmed;
}
