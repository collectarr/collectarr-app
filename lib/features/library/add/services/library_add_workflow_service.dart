import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_action_service.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_orchestration_service.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class LibraryAddWorkflowService {
  const LibraryAddWorkflowService();

  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    final series = preview.series;
    final publishing = preview.publishing;
    final music = preview.music;
    final video = preview.video;
    final game = preview.game;
    return LibraryMetadataItem(
      id: buildPreviewCatalogItemId(
        kind: preview.kind,
        provider: preview.provider,
        providerItemId: preview.providerItemId,
      ),
      kind: preview.kind,
      title: preview.title,
      itemNumber: preview.itemNumber,
      synopsis: preview.synopsis,
      coverImageUrl: preview.coverImageUrl,
      thumbnailImageUrl: preview.coverImageUrl,
      editionTitle: preview.editionTitle,
      physicalFormat: preview.physicalFormat,
      physicalFormatLabel: preview.physicalFormatLabel,
      publisher: preview.publisher,
      releaseDate: preview.releaseDate,
      releaseYear: preview.releaseDate?.year ?? preview.series?.volumeStartYear,
      barcode: preview.barcode,
      variant: preview.variantName,
      series: series,
      publishing: publishing,
      music: music,
      video: video,
      game: game,
      country: preview.country,
      language: preview.language,
      ageRating: preview.ageRating,
      audienceRating: preview.audienceRating,
      creators: [
        for (final creator in preview.creators)
          {
            'name': creator.name,
            if (creator.role != null) 'role': creator.role,
            if (creator.imageUrl != null) 'image_url': creator.imageUrl,
          },
      ],
      characters: preview.characters,
      storyArcs: preview.storyArcs,
      genres: preview.genres,
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

  Future<LibraryMetadataItem> providerAddItemForCandidate({
    required ApiClient api,
    required ProviderCandidate candidate,
    required bool mounted,
    required void Function(VoidCallback fn) rebuild,
    required LibraryAddPreviewController previewState,
    required void Function(String? message) setError,
    required bool Function(Object error) isMissingBearerTokenError,
  }) async {
    if (candidate.isStub) {
      return candidate.placeholderItem();
    }
    final cachedPreview =
        previewState.providerPreviewFor(candidate.localCatalogId);
    if (cachedPreview != null) {
      return metadataItemFromPreview(cachedPreview).copyWith(
        id: buildPreviewCatalogItemId(
          kind: cachedPreview.kind,
          provider: cachedPreview.provider,
          providerItemId: cachedPreview.providerItemId,
        ),
      );
    }
    try {
      final preview = await api.providerPreview(
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
      );
      if (mounted) {
        rebuild(() {
          previewState.setProviderPreview(candidate.localCatalogId, preview);
        });
      }
      return metadataItemFromPreview(preview).copyWith(
        id: buildPreviewCatalogItemId(
          kind: preview.kind,
          provider: preview.provider,
          providerItemId: preview.providerItemId,
        ),
      );
    } catch (error) {
      if (mounted && isMissingBearerTokenError(error)) {
        rebuild(
          () => setError(
            'Provider preview needs authentication. Adding basic provider metadata only.',
          ),
        );
        return candidate.placeholderItem();
      }
      rethrow;
    }
  }

  Future<void> addItems({
    required bool mounted,
    required bool isAdding,
    required void Function(VoidCallback fn) rebuild,
    required void Function(bool value) setIsAdding,
    required void Function(String? message) setError,
    required void Function(LibraryAddDialogResult result) onSuccess,
    required CatalogCacheRepository catalog,
    required CollectionMutations mutations,
    required Iterable<LibraryMetadataItem> items,
    required LibraryAddTarget target,
    LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
    LibraryAddDefaults defaults = const LibraryAddDefaults(),
    Map<String, LibraryAddOwnedDetails> ownedDetailsByItemId = const {},
    Map<String, LibraryAddEditionSelection> editionSelectionsByItemId =
        const {},
    Map<String, String> bundleReleaseIdsByItemId = const {},
  }) async {
    final resolvedItems = items.toList(growable: false);
    if (resolvedItems.isEmpty || isAdding) {
      return;
    }
    rebuild(() {
      setIsAdding(true);
      setError(null);
    });
    try {
      await addLibraryItemsToTarget(
        catalog: catalog,
        mutations: mutations,
        items: resolvedItems,
        target: target,
        referenceType: referenceType,
        defaults: defaults,
        ownedDetailsByItemId: ownedDetailsByItemId,
        editionSelectionsByItemId: editionSelectionsByItemId,
        bundleReleaseIdsByItemId: bundleReleaseIdsByItemId,
      );
      if (mounted) {
        onSuccess(
          LibraryAddDialogResult(
            target: target,
            itemIds: [for (final item in resolvedItems) item.id],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        rebuild(() => setError('Add failed: $error'));
      }
    } finally {
      if (mounted) {
        rebuild(() => setIsAdding(false));
      }
    }
  }

  Future<void> addProviderCandidate({
    required BuildContext context,
    required ApiClient api,
    required bool isAdmin,
    required LibraryTypeConfig type,
    required ProviderCandidate candidate,
    required LibraryAddTarget target,
    required bool mounted,
    required bool isAdding,
    required void Function(VoidCallback fn) rebuild,
    required void Function(bool value) setIsAdding,
    required void Function(String? message) setError,
    required void Function(LibraryAddDialogResult result) onSuccess,
    required bool Function(Object error) isMissingBearerTokenError,
    required CatalogCacheRepository catalog,
    required CollectionMutations mutations,
    required List<PhysicalMediaFormat> physicalFormats,
    required LibraryAddPreviewController previewState,
    required LibraryProviderActionService providerActionService,
    required LibraryProviderOrchestrationService providerOrchestrationService,
    required BuildProviderCorrections providerMapper,
    required List<ProviderCandidate> Function() visibleProviderResults,
    required Future<LibraryEditSelection?> Function(
      BuildContext context,
      LibraryEditDialogRequest request,
    ) showEditDialog,
    required Future<bool> Function(Object error, String action)
        clearRejectedMetadataSession,
    LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
    LibraryAddDefaults defaults = const LibraryAddDefaults(),
  }) async {
    if (!isAdmin || candidate.isStub) {
      final previewItem = await providerAddItemForCandidate(
        api: api,
        candidate: candidate,
        mounted: mounted,
        rebuild: rebuild,
        previewState: previewState,
        setError: setError,
        isMissingBearerTokenError: isMissingBearerTokenError,
      );
      await addItems(
        mounted: mounted,
        isAdding: isAdding,
        rebuild: rebuild,
        setIsAdding: setIsAdding,
        setError: setError,
        onSuccess: onSuccess,
        catalog: catalog,
        mutations: mutations,
        items: [previewItem],
        target: target,
        referenceType: referenceType,
        defaults: defaults,
      );
      return;
    }

    var currentCandidate = candidate;
    try {
      while (mounted) {
        final preview = await providerActionService.fetchPreview(
          api: api,
          candidate: currentCandidate,
        );
        if (!mounted) {
          return;
        }

        final previewItem = metadataItemFromPreview(preview).copyWith(
          id: buildPreviewCatalogItemId(
            kind: preview.kind,
            provider: preview.provider,
            providerItemId: preview.providerItemId,
          ),
        );

        final visibleCandidates = visibleProviderResults();
        final currentIndex = visibleCandidates.indexWhere(
          (entry) => entry.localCatalogId == currentCandidate.localCatalogId,
        );
        ProviderCandidate? navigateCandidate;
        if (!context.mounted) {
          return;
        }
        final accent = LibraryAccentScope.accentOf(context);
        final result = await showEditDialog(
          context,
          LibraryEditDialogRequest(
            type: type,
            item: previewItem,
            ownedItem: null,
            accent: accent,
            scope: LibraryEditScope.all,
            physicalFormats: physicalFormats,
            onPrevious: currentIndex > 0
                ? () {
                    navigateCandidate = visibleCandidates[currentIndex - 1];
                    Navigator.of(context).pop();
                  }
                : null,
            onNext:
                currentIndex >= 0 && currentIndex < visibleCandidates.length - 1
                    ? () {
                        navigateCandidate = visibleCandidates[currentIndex + 1];
                        Navigator.of(context).pop();
                      }
                    : null,
          ),
        );
        if (!mounted) {
          return;
        }
        if (navigateCandidate != null) {
          currentCandidate = navigateCandidate!;
          continue;
        }
        if (result == null) {
          return;
        }

        final ingest = await providerActionService.ingestCandidate(
          api: api,
          candidate: currentCandidate,
        );

        final edited = result.item;
        final ingested = metadataItemFromIngestResult(ingest.item);
        if (mounted) {
          await providerOrchestrationService.applyIngestCorrections(
            api: api,
            providerMapper: providerMapper,
            kind: ingested.kind,
            itemId: ingest.itemId,
            preview: previewItem,
            edited: edited,
          );
        }

        final finalItem = mergeProviderAddResult(
          ingested: ingested,
          edited: edited,
        );
        await addItems(
          mounted: mounted,
          isAdding: isAdding,
          rebuild: rebuild,
          setIsAdding: setIsAdding,
          setError: setError,
          onSuccess: onSuccess,
          catalog: catalog,
          mutations: mutations,
          items: [finalItem],
          target: target,
          referenceType: referenceType,
          defaults: defaults,
        );
        return;
      }
    } catch (error) {
      if (mounted &&
          await clearRejectedMetadataSession(error, 'Provider ingest')) {
        return;
      }
      if (mounted) {
        rebuild(
          () => setError(
            'Provider ingest failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)}',
          ),
        );
      }
    }
  }
}
