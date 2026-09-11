import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_action_service.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_orchestration_service.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_bundle.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:flutter/material.dart';

typedef LibraryProviderCandidateSource = List<ProviderCandidate> Function();

typedef LibraryProviderEditLauncher = Future<LibraryEditSelection?> Function(
    LibraryEditDialogRequest request);

final class LibraryProviderAddDependencies {
  const LibraryProviderAddDependencies({
    required this.catalog,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    required this.physicalFormats,
    required this.previewState,
    required this.providerActionService,
    required this.providerOrchestrationService,
    required this.providerMapper,
    required this.visibleProviderResults,
    required this.showEditDialog,
    required this.closeEditDialog,
    required this.clearRejectedMetadataSession,
  });

  final CatalogTransportRepository catalog;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
  final List<PhysicalMediaFormat> physicalFormats;
  final LibraryAddPreviewController previewState;
  final LibraryProviderActionService providerActionService;
  final LibraryProviderOrchestrationService providerOrchestrationService;
  final BuildProviderCorrections providerMapper;
  final LibraryProviderCandidateSource visibleProviderResults;
  final LibraryProviderEditLauncher showEditDialog;
  final VoidCallback closeEditDialog;
  final Future<bool> Function(Object error, String action)
      clearRejectedMetadataSession;
}

final class LibraryProviderAddRequest {
  const LibraryProviderAddRequest({
    required this.api,
    required this.isAdmin,
    required this.type,
    required this.candidate,
    required this.target,
    required this.accent,
    required this.dependencies,
    this.referenceType = LibraryAddReferenceType.media,
    this.defaults = const LibraryAddDefaults(),
    this.reportError,
  });

  final ApiClient api;
  final bool isAdmin;
  final LibraryKindRegistration type;
  final ProviderCandidate candidate;
  final LibraryAddTarget target;
  final Color accent;
  final LibraryProviderAddDependencies dependencies;
  final LibraryAddReferenceType referenceType;
  final LibraryAddDefaults defaults;
  final void Function(String message)? reportError;
}
