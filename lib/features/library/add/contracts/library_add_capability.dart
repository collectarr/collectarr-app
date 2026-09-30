import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_unsupported_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:flutter/widgets.dart';

export 'library_add_result_policy.dart';

typedef LibraryAddAdvancedFilterDescriptorsBuilder
    = List<LibraryAddAdvancedFilterField<String>> Function(
  LibraryAddModeBarRequest request,
);

typedef LibraryAddCoreSearchInputBuilder = MetadataSearchQuery Function(
  LibraryAddSearchContext context, {
  required int limit,
});

typedef LibraryAddCoreSearchResultFilter = List<CatalogSearchCandidate>
    Function(
  List<CatalogSearchCandidate> items,
  LibraryAddSearchContext context,
);

typedef LibraryAddMatchSummaryBuilder<T> = String? Function(
  T candidate,
  LibraryAddSearchContext context,
);

typedef LibraryAddOwnedPayloadBuilder<TDraft extends LibraryAddKindDraft>
    = OwnedItemCreatePayload Function(
  CatalogSearchCandidate item,
  LibraryAddCommonDraft common,
  TDraft draft,
  JsonEncodable details, {
  String? kindValue,
});

typedef LibraryAddDigitalCopyFlagBuilder = bool? Function(
  CatalogSearchCandidate item,
);

typedef LibraryAddManualCandidateBuilder = CatalogSearchCandidate? Function(
  LibraryKindAddDraft draft, {
  required String title,
});

typedef LibraryAddManualProposalBuilder = Map<String, Object?>? Function(
  LibraryKindAddDraft draft, {
  required String title,
});

typedef LibraryAddCoreCatalogProjection = CatalogSearchCandidate Function(
  CatalogSearchCandidate item,
);

class LibraryAddSearchCapability {
  const LibraryAddSearchCapability({
    required this.input,
    required this.core,
    this.coverScan,
    this.presentation = const LibraryAddSearchPresentationCapability(),
  });

  final LibraryAddSearchInputCapability input;
  final LibraryAddCoreSearchCapability core;
  final LibraryAddCoverScanCapability? coverScan;
  final LibraryAddSearchPresentationCapability presentation;
}

class LibraryAddSearchInputCapability {
  const LibraryAddSearchInputCapability({
    this.initialAdvancedFilters = const {},
    required this.advancedFilterDescriptorsBuilder,
    this.searchInputPredicate,
  });

  final Map<LibraryAddFilterId, LibraryAddFilterValue> initialAdvancedFilters;
  final LibraryAddAdvancedFilterDescriptorsBuilder
      advancedFilterDescriptorsBuilder;
  final LibraryAddSearchInputPredicate? searchInputPredicate;

  bool hasSearchInput(LibraryAddSearchContext context) =>
      searchInputPredicate?.call(context) ?? context.hasAnyInput;
}

typedef LibraryAddSearchInputPredicate = bool Function(
  LibraryAddSearchContext context,
);

class LibraryAddCoreSearchCapability {
  const LibraryAddCoreSearchCapability({
    required this.inputBuilder,
    required this.ranking,
    this.resultFilter,
  });

  final LibraryAddCoreSearchInputBuilder inputBuilder;
  final LibraryAddSearchRanking ranking;
  final LibraryAddCoreSearchResultFilter? resultFilter;

  List<CatalogSearchCandidate> filterResults(
    List<CatalogSearchCandidate> items,
    LibraryAddSearchContext context,
  ) =>
      resultFilter?.call(items, context) ?? items;
}

class LibraryAddCoverScanCapability {
  const LibraryAddCoverScanCapability({
    this.queryBuilder,
    this.filterValuesBuilder,
  });

  final String? Function(LibraryCoverScanResult result)? queryBuilder;
  final Map<LibraryAddFilterId, LibraryAddFilterValue> Function(
    LibraryCoverScanResult result,
  )? filterValuesBuilder;

  String? searchQuery(LibraryCoverScanResult result) =>
      queryBuilder?.call(result) ?? result.query;

  Map<LibraryAddFilterId, LibraryAddFilterValue> filterValues(
    LibraryCoverScanResult result,
  ) =>
      filterValuesBuilder?.call(result) ?? const {};
}

class LibraryAddSearchPresentationCapability {
  const LibraryAddSearchPresentationCapability({
    this.controlsBuilder,
    this.coreMatchSummaryBuilder,
  });

  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      controlsBuilder;
  final LibraryAddMatchSummaryBuilder<CatalogSearchCandidate>?
      coreMatchSummaryBuilder;

