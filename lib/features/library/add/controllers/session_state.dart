import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/add/controllers/preview_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/search_state.dart';
import 'package:collectarr_app/features/library/add/controllers/selection_state.dart';
import 'package:collectarr_app/features/library/add/controllers/browse_state.dart';
import 'package:collectarr_app/features/library/add/contracts/result_policy.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:collectarr_app/features/library/add/models/common_draft.dart';
import 'package:collectarr_app/features/library/add/models/kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/target.dart';
import 'package:collectarr_app/features/library/add/models/tracking_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
final class LibraryAddSessionState {
  const LibraryAddSessionState({
    required this.mode,
    this.kindTab = 0,
    required this.target,
    required this.search,
    this.browse = const LibraryAddBrowseState(),
    required this.selection,
    required this.preview,
    required this.commonDraft,
    required this.trackingDraft,
    required this.manualDraft,
    required this.submitState,
    required this.defaultCondition,
    this.defaultPurchaseDate,
    this.defaultLocationId,
    this.defaultReadStatus,
    this.defaultTags,
    this.physicalFormatId,
    this.isAdding = false,
  });

  final LibraryAddDialogMode mode;

  /// Which of the kind's own tabs is open while [mode] is a kind tab.
  final int kindTab;
  final LibraryAddTarget target;
  final LibraryAddSearchState search;
  final LibraryAddBrowseState browse;
  final LibraryAddSelectionState selection;
  final LibraryAddPreviewState preview;
  final LibraryAddCommonDraft commonDraft;
  final LibraryAddTrackingDraft trackingDraft;
  final LibraryAddKindDraft manualDraft;
  final AsyncValue<void> submitState;
  final String defaultCondition;
  final DateTime? defaultPurchaseDate;
  final String? defaultLocationId;
  final String? defaultReadStatus;
  final List<String>? defaultTags;
  final String? physicalFormatId;
  final bool isAdding;

  CatalogSearchCandidate? get selectedItem {
    final id = selection.selectedResultId;
    if (id == null) return null;
    for (final item in search.results) {
      if (item.reference.id != id) continue;
      return preview.hydratedResultFor(item.reference) ?? item;
    }
    return null;
  }

  List<CatalogSearchCandidate> visibleCoreResults(
    LibraryAddResultPolicy policy, {
    required bool Function(CatalogSearchCandidate item) isEntryCatalogItem,
  }) {
    final libraryEntryRefs = <CatalogItemRef>{
      for (final item in search.results)
        if (isEntryCatalogItem(item)) item.reference,
    };
    return policy.filterCoreResults(
      items: search.results,
      state: selection.resultPolicyState,
      entryCatalogRefs: libraryEntryRefs,
    );
  }

  LibraryAddSessionState copyWith({
    LibraryAddDialogMode? mode,
    int? kindTab,
    LibraryAddTarget? target,
    LibraryAddSearchState? search,
    LibraryAddBrowseState? browse,
    LibraryAddSelectionState? selection,
    LibraryAddPreviewState? preview,
    LibraryAddCommonDraft? commonDraft,
    LibraryAddTrackingDraft? trackingDraft,
    LibraryAddKindDraft? manualDraft,
    AsyncValue<void>? submitState,
    String? defaultCondition,
    DateTime? defaultPurchaseDate,
    bool clearDefaultPurchaseDate = false,
    String? defaultLocationId,
    bool clearDefaultLocationId = false,
    String? defaultReadStatus,
    bool clearDefaultReadStatus = false,
    List<String>? defaultTags,
    bool clearDefaultTags = false,
    String? physicalFormatId,
    bool clearPhysicalFormatId = false,
    bool? isAdding,
  }) {
    return LibraryAddSessionState(
      mode: mode ?? this.mode,
      kindTab: kindTab ?? this.kindTab,
      target: target ?? this.target,
      search: search ?? this.search,
      browse: browse ?? this.browse,
      selection: selection ?? this.selection,
      preview: preview ?? this.preview,
      commonDraft: commonDraft ?? this.commonDraft,
      trackingDraft: trackingDraft ?? this.trackingDraft,
      manualDraft: manualDraft ?? this.manualDraft,
      submitState: submitState ?? this.submitState,
      defaultCondition: defaultCondition ?? this.defaultCondition,
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
