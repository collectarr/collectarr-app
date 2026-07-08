import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_action_service.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_orchestration_service.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:flutter/material.dart';

class LibraryAddProposalFlowService {
  const LibraryAddProposalFlowService();

  Future<void> proposeCandidate({
    required BuildContext context,
    required ApiClient api,
    required LibraryTypeConfig type,
    required ProviderCandidate candidate,
    required LibraryProviderActionService providerActionService,
    required LibraryProviderOrchestrationService orchestrationService,
    required bool mounted,
    required bool isAdding,
    required void Function(VoidCallback fn) rebuild,
    required void Function(bool value) setIsAdding,
    required void Function(String? message) setError,
    required List<ProviderCandidate> Function() visibleProviderResults,
    required List<PhysicalMediaFormat> Function() currentPhysicalFormats,
    required Future<LibraryEditSelection?> Function(
      BuildContext context,
      LibraryEditDialogRequest request,
    ) showEditDialog,
  }) async {
    if (isAdding) {
      return;
    }
    var currentCandidate = candidate;
    LibraryEditSelection? result;
    while (mounted) {
      final visibleCandidates = visibleProviderResults();
      final currentIndex = visibleCandidates.indexWhere(
        (entry) => entry.localCatalogId == currentCandidate.localCatalogId,
      );
      ProviderCandidate? navigateCandidate;
      result = await showEditDialog(
        context,
        LibraryEditDialogRequest(
          type: type,
          item: orchestrationService.proposalDraftFromCandidate(
            type: type,
            candidate: currentCandidate,
          ),
          ownedItem: null,
          accent: LibraryAccentScope.accentOf(context),
          physicalFormats: currentPhysicalFormats(),
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
      break;
    }
    if (result == null || !mounted) {
      return;
    }
    rebuild(() {
      setIsAdding(true);
      setError(null);
    });
    try {
      final proposalItem = result.item;
      await providerActionService.proposeMetadata(
        api: api,
        type: type,
        candidate: currentCandidate,
        proposalItem: proposalItem,
      );
      if (!mounted || !context.mounted) {
        return;
      }
      showAppToast(
        context,
        '${type.singularLabel} metadata proposal sent for review.',
        tone: AppToastTone.success,
      );
      Navigator.of(context).pop(
        LibraryAddDialogResult(
          target: LibraryAddTarget.track,
          itemIds: [result.item.id],
        ),
      );
    } catch (error) {
      if (mounted && context.mounted) {
        showAppToast(
          context,
          orchestrationService.describeMetadataProposalError(error),
          tone: AppToastTone.error,
        );
      }
    } finally {
      if (mounted) {
        rebuild(() => setIsAdding(false));
      }
    }
  }
}
