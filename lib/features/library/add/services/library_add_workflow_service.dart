import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_add_request.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/providers/transport/admin_metadata_add_projection.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:uuid/uuid.dart';

class LibraryAddWorkflowService {
  const LibraryAddWorkflowService();

  LibraryAddCatalogTransport metadataItemFromPreview(
    AdminProviderPreview preview, {
    String? itemId,
  }) {
    final mediaKind = catalogMediaKindFromApiValue(preview.kind);
    final id = itemId ??
        buildPreviewCatalogItemId(
          kind: preview.kind,
          provider: preview.provider,
          providerItemId: preview.providerItemId,
        );
    final mapper = libraryKindProviderMetadataMapperForKind(mediaKind);
    if (mapper == null) {
      throw StateError('No provider mapper registered for ${preview.kind}');
    }
    return LibraryAddCatalogTransport.fromItem(
      mapper(
        ProviderMetadataEnvelope.fromAdminPreview(
          preview,
          itemId: id,
        ),
      ),
    );
  }

  String buildPreviewCatalogItemId({
    required String kind,
    required String provider,
    required String providerItemId,
  }) {
    final previewKey = '$kind:$provider:$providerItemId';
    return 'preview-$kind-${const Uuid().v5(Namespace.url.value, previewKey)}';
  }

  Future<LibraryAddCatalogTransport> providerAddItemForCandidate({
    required LibraryKindModule type,
    required ProviderCandidate candidate,
    required LibraryAddPreviewController previewState,
  }) async {
    if (candidate.isStub) {
      return type.add.catalogTransportFromProviderCandidate(candidate);
    }
    final cachedPreview =
        previewState.providerPreviewFor(candidate.localCatalogId);
    if (cachedPreview != null) {
      return metadataItemFromPreview(cachedPreview,
          itemId: candidate.localCatalogId);
    }
    return type.add.catalogTransportFromProviderCandidate(candidate);
  }

  Future<void> addProviderCandidate(LibraryProviderAddRequest request) async {
    final dependencies = request.dependencies;
    final candidate = request.candidate;
    final target = request.target;
    final type = request.type;
    if (!request.isAdmin || candidate.isStub) {
      final previewItem = await providerAddItemForCandidate(
        type: type,
        candidate: candidate,
        previewState: dependencies.previewState,
      );
      await const LibraryAddCoordinator().add(
        LibraryAddBatchRequest(
          dependencies: LibraryAddMutationDependencies(
            catalog: dependencies.catalog,
            ownedMutations: dependencies.ownedMutations,
            wishlistMutations: dependencies.wishlistMutations,
            trackingMutations: dependencies.trackingMutations,
          ),
          items: [previewItem],
          target: target,
          referenceType: request.referenceType,
          defaults: request.defaults,
        ),
      );
      return;
    }

    var currentCandidate = candidate;
    try {
      while (true) {
        final cached = dependencies.previewState.providerPreviewFor(
          currentCandidate.localCatalogId,
        );
        final previewItem = cached != null
            ? metadataItemFromPreview(cached)
            : type.add.catalogTransportFromProviderCandidate(currentCandidate);

        final visibleCandidates = dependencies.visibleProviderResults();
        final currentIndex = visibleCandidates.indexWhere(
          (entry) => entry.localCatalogId == currentCandidate.localCatalogId,
        );
        ProviderCandidate? navigateCandidate;
        final result = await dependencies.showEditDialog(
          LibraryEditDialogRequest(
            type: type,
            item: previewItem,
            ownedItem: null,
            accent: request.accent,
            scope: LibraryEditScope.all,
            physicalFormats: dependencies.physicalFormats,
            onPrevious: currentIndex > 0
                ? () {
                    navigateCandidate = visibleCandidates[currentIndex - 1];
                    dependencies.closeEditDialog();
                  }
                : null,
            onNext:
                currentIndex >= 0 && currentIndex < visibleCandidates.length - 1
                    ? () {
                        navigateCandidate = visibleCandidates[currentIndex + 1];
                        dependencies.closeEditDialog();
                      }
                    : null,
          ),
        );
        if (navigateCandidate != null) {
          currentCandidate = navigateCandidate!;
          continue;
        }
        if (result == null) {
          return;
        }

        final ingest = await dependencies.providerActionService.ingestCandidate(
          api: request.api,
          candidate: currentCandidate,
        );

        final edited = result.item;
        final ingested = libraryAddCatalogItemFromIngestResult(ingest.item);
        await dependencies.providerOrchestrationService.applyIngestCorrections(
          api: request.api,
          providerMapper: dependencies.providerMapper,
          kind: ingested.mediaKind.apiValue,
          itemId: ingest.itemId,
          preview: previewItem,
          edited: edited,
        );

        final finalItem = mergeProviderAddResult(
          ingested: ingested,
          edited: edited,
        );
        await const LibraryAddCoordinator().add(
          LibraryAddBatchRequest(
            dependencies: LibraryAddMutationDependencies(
              catalog: dependencies.catalog,
              ownedMutations: dependencies.ownedMutations,
              wishlistMutations: dependencies.wishlistMutations,
              trackingMutations: dependencies.trackingMutations,
            ),
            items: [finalItem],
            target: target,
            referenceType: request.referenceType,
            defaults: request.defaults,
          ),
        );
        return;
      }
    } catch (error) {
      if (await dependencies.clearRejectedMetadataSession(
        error,
        'Provider ingest',
      )) {
        return;
      }
      request.reportError?.call(
        'Provider ingest failed: ${ConnectionDiagnostics.metadataError(error, request.api.baseUrl)}',
      );
    }
  }
}
