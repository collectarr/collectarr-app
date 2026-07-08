import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/add/services/library_add_workflow_service.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:dio/dio.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';

class LibraryProviderOrchestrationService {
  const LibraryProviderOrchestrationService();

  static const _workflow = LibraryAddWorkflowService();

  LibraryMetadataItem proposalDraftFromCandidate({
    required LibraryTypeConfig type,
    required ProviderCandidate candidate,
  }) {
    return LibraryMetadataItem(
      id: _workflow.buildPreviewCatalogItemId(
        kind: type.workspace.kind.apiValue,
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
      ),
      kind: type.workspace.kind.apiValue,
      title: candidate.title,
      synopsis: candidate.summary,
      coverImageUrl: candidate.imageUrl,
      thumbnailImageUrl: candidate.imageUrl,
    );
  }

  Future<void> applyIngestCorrections({
    required ApiClient api,
    required LibraryKindProviderMapper providerMapper,
    required String kind,
    required String itemId,
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  }) async {
    final corrections = providerMapper.buildCorrections(
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
