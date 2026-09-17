import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/services/library_add_workflow_service.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_add_request.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/providers/transport/admin_metadata_add_projection.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

/// Coordinates the provider-candidate branch of Add.
///
/// Preview decoding, provider ingest, edit-dialog navigation and collection
/// mutation are kept here because they form one application workflow. The
/// regular [LibraryAddWorkflowService] remains a small, pure preview/id
/// mapper and does not own UI lifecycle or mutation dependencies.
final class LibraryProviderAddCoordinator {
  const LibraryProviderAddCoordinator({
    this.workflow = const LibraryAddWorkflowService(),
  });

  final LibraryAddWorkflowService workflow;

  Future<CatalogSearchCandidate> providerAddItemForCandidate({
    required LibraryKindRegistration type,
    required ProviderSearchCandidate candidate,
    required LibraryAddPreviewController previewState,
  }) async {
    final effectiveCandidate =
        previewState.typedProviderCandidateFor(candidate.localCatalogId) ??
            candidate;
    if (effectiveCandidate.isStub) {
      return libraryAddForKind(type.kind)
          .catalogCandidateFromProviderCandidate(effectiveCandidate);
    }
    final cachedPreview =
        previewState.providerPreviewFor(candidate.localCatalogId);
    if (cachedPreview != null) {
      return workflow.metadataItemFromPreview(
        cachedPreview,
        itemId: candidate.localCatalogId,
      );
    }
    return libraryAddForKind(type.kind)
        .catalogCandidateFromProviderCandidate(effectiveCandidate);
  }

  Future<void> addProviderCandidate(LibraryProviderAddRequest request) async {
    final dependencies = request.dependencies;
    final candidate = request.candidate;
    final target = request.target;
    final type = request.type;
    if (candidate.previewOnly) {
      request.reportError?.call(
        'Select a concrete child result before adding this group.',
      );
      return;
    }
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
        final effectiveCandidate = dependencies.previewState
                .typedProviderCandidateFor(currentCandidate.localCatalogId) ??
            currentCandidate;
        final cached = dependencies.previewState.providerPreviewFor(
          effectiveCandidate.localCatalogId,
        );
        final previewItem = cached != null
            ? workflow.metadataItemFromPreview(cached)
            : libraryAddForKind(type.kind)
                .catalogCandidateFromProviderCandidate(effectiveCandidate);

        final visibleCandidates = dependencies.visibleProviderResults();
        final currentIndex = visibleCandidates.indexWhere(
          (entry) => entry.localCatalogId == currentCandidate.localCatalogId,
        );
        ProviderSearchCandidate? navigateCandidate;
        final result = await dependencies.showEditDialog(
          LibraryEditDialogRequest(
            type: type,
            item: previewItem,
            ownedItem: null,
            accent: request.accent,
            scope: null,
            physicalFormats: dependencies.physicalFormats,
            onPrevious: request.allowNavigation && currentIndex > 0
                ? () {
                    navigateCandidate = visibleCandidates[currentIndex - 1];
                    dependencies.closeEditDialog();
                  }
                : null,
            onNext: request.allowNavigation &&
                    currentIndex >= 0 &&
                    currentIndex < visibleCandidates.length - 1
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
          candidate: effectiveCandidate,
        );

        final edited = result.kindItem;
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

  Future<void> addProviderCandidates(
    LibraryProviderAddRequest request,
    Iterable<ProviderSearchCandidate> candidates,
  ) async {
    for (final candidate in candidates) {
      await addProviderCandidate(
        request.copyWith(candidate: candidate, allowNavigation: false),
      );
    }
  }
}
