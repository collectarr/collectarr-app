import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/generated/catalog_item_v1_fields.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';

List<String> unknownCatalogItemProposalFields({
  required String kind,
  required JsonMap catalogItem,
}) {
  final allowedFields = catalogItemV1FieldsByKind[kind.trim().toLowerCase()];
  if (allowedFields == null) {
    return catalogItem.keys.toList()..sort();
  }
  return catalogItem.keys
      .where((field) => !allowedFields.contains(field))
      .toList()
    ..sort();
}

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
  final title = item['title'] ?? item['name'];
  final trimmed = title is String ? title.trim() : '';
  return trimmed.isEmpty ? null : trimmed;
}
