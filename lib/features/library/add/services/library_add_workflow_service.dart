import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
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
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class LibraryAddWorkflowService {
  const LibraryAddWorkflowService();

  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    final mediaKind = catalogMediaKindFromApiValue(preview.kind);
    final id = buildPreviewCatalogItemId(
      kind: preview.kind,
      provider: preview.provider,
      providerItemId: preview.providerItemId,
    );
    return LibraryMetadataItem(
      identity: LibraryItemIdentity(
        id: id,
        mediaKind: mediaKind,
      ),
      common: LibraryCommonMetadata(
        title: preview.title,
        synopsis: preview.synopsis,
        coverImageUrl: preview.coverImageUrl,
        thumbnailImageUrl: preview.coverImageUrl,
        releaseDate: preview.releaseDate,
        releaseYear:
            preview.releaseDate?.year ?? preview.series?.volumeStartYear,
      ),
      kindMetadata: LibraryKindMetadataDecoders.decode(
        mediaKind,
        {
          'id': id,
          'kind': preview.kind,
          'title': preview.title,
          'item_number': preview.itemNumber,
          'synopsis': preview.synopsis,
          'cover_image_url': preview.coverImageUrl,
          'edition_title': preview.editionTitle,
          'physical_format': preview.physicalFormat,
          'physical_format_label': preview.physicalFormatLabel,
          'publisher': preview.publisher,
          'release_date': preview.releaseDate?.toIso8601String(),
          'barcode': preview.barcode,
          'variant': preview.variantName,
          'country': preview.country,
          'language': preview.language,
          'genres': preview.genres,
          'characters': preview.characters,
          'story_arcs': preview.storyArcs,
          if (preview.creators.isNotEmpty)
            'creators': [
              for (final c in preview.creators)
                {
                  'name': c.name,
                  if (c.role != null) 'role': c.role,
                  if (c.imageUrl != null) 'image_url': c.imageUrl,
                },
            ],
          if (preview.series != null)
            'series_title': preview.series!.seriesTitle,
          if (preview.publishing != null)
            'publishing': {
              'page_count': preview.publishing!.pageCount,
              'cover_price_cents': preview.publishing!.coverPriceCents,
              'imprint': preview.publishing!.imprint,
              'subtitle': preview.publishing!.subtitle,
              'series_group': preview.publishing!.seriesGroup,
            },
          if (preview.music != null) ...{
            'track_count': preview.music!.trackCount,
            if (preview.music!.tracks.isNotEmpty)
              'tracks': preview.music!.tracks.map((t) => t.toJson()).toList(),
            'music': {
              'track_count': preview.music!.trackCount,
              'catalog_number': preview.music!.catalogNumber,
              'release_status': preview.music!.releaseStatus,
              'rpm': preview.music!.rpm,
              'sound_type': preview.music!.soundType,
              'is_live': preview.music!.isLive,
              if (preview.music!.tracks.isNotEmpty)
                'tracks': preview.music!.tracks.map((t) => t.toJson()).toList(),
            },
          },
          if (preview.video != null)
            'video': {
              'runtime_minutes': preview.video!.runtimeMinutes,
              'color': preview.video!.color,
              'nr_discs': preview.video!.nrDiscs,
              'screen_ratio': preview.video!.screenRatio,
              'audio_tracks': preview.video!.audioTracks,
              'subtitles': preview.video!.subtitles,
              'layers': preview.video!.layers,
            },
          if (preview.game != null)
            'game': {
              'platforms': preview.game!.platforms,
              if (preview.game!.toySubtype != null)
                'toy_subtype': preview.game!.toySubtype,
              if (preview.game!.toyType != null)
                'toy_type': preview.game!.toyType,
            },
        },
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

  Future<LibraryMetadataItem> providerAddItemForCandidate({
    required ApiClient? api,
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
      return metadataItemFromPreview(cachedPreview);
    }
    return candidate.placeholderItem();
  }

  Future<void> addItems({
    required bool mounted,
    required bool isAdding,
    required void Function(VoidCallback fn) rebuild,
    required void Function(bool value) setIsAdding,
    required void Function(String? message) setError,
    required void Function(LibraryAddDialogResult result) onSuccess,
    required CatalogCacheRepository catalog,
    required OwnedItemMutations ownedMutations,
    required WishlistMutations wishlistMutations,
    required TrackingMutations trackingMutations,
    required Iterable<LibraryMetadataItem> items,
    required LibraryAddTarget target,
    LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
    LibraryAddDefaults defaults = const LibraryAddDefaults(),
    LibraryAddCommonDraft? commonDraft,
    Map<String, LibraryAddKindDraft> kindDraftsByItemId = const {},
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
        ownedMutations: ownedMutations,
        wishlistMutations: wishlistMutations,
        trackingMutations: trackingMutations,
        items: resolvedItems,
        target: target,
        referenceType: referenceType,
        defaults: defaults,
        commonDraft: commonDraft,
        kindDraftsByItemId: kindDraftsByItemId,
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
    required OwnedItemMutations ownedMutations,
    required WishlistMutations wishlistMutations,
    required TrackingMutations trackingMutations,
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
        ownedMutations: ownedMutations,
        wishlistMutations: wishlistMutations,
        trackingMutations: trackingMutations,
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
        final cached =
            previewState.providerPreviewFor(currentCandidate.localCatalogId);
        final previewItem = cached != null
            ? metadataItemFromPreview(cached)
            : currentCandidate.placeholderItem();

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
          ownedMutations: ownedMutations,
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
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
