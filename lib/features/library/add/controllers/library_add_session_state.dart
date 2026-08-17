import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_search_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_state.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_content_scope.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_unified.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
final class LibraryAddSessionState {
  const LibraryAddSessionState({
    required this.mode,
    required this.target,
    required this.search,
    required this.selection,
    required this.preview,
    required this.commonDraft,
    required this.manualDraft,
    required this.submitState,
    this.defaultCondition = 'Near Mint',
    this.defaultGrade = 'Ungraded',
    this.defaultPurchaseDate,
    this.defaultLocationId,
    this.defaultReadStatus,
    this.defaultTags,
    this.physicalFormatId,
    this.isAdding = false,
  });

  final LibraryAddDialogMode mode;
  final LibraryAddTarget target;
  final LibraryAddSearchState search;
  final LibraryAddSelectionState selection;
  final LibraryAddPreviewState preview;
  final LibraryAddCommonDraft commonDraft;
  final LibraryAddKindDraft manualDraft;
  final AsyncValue<void> submitState;
  final String defaultCondition;
  final String defaultGrade;
  final DateTime? defaultPurchaseDate;
  final String? defaultLocationId;
  final String? defaultReadStatus;
  final String? defaultTags;
  final String? physicalFormatId;
  final bool isAdding;

  LibraryMetadataItem? get selectedItem {
    if (!selection.showCoreResults) return null;
    if (!selection.showMediaResults && !selection.showReleaseResults) {
      return null;
    }
    final id = selection.selectedResultId;
    if (id == null) return null;
    final hydrated = preview.hydratedResultFor(id);
    if (hydrated != null) return hydrated;
    for (final item in search.results) {
      if (item.id == id) return item;
    }
    return null;
  }

  ProviderCandidate? get selectedCandidate {
    if (!selection.showProviderResults) return null;
    if (!selection.showMediaResults && !selection.showReleaseResults) {
      return null;
    }
    final id = selection.selectedProviderCandidateId;
    if (id == null) return null;
    for (final candidate in search.providerResults) {
      if (candidate.localCatalogId == id) return candidate;
    }
    return null;
  }

  BundleReleaseDetail? get selectedBundleReleaseDetail {
    final bundleReleaseId = selection.selectedBundleReleaseId;
    if (bundleReleaseId == null) return null;
    return preview.bundleReleaseDetailForId(bundleReleaseId);
  }

  AdminProviderPreview? get selectedCandidatePreview {
    final candidate = selectedCandidate;
    if (candidate == null) return null;
    return preview.providerPreviewFor(candidate.localCatalogId);
  }

  List<LibraryMetadataItem> visibleCoreResults(
    LibraryTypeConfig type, {
    required bool Function(String id) isOwnedCatalogItem,
  }) {
    if (!selection.showCoreResults) return const <LibraryMetadataItem>[];
    final isVideoKind = type.capabilities.wideDialog;
    return search.results.where((item) {
      if (isVideoKind &&
          !libraryAddMatchesContentScope(
            type: type,
            item: item,
            showSeriesResults: selection.showMediaResults,
            showSeasonResults: selection.showSeasonResults,
            showReleaseResults: selection.showReleaseResults,
          )) {
        return false;
      }
      if (selection.hideComicOwnedResults && isOwnedCatalogItem(item.id)) {
        return false;
      }
      if (selection.hideComicVariantResults) {
        final variantText = item.variant?.trim();
        if (variantText != null && variantText.isNotEmpty) {
          return false;
        }
      }
      return true;
    }).toList(growable: false);
  }

  List<ProviderCandidate> visibleProviderResults(LibraryTypeConfig type) {
    if (!selection.showProviderResults) return const <ProviderCandidate>[];
    final isVideoKind = type.capabilities.wideDialog;
    return search.providerResults.where((candidate) {
      if (isVideoKind) {
        final isRelease = !isSeriesCandidate(candidate);
        final matchesScope =
            (selection.showMediaResults && selection.showReleaseResults) ||
                (isRelease
                    ? selection.showReleaseResults
                    : selection.showMediaResults);
        if (!matchesScope) return false;
      }
      if (selection.hideComicVariantResults && candidate.isVariant) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  LibraryAddSessionState copyWith({
    LibraryAddDialogMode? mode,
    LibraryAddTarget? target,
    LibraryAddSearchState? search,
    LibraryAddSelectionState? selection,
    LibraryAddPreviewState? preview,
    LibraryAddCommonDraft? commonDraft,
    LibraryAddKindDraft? manualDraft,
    AsyncValue<void>? submitState,
    String? defaultCondition,
    String? defaultGrade,
    DateTime? defaultPurchaseDate,
    bool clearDefaultPurchaseDate = false,
    String? defaultLocationId,
    bool clearDefaultLocationId = false,
    String? defaultReadStatus,
    bool clearDefaultReadStatus = false,
    String? defaultTags,
    bool clearDefaultTags = false,
    String? physicalFormatId,
    bool clearPhysicalFormatId = false,
    bool? isAdding,
  }) {
    return LibraryAddSessionState(
      mode: mode ?? this.mode,
      target: target ?? this.target,
      search: search ?? this.search,
      selection: selection ?? this.selection,
      preview: preview ?? this.preview,
      commonDraft: commonDraft ?? this.commonDraft,
      manualDraft: manualDraft ?? this.manualDraft,
      submitState: submitState ?? this.submitState,
      defaultCondition: defaultCondition ?? this.defaultCondition,
      defaultGrade: defaultGrade ?? this.defaultGrade,
      defaultPurchaseDate: clearDefaultPurchaseDate
          ? null
          : (defaultPurchaseDate ?? this.defaultPurchaseDate),
      defaultLocationId: clearDefaultLocationId
          ? null
          : (defaultLocationId ?? this.defaultLocationId),
      defaultReadStatus: clearDefaultReadStatus
          ? null
          : (defaultReadStatus ?? this.defaultReadStatus),
      defaultTags: clearDefaultTags ? null : (defaultTags ?? this.defaultTags),
      physicalFormatId: clearPhysicalFormatId
          ? null
          : (physicalFormatId ?? this.physicalFormatId),
      isAdding: isAdding ?? this.isAdding,
    );
  }
}
