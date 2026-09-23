import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_unsupported_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/runtime/provider_runtime.dart';
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

typedef LibraryAddProviderQueryBuilder = String Function(
  LibraryAddSearchContext context,
);

typedef LibraryAddProviderKindOverridesBuilder = Iterable<LibraryAddSearchScope>
    Function(
  LibraryAddSearchContext context,
);

typedef LibraryAddCoreSearchResultFilter = List<CatalogSearchCandidate>
    Function(
  List<CatalogSearchCandidate> items,
  LibraryAddSearchContext context,
);

typedef LibraryAddTypedProviderSearchBuilder
    = Future<List<ProviderSearchCandidate>> Function(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  required int limit,
  ProviderCancellationToken? cancellationToken,
});

typedef LibraryAddTypedProviderSearchContextBuilder
    = Future<List<ProviderSearchCandidate>> Function(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  required int limit,
  required LibraryAddSearchContext context,
  ProviderCancellationToken? cancellationToken,
});

typedef LibraryAddTypedProviderSearchResultFilter
    = List<ProviderSearchCandidate> Function(
  List<ProviderSearchCandidate> candidates,
  LibraryAddSearchContext context,
);

@immutable
class LibraryAddProviderCandidatePreview {
  const LibraryAddProviderCandidatePreview({
    required this.candidate,
    required this.preview,
  });

  final ProviderSearchCandidate candidate;
  final AdminProviderPreview preview;
}

typedef LibraryAddTypedProviderCandidatePreviewLoader
    = Future<LibraryAddProviderCandidatePreview?> Function(
  ProviderConnector provider,
  ProviderSearchCandidate candidate,
);

typedef LibraryAddProviderGroupHydrationPredicate = bool Function(
  LibraryAddSearchContext context,
);

typedef LibraryAddSearchInputPredicate = bool Function(
  LibraryAddSearchContext context,
);