  String? coreMatchSummary(
    CatalogSearchCandidate item,
    LibraryAddSearchContext context,
  ) {
    final custom = coreMatchSummaryBuilder?.call(item, context);
    if (custom != null) return custom;
    final label = item.summary.primaryLabel.trim().toLowerCase();
    final query = context.query.trim().toLowerCase();
    return label.isNotEmpty && query.isNotEmpty && label.contains(query)
        ? 'Title'
        : null;
  }
}

abstract interface class LibraryAddCapability<
    TDraft extends LibraryAddKindDraft> {
  CatalogMediaKind get kind;

  TDraft createInitialDraft();
  LibraryKindAddDraft createManualDraft();

  /// Kind-owned validation copy for a manual candidate that could not be
  /// created. The generic host renders this value but never infers a kind
  /// name or entity terminology itself.
  String get manualCandidateValidationMessage =>
      'The manual entry is incomplete or contains invalid values.';

  CatalogSearchCandidate? buildManualCandidate(
    LibraryKindAddDraft draft, {
    required String title,
  }) =>
      null;

  Map<String, Object?>? buildManualProposalData(
    LibraryKindAddDraft draft, {
    required String title,
  }) =>
      null;

  Widget buildManualPane(
    BuildContext context,
    LibraryAddManualPaneRequest request,
  );

  LibraryAddHeaderBuilder? get headerBuilder;
  LibraryAddModeBarBuilder? get modeBarBuilder;
  LibraryAddPreviewPaneBuilder? get previewPaneBuilder;
  LibraryAddSearchPaneBuilder? get searchPaneBuilder;
  LibraryAddBottomBarPresentation get bottomBarPresentation;
  LibraryAddChromeConfig get chrome;
  LibraryAddSearchCapability get search;
  LibraryAddResultPolicy get resultPolicy;

  CatalogSearchCandidate catalogCandidateFromCoreItem(
    CatalogSearchCandidate item,
  );

  bool? digitalCopyFlag(CatalogSearchCandidate item) => null;

  Widget? buildPreviewPane(
    BuildContext context,
    LibraryAddPreviewPaneRequest request,
  );

  AddOwnedItemCommand buildCommand(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft, {
    CatalogEntityRef? targetRef,
    LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft(),
  });

  AddOwnedItemCommand buildCommandFromDetails(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    JsonEncodable details, {
    LibraryAddKindDraft? draft,
    CatalogEntityRef? targetRef,
    LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft(),
    String? kindValue,
  });
}

class _EmptyKindAddDraft implements LibraryKindAddDraft {
  const _EmptyKindAddDraft();
  @override
  void dispose() {}
}

