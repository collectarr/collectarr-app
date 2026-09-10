import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';

String resolveLibraryMetadataProposalProvider(
  CatalogMediaKind kind, {
  String? provider,
  String? defaultProvider,
}) {
  final requestedProvider = provider?.trim();
  if (requestedProvider == null || requestedProvider.isEmpty) {
    final configured = defaultProvider?.trim();
    if (configured != null && configured.isNotEmpty) {
      final supported = collectarrMetadataProviderRegistry.byId(configured);
      if (supported?.supportsKind(kind) == true) return configured;
    }
    final first = collectarrMetadataProviderRegistry.forKind(kind).firstOrNull;
    if (first == null) {
      throw ArgumentError.value(
        kind,
        'kind',
        'No metadata provider is registered for ${kind.apiValue}',
      );
    }
    return first.id;
  }
  final supported = collectarrMetadataProviderRegistry.byId(requestedProvider);
  if (supported?.supportsKind(kind) != true) {
    throw ArgumentError.value(
      requestedProvider,
      'provider',
      '${kind.apiValue} does not support this metadata provider',
    );
  }
  return requestedProvider;
}

Future<Map<String, dynamic>> createLibraryMetadataProposal({
  required ApiClient api,
  required CatalogMediaKind kind,
  String? defaultProvider,
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
      kind,
      provider: provider,
      defaultProvider: defaultProvider,
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
  required CatalogMediaKind kind,
  String? defaultProvider,
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
    kind,
    provider: provider,
    defaultProvider: defaultProvider,
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
  required CatalogMediaKind kind,
  String? defaultProvider,
  String? provider,
  required String query,
  String? title,
  required String source,
}) {
  return store.recordResponse(
    response: response,
    provider: resolveLibraryMetadataProposalProvider(
      kind,
      provider: provider,
      defaultProvider: defaultProvider,
    ),
    query: query,
    title: title,
    source: source,
  );
}
