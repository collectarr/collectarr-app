import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';

String resolveLibraryMetadataProposalProvider(
  LibraryTypeConfig type, {
  String? provider,
}) {
  final requestedProvider = provider?.trim();
  if (requestedProvider == null || requestedProvider.isEmpty) {
    return type.defaultSupportedMetadataProvider;
  }
  if (!type.supportsMetadataProvider(requestedProvider)) {
    throw ArgumentError.value(
      requestedProvider,
      'provider',
      '${type.pluralLabel} does not support this metadata provider',
    );
  }
  return requestedProvider;
}

Future<Map<String, dynamic>> createLibraryMetadataProposal({
  required ApiClient api,
  required LibraryTypeConfig type,
  String? provider,
  String? providerItemId,
  required String query,
  String? title,
  String? summary,
  String? imageUrl,
  Map<String, dynamic>? metadataPayload,
}) {
  return api.createMetadataProposal(
    provider: resolveLibraryMetadataProposalProvider(
      type,
      provider: provider,
    ),
    providerItemId: providerItemId,
    query: query,
    title: title,
    summary: summary,
    imageUrl: imageUrl,
    metadataPayload: metadataPayload,
  );
}

Future<Map<String, dynamic>> createAndRecordLibraryMetadataProposal({
  MetadataProposalStore store = const MetadataProposalStore(),
  required ApiClient api,
  required LibraryTypeConfig type,
  String? provider,
  String? providerItemId,
  required String query,
  String? title,
  String? summary,
  String? imageUrl,
  Map<String, dynamic>? metadataPayload,
  required String source,
}) async {
  final resolvedProvider = resolveLibraryMetadataProposalProvider(
    type,
    provider: provider,
  );
  final response = await api.createMetadataProposal(
    provider: resolvedProvider,
    providerItemId: providerItemId,
    query: query,
    title: title,
    summary: summary,
    imageUrl: imageUrl,
    metadataPayload: metadataPayload,
  );
  await store.recordResponse(
    response: response,
    provider: resolvedProvider,
    query: query,
    title: title,
    source: source,
  );
  return response;
}

Future<void> recordLibraryMetadataProposalResponse({
  MetadataProposalStore store = const MetadataProposalStore(),
  required Map<String, dynamic> response,
  required LibraryTypeConfig type,
  String? provider,
  required String query,
  String? title,
  required String source,
}) {
  return store.recordResponse(
    response: response,
    provider: resolveLibraryMetadataProposalProvider(
      type,
      provider: provider,
    ),
    query: query,
    title: title,
    source: source,
  );
}
