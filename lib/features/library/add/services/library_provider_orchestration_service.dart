import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/add/services/library_add_workflow_service.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:dio/dio.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';

typedef BuildProviderCorrections = Map<String, Object?> Function({
  required LibraryAddCatalogTransport preview,
  required LibraryAddCatalogTransport edited,
});

class LibraryProviderOrchestrationService {
  const LibraryProviderOrchestrationService();

  static const _workflow = LibraryAddWorkflowService();

  LibraryAddCatalogTransport proposalDraftFromCandidate({
    required LibraryKindModule type,
    required ProviderCandidate candidate,
  }) {
    final mediaKind = type.kind;
    final id = _workflow.buildPreviewCatalogItemId(
      kind: mediaKind.apiValue,
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
    );
    return LibraryAddCatalogTransport.fromJson({
      'id': id,
      'kind': mediaKind.apiValue,
      'title': candidate.title,
      'synopsis': candidate.summary,
      'cover_image_url': candidate.imageUrl,
    });
  }

  Future<void> applyIngestCorrections({
    required ApiClient api,
    required BuildProviderCorrections providerMapper,
    required String kind,
    required String itemId,
    required LibraryAddCatalogTransport preview,
    required LibraryAddCatalogTransport edited,
  }) async {
    final corrections = providerMapper(
      preview: preview,
      edited: edited,
    );
    if (corrections.isEmpty) {
      return;
    }
    await applyProviderIngestCorrections(
      api: api,
      kind: kind,
      itemId: itemId,
      corrections: corrections,
      edited: edited,
    );
  }

  String describeMetadataProposalError(Object error) {
    if (error case DioException dioError) {
      final statusCode = dioError.response?.statusCode;
      if (statusCode != null) {
        return 'Couldn\'t send the metadata proposal. Server responded with $statusCode.';
      }
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        return 'Couldn\'t send the metadata proposal. The request timed out.';
      }
      return 'Couldn\'t send the metadata proposal right now. Try again.';
    }
    final text = error.toString().trim();
    if (text.startsWith('StateError: ')) {
      return text.substring('StateError: '.length);
    }
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    return 'Couldn\'t send the metadata proposal. $text';
  }
}
