import 'package:collectarr_app/core/api/api_client.dart';
import 'package:dio/dio.dart';
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

/// Proposes a library entry that Core does not have as a new Core item.
///
/// Core projects the entry's catalog data onto the fields it recognizes for
/// the kind; an entry without a title of its own is named as the library
/// names it.
Future<JsonMap> submitLibraryEntryToCore({
  MetadataProposalStore store = const MetadataProposalStore(),
  required ApiClient api,
  required String kind,
  required JsonMap catalogData,
  required String title,
}) {
  final catalogItem = {
    ...catalogData,
    if ((catalogData['title'] as String?)?.trim().isEmpty ?? true)
      'title': title,
  };
  return createAndRecordLibraryMetadataProposal(
    store: store,
    api: api,
    kind: kind,
    catalogItem: catalogItem,
    source: 'Submit to Core',
  );
}

/// Core's reason for refusing a request, or the error itself. A validation
/// refusal names its first failed rule rather than only "Validation error".
String coreRefusalMessage(Object error) => switch (error) {
      DioException(
        response: Response(data: {'errors': [{'msg': final String rule}, ...]})
      )
          when rule.trim().isNotEmpty =>
        rule.replaceFirst('Value error, ', '').trim(),
      DioException(response: Response(data: {'detail': final String detail}))
          when detail.trim().isNotEmpty =>
        detail.trim(),
      DioException(:final message?) when message.trim().isNotEmpty =>
        message.trim(),
      _ => '$error',
    };

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