typedef LibraryAddCoverScanFilterValuesBuilder
    = Map<LibraryAddFilterId, LibraryAddFilterValue> Function(
  LibraryCoverScanResult result,
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

typedef LibraryAddMediaTargetRefBuilder = CatalogEntityRef? Function(
  CatalogSearchCandidate item,
);

typedef LibraryAddManualCandidateBuilder = CatalogSearchCandidate? Function(
  LibraryKindAddDraft draft, {
  required String title,
});

typedef LibraryAddTypedProviderCandidateProjection = CatalogSearchCandidate
    Function(ProviderSearchCandidate candidate);

typedef LibraryAddCoreCatalogProjection = CatalogSearchCandidate Function(
  CatalogSearchCandidate item,
);

class LibraryAddSearchCapability {
  const LibraryAddSearchCapability({
    this.initialAdvancedFilters = const {},
    required this.advancedFilterDescriptorsBuilder,
    required this.coreSearchInputBuilder,
    required this.providerQueryBuilder,
    required this.ranking,
    this.searchInputPredicate,
    this.providerKindOverridesBuilder,
    this.typedProviderSearchBuilder,
    this.typedProviderSearchContextBuilder,
    this.typedProviderCandidatePreviewLoader,
    this.coreSearchResultFilter,
    this.typedProviderSearchResultFilter,
    this.providerGroupHydrationPredicate,
    this.removeProviderGroupsWithoutVisibleChildren = false,
    this.kindSpecificPaneBuilder,
    this.coverScanQueryBuilder,
    this.coverScanFilterValuesBuilder,
    this.coreMatchSummaryBuilder,
    this.typedProviderMatchSummaryBuilder,
  });

  final Map<LibraryAddFilterId, LibraryAddFilterValue> initialAdvancedFilters;
  final LibraryAddAdvancedFilterDescriptorsBuilder
      advancedFilterDescriptorsBuilder;
  final LibraryAddCoreSearchInputBuilder coreSearchInputBuilder;
  final LibraryAddProviderQueryBuilder providerQueryBuilder;
  final LibraryAddSearchRanking ranking;
  final LibraryAddSearchInputPredicate? searchInputPredicate;
  final LibraryAddProviderKindOverridesBuilder? providerKindOverridesBuilder;
  final LibraryAddTypedProviderSearchBuilder? typedProviderSearchBuilder;
  final LibraryAddTypedProviderSearchContextBuilder?
      typedProviderSearchContextBuilder;
  final LibraryAddTypedProviderCandidatePreviewLoader?
      typedProviderCandidatePreviewLoader;
  final LibraryAddCoreSearchResultFilter? coreSearchResultFilter;
  final LibraryAddTypedProviderSearchResultFilter?
      typedProviderSearchResultFilter;
  final LibraryAddProviderGroupHydrationPredicate?
      providerGroupHydrationPredicate;
  final bool removeProviderGroupsWithoutVisibleChildren;
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      kindSpecificPaneBuilder;
  final String? Function(LibraryCoverScanResult result)? coverScanQueryBuilder;
  final LibraryAddCoverScanFilterValuesBuilder? coverScanFilterValuesBuilder;
  final LibraryAddMatchSummaryBuilder<CatalogSearchCandidate>?
      coreMatchSummaryBuilder;
  final LibraryAddMatchSummaryBuilder<ProviderSearchCandidate>?
      typedProviderMatchSummaryBuilder;

  Iterable<LibraryAddSearchScope> providerKindOverrides(
    LibraryAddSearchContext context,
  ) =>
      providerKindOverridesBuilder?.call(context) ?? const [];

  Future<List<ProviderSearchCandidate>> searchProvider(
    ProviderConnector provider, {
    required String query,
    required CatalogMediaKind kind,
    int limit = 25,
    LibraryAddSearchContext? context,
    ProviderCancellationToken? cancellationToken,
  }) async {
    final typedContextBuilder = typedProviderSearchContextBuilder;
    if (typedContextBuilder != null && context != null) {
      return typedContextBuilder(
        provider,
        query: query,
        kind: kind,
        limit: limit,
        context: context,
        cancellationToken: cancellationToken,
      );
    }
    final typedSearch = typedProviderSearchBuilder;
    if (typedSearch != null) {
      return typedSearch(
        provider,
        query: query,
        kind: kind,
        limit: limit,
        cancellationToken: cancellationToken,
      );
    }
    final hits = await provider.searchHits(
      query,
      kind: kind,
      limit: limit,
      cancellationToken: cancellationToken,
    );
    return [
      for (final hit in hits)
        ProviderSearchHitCandidate.fromHit(
          hit,
          provider: provider.descriptor.name,
        ),
    ];
  }

  List<CatalogSearchCandidate> filterCoreSearchResults(
    List<CatalogSearchCandidate> items,
    LibraryAddSearchContext context,
  ) {
    return coreSearchResultFilter?.call(items, context) ?? items;
  }

  List<ProviderSearchCandidate> filterProviderSearchResults(
    List<ProviderSearchCandidate> candidates,
    LibraryAddSearchContext context,
  ) {
    final typedFilter = typedProviderSearchResultFilter;
    if (typedFilter != null) return typedFilter(candidates, context);
    return candidates;
  }

  bool shouldHydrateProviderGroups(LibraryAddSearchContext context) {
    return providerGroupHydrationPredicate?.call(context) ?? false;
  }

  bool hasSearchInput(LibraryAddSearchContext context) =>
      searchInputPredicate?.call(context) ?? context.hasAnyInput;

  String? coverScanQuery(LibraryCoverScanResult result) =>
      coverScanQueryBuilder?.call(result) ?? result.query;

  Map<LibraryAddFilterId, LibraryAddFilterValue> coverScanFilterValues(
    LibraryCoverScanResult result,
  ) =>
      coverScanFilterValuesBuilder?.call(result) ?? const {};

  String? coreMatchSummary(
    CatalogSearchCandidate item,
    LibraryAddSearchContext context,
  ) {
    final custom = coreMatchSummaryBuilder?.call(item, context);
    if (custom != null) return custom;
    return _matchesQuery(item.summary.primaryLabel, context.query) ? 'Title' : null;
  }

  String? providerMatchSummary(
    ProviderSearchCandidate candidate,
    LibraryAddSearchContext context,
  ) {
    final typedCustom =
        typedProviderMatchSummaryBuilder?.call(candidate, context);
    if (typedCustom != null) return typedCustom;
    return _matchesQuery(candidate.title, context.query) ? 'Title' : null;
  }
}

bool _matchesQuery(String candidate, String query) {
  final normalizedCandidate = candidate.trim().toLowerCase();
  final normalizedQuery = query.trim().toLowerCase();
  return normalizedCandidate.isNotEmpty &&
      normalizedQuery.isNotEmpty &&
      (normalizedCandidate == normalizedQuery ||
          normalizedCandidate.contains(normalizedQuery));
}

abstract interface class LibraryAddCapability<
    TDraft extends LibraryAddKindDraft> {
  CatalogMediaKind get kind;

  TDraft createInitialDraft();
  LibraryKindAddDraft createManualDraft();

  bool get hasManualCandidateBuilder => false;

  /// Kind-owned validation copy for a manual candidate that could not be
  /// created. The generic host renders this value but never infers a kind
  /// name or entity terminology itself.
  String get manualCandidateValidationMessage =>
      'Enter a valid catalog candidate';

  CatalogSearchCandidate? buildManualCandidate(
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
  LibraryAddBottomBarBuilder? get bottomBarBuilder;
  LibraryAddDialogLauncher? get dialogLauncher;
  LibraryAddChromeConfig get chrome;
  LibraryAddSearchCapability get search;
  LibraryAddResultPolicy get resultPolicy;

  CatalogSearchCandidate catalogCandidateFromProviderCandidate(
    ProviderSearchCandidate candidate,
  );

  CatalogSearchCandidate catalogCandidateFromCoreItem(
    CatalogSearchCandidate item,
  );

  bool? digitalCopyFlag(CatalogSearchCandidate item) => null;

  /// Returns a kind-owned concrete target when the media-level action must
  /// address a nested entity. Most kinds keep the catalog root as-is.
  CatalogEntityRef? mediaTargetRef(CatalogSearchCandidate item) => null;

  Widget? buildPreviewPane(
    BuildContext context,
    LibraryAddPreviewPaneRequest request,
  );

  AddOwnedItemCommand buildCommand(CatalogSearchCandidate item,
      LibraryAddCommonDraft common, LibraryAddKindDraft draft,
      {CatalogEntityRef? targetRef,
      LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft()});

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
    this.manualCandidateValidationMessage = 'Enter a valid catalog candidate',
    this.manualPaneBuilder,
    this.headerBuilder,
    this.modeBarBuilder,
    this.previewPaneBuilder,
    this.searchPaneBuilder,
    this.bottomBarBuilder,
    this.dialogLauncher,
    this.chrome = const LibraryAddChromeConfig(),
    required this.search,
    this.ownedPayloadBuilder,
    this.digitalCopyFlagBuilder,
    this.mediaTargetRefBuilder,
    this.typedProviderCandidateProjectionBuilder,
    required this.coreCatalogProjectionBuilder,
    this.resultPolicy = const LibraryAddResultPolicy.identity(),
  });

  @override
  final CatalogMediaKind kind;
  final TDraft Function() initialDraftBuilder;
  final LibraryKindAddDraft Function()? manualDraftBuilder;
  final LibraryAddManualCandidateBuilder? manualCandidateBuilder;
  final Widget Function(
          BuildContext context, LibraryAddManualPaneRequest request)?
      manualPaneBuilder;
  @override
  final LibraryAddHeaderBuilder? headerBuilder;
  @override
  final LibraryAddModeBarBuilder? modeBarBuilder;
  @override
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
  @override
  final LibraryAddSearchPaneBuilder? searchPaneBuilder;
  @override
  final LibraryAddBottomBarBuilder? bottomBarBuilder;
  @override
  final LibraryAddDialogLauncher? dialogLauncher;
  @override
  final LibraryAddChromeConfig chrome;
  @override
  final LibraryAddSearchCapability search;
  final LibraryAddOwnedPayloadBuilder<TDraft>? ownedPayloadBuilder;
  final LibraryAddDigitalCopyFlagBuilder? digitalCopyFlagBuilder;
  final LibraryAddMediaTargetRefBuilder? mediaTargetRefBuilder;
  final LibraryAddTypedProviderCandidateProjection?
      typedProviderCandidateProjectionBuilder;
  final LibraryAddCoreCatalogProjection coreCatalogProjectionBuilder;
  @override
  final LibraryAddResultPolicy resultPolicy;

  @override
  TDraft createInitialDraft() => initialDraftBuilder();

  @override
  bool? digitalCopyFlag(CatalogSearchCandidate item) =>
      digitalCopyFlagBuilder?.call(item);

  @override
  CatalogEntityRef? mediaTargetRef(CatalogSearchCandidate item) =>
      mediaTargetRefBuilder?.call(item);

  @override
  CatalogSearchCandidate catalogCandidateFromProviderCandidate(
    ProviderSearchCandidate candidate,
  ) {
    final typedProjection = typedProviderCandidateProjectionBuilder;
    if (typedProjection != null) {
      return typedProjection(candidate);
    }
    throw StateError(
      'Kind ${kind.apiValue} received an unsupported provider candidate '
      'without a typed projection.',
    );
  }

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
  bool get hasManualCandidateBuilder => manualCandidateBuilder != null;

  @override
  final String manualCandidateValidationMessage;

  @override
  Widget buildManualPane(
    BuildContext context,
    LibraryAddManualPaneRequest request,
  ) {
    if (manualPaneBuilder != null) {
      return manualPaneBuilder!(context, request);
    }
    return LibraryAddUnsupportedManualPane(request: request);
  }

  @override
  Widget? buildPreviewPane(
    BuildContext context,
    LibraryAddPreviewPaneRequest request,
  ) {
    return previewPaneBuilder?.call(context, request);
  }

  OwnedItemCreatePayload _buildOwnedPayload(CatalogSearchCandidate item,
      LibraryAddCommonDraft common, TDraft draft, JsonEncodable details,
      {String? kindValue}) {
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
  AddOwnedItemCommand buildCommand(CatalogSearchCandidate item,
      LibraryAddCommonDraft common, LibraryAddKindDraft draft,
      {CatalogEntityRef? targetRef,
      LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft()}) {
    final effectiveDraft = draft is TDraft ? draft : createInitialDraft();
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
    final effectiveDraft = draft is TDraft ? draft : createInitialDraft();
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
