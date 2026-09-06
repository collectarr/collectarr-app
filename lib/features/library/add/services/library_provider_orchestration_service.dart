import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/add/services/library_add_workflow_service.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:dio/dio.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';

typedef BuildProviderCorrections = Map<String, Object?> Function({
  required CatalogItem preview,
  required CatalogItem edited,
});

class LibraryProviderOrchestrationService {
  const LibraryProviderOrchestrationService();

  static const _workflow = LibraryAddWorkflowService();

  CatalogItem proposalDraftFromCandidate({
    required LibraryKindRuntime type,
    required ProviderCandidate candidate,
  }) {
    final mediaKind = type.kind;
    final id = _workflow.buildPreviewCatalogItemId(
      kind: mediaKind.apiValue,
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
    );
    return CatalogItem.fromJson({
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
    required CatalogItem preview,
    required CatalogItem edited,
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