class StandardLibraryAddCapability<TDraft extends LibraryAddKindDraft>
    implements LibraryAddCapability<TDraft> {
  const StandardLibraryAddCapability({
    required this.kind,
    required this.initialDraftBuilder,
    this.manualDraftBuilder,
    this.manualCandidateBuilder,
    this.manualProposalBuilder,
    this.manualCandidateValidationMessage =
        'The manual entry is incomplete or contains invalid values.',
    this.manualPaneBuilder,
    this.headerBuilder,
    this.modeBarBuilder,
    this.previewPaneBuilder,
    this.searchPaneBuilder,
    this.bottomBarPresentation = LibraryAddBottomBarPresentation.responsiveMenu,
    this.chrome = const LibraryAddChromeConfig(),
    required this.search,
    this.ownedPayloadBuilder,
    this.digitalCopyFlagBuilder,
    required this.coreCatalogProjectionBuilder,
    this.resultPolicy = const LibraryAddResultPolicy.identity(),
  });

  @override
  final CatalogMediaKind kind;
  final TDraft Function() initialDraftBuilder;
  final LibraryKindAddDraft Function()? manualDraftBuilder;
  final LibraryAddManualCandidateBuilder? manualCandidateBuilder;
  final LibraryAddManualProposalBuilder? manualProposalBuilder;
  final Widget Function(
    BuildContext context,
    LibraryAddManualPaneRequest request,
  )? manualPaneBuilder;
  @override
  final LibraryAddHeaderBuilder? headerBuilder;
  @override
  final LibraryAddModeBarBuilder? modeBarBuilder;
  @override
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
  @override
  final LibraryAddSearchPaneBuilder? searchPaneBuilder;
  @override
  final LibraryAddBottomBarPresentation bottomBarPresentation;
  @override
  final LibraryAddChromeConfig chrome;
  @override
  final LibraryAddSearchCapability search;
  final LibraryAddOwnedPayloadBuilder<TDraft>? ownedPayloadBuilder;
  final LibraryAddDigitalCopyFlagBuilder? digitalCopyFlagBuilder;
  final LibraryAddCoreCatalogProjection coreCatalogProjectionBuilder;
  @override
  final LibraryAddResultPolicy resultPolicy;

  @override
  final String manualCandidateValidationMessage;

  @override
  TDraft createInitialDraft() => initialDraftBuilder();

  @override
  bool? digitalCopyFlag(CatalogSearchCandidate item) =>
      digitalCopyFlagBuilder?.call(item);

  @override
  CatalogSearchCandidate catalogCandidateFromCoreItem(
    CatalogSearchCandidate item,
  ) =>
      coreCatalogProjectionBuilder(item);

  @override
  LibraryKindAddDraft createManualDraft() =>
      manualDraftBuilder?.call() ?? const _EmptyKindAddDraft();

  @override
  CatalogSearchCandidate? buildManualCandidate(
    LibraryKindAddDraft draft, {
    required String title,
  }) =>
      manualCandidateBuilder?.call(draft, title: title);

  @override
  Map<String, Object?>? buildManualProposalData(
    LibraryKindAddDraft draft, {
    required String title,
  }) =>
      manualProposalBuilder?.call(draft, title: title);

  @override
  Widget buildManualPane(
    BuildContext context,
    LibraryAddManualPaneRequest request,
  ) =>
      manualPaneBuilder?.call(context, request) ??
      LibraryAddUnsupportedManualPane(request: request);

  @override
  Widget? buildPreviewPane(
    BuildContext context,
    LibraryAddPreviewPaneRequest request,
  ) =>
      previewPaneBuilder?.call(context, request);

  TDraft _resolveDraft(
    LibraryAddKindDraft? draft, {
    required String operation,
  }) {
    if (draft == null) return createInitialDraft();
    if (draft is TDraft) return draft;
    throw StateError(
      'Cannot $operation for kind ${kind.apiValue}: expected a $TDraft draft, '
      'but received ${draft.runtimeType}. The supplied draft was not replaced.',
    );
  }

  OwnedItemCreatePayload _buildOwnedPayload(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    TDraft draft,
    JsonEncodable details, {
    String? kindValue,
  }) {
    try {
      final payload = ownedPayloadBuilder?.call(
        item,
        common,
        draft,
        details,
        kindValue: kindValue,
      );
      if (payload == null) {
        throw StateError(
          'Kind ${kind.apiValue} must provide an owned create payload.',
        );
      }
      return payload;
    } on TypeError catch (error) {
      throw StateError(
        'Kind ${kind.apiValue} received details owned by another kind: '
        '$error',
      );
    }
  }

  @override
  AddOwnedItemCommand buildCommand(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft, {
    CatalogEntityRef? targetRef,
    LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft(),
  }) {
    final effectiveDraft = _resolveDraft(
      draft,
      operation: 'build an add command',
    );
    final details = effectiveDraft.toOwnedDetailsDraft();
    final typedPayload = _buildOwnedPayload(
      item,
      common,
      effectiveDraft,
      details,
    );
    return AddOwnedItemCommand(
      catalogRef: item.reference,
      typedPayload: typedPayload,
      targetRef: targetRef ?? item.reference,
      tracking: OwnedItemTrackingDraft(
        status: mediaTrackingStatusFromValue(tracking.readStatus),
        rating: tracking.rating,
        startedAt: tracking.startedAt,
        finishedAt: tracking.finishedAt,
        notes: tracking.notes,
      ),
    );
  }

  @override
  AddOwnedItemCommand buildCommandFromDetails(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    JsonEncodable details, {
    LibraryAddKindDraft? draft,
    CatalogEntityRef? targetRef,
    LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft(),
    String? kindValue,
  }) {
    final effectiveDraft = _resolveDraft(
      draft,
      operation: 'build an add command from details',
    );
    final typedPayload = _buildOwnedPayload(
      item,
      common,
      effectiveDraft,
      details,
      kindValue: kindValue,
    );
    return AddOwnedItemCommand(
      catalogRef: item.reference,
      typedPayload: typedPayload,
      targetRef: targetRef ?? item.reference,
      tracking: OwnedItemTrackingDraft(
        status: mediaTrackingStatusFromValue(tracking.readStatus),
        rating: tracking.rating,
        startedAt: tracking.startedAt,
        finishedAt: tracking.finishedAt,
        notes: tracking.notes,
      ),
    );
  }
}
