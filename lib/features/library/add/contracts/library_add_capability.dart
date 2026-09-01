import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_unsupported_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:flutter/widgets.dart';

export 'library_add_result_policy.dart';

typedef LibraryAddAdvancedFilterDescriptorsBuilder
    = List<LibraryAddAdvancedFilterField<String>> Function(
  LibraryAddModeBarRequest request,
);

typedef LibraryAddCoreSearchInputBuilder = LibraryMetadataSearchInput Function(
  LibraryAddSearchContext context, {
  required int limit,
});

typedef LibraryAddProviderQueryBuilder = String Function(
  LibraryAddSearchContext context,
);

typedef LibraryAddProviderKindOverridesBuilder = Iterable<String> Function(
  LibraryAddSearchContext context,
);

typedef LibraryAddSearchInputPredicate = bool Function(
  LibraryAddSearchContext context,
);

typedef LibraryAddCoverScanFilterValuesBuilder
    = Map<LibraryAddFilterId, Object?> Function(LibraryCoverScanResult result);

typedef LibraryAddMatchSummaryBuilder<T> = String? Function(
  T candidate,
  LibraryAddSearchContext context,
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
    this.kindSpecificPaneBuilder,
    this.coverScanQueryBuilder,
    this.coverScanFilterValuesBuilder,
    this.coreMatchSummaryBuilder,
    this.providerMatchSummaryBuilder,
  });

  final Map<LibraryAddFilterId, Object?> initialAdvancedFilters;
  final LibraryAddAdvancedFilterDescriptorsBuilder
      advancedFilterDescriptorsBuilder;
  final LibraryAddCoreSearchInputBuilder coreSearchInputBuilder;
  final LibraryAddProviderQueryBuilder providerQueryBuilder;
  final LibraryAddSearchRanking ranking;
  final LibraryAddSearchInputPredicate? searchInputPredicate;
  final LibraryAddProviderKindOverridesBuilder? providerKindOverridesBuilder;
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      kindSpecificPaneBuilder;
  final String? Function(LibraryCoverScanResult result)? coverScanQueryBuilder;
  final LibraryAddCoverScanFilterValuesBuilder? coverScanFilterValuesBuilder;
  final LibraryAddMatchSummaryBuilder<LibraryMetadataItem>?
      coreMatchSummaryBuilder;
  final LibraryAddMatchSummaryBuilder<ProviderCandidate>?
      providerMatchSummaryBuilder;

  Iterable<String> providerKindOverrides(LibraryAddSearchContext context) =>
      providerKindOverridesBuilder?.call(context) ?? const [];

  bool hasSearchInput(LibraryAddSearchContext context) =>
      searchInputPredicate?.call(context) ?? context.hasAnyInput;

  String? coverScanQuery(LibraryCoverScanResult result) =>
      coverScanQueryBuilder?.call(result) ?? result.query;

  Map<LibraryAddFilterId, Object?> coverScanFilterValues(
    LibraryCoverScanResult result,
  ) =>
      coverScanFilterValuesBuilder?.call(result) ?? const {};

  String? coreMatchSummary(
    LibraryMetadataItem item,
    LibraryAddSearchContext context,
  ) {
    final custom = coreMatchSummaryBuilder?.call(item, context);
    if (custom != null) return custom;
    return _matchesQuery(item.title, context.query) ? 'Title' : null;
  }

  String? providerMatchSummary(
    ProviderCandidate candidate,
    LibraryAddSearchContext context,
  ) {
    final custom = providerMatchSummaryBuilder?.call(candidate, context);
    if (custom != null) return custom;
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
  LibraryAddSearchCapability get search;
  LibraryAddResultPolicy get resultPolicy;

  Widget? buildPreviewPane(
    BuildContext context,
    LibraryAddPreviewPaneRequest request,
  );

  AddOwnedItemCommand buildCommand(
    LibraryMetadataItem item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft,
  );
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
    this.manualPaneBuilder,
    this.headerBuilder,
    this.modeBarBuilder,
    this.previewPaneBuilder,
    this.searchPaneBuilder,
    this.bottomBarBuilder,
    this.dialogLauncher,
    required this.search,
    this.resultPolicy = const LibraryAddResultPolicy.identity(),
  });

  @override
  final CatalogMediaKind kind;
  final TDraft Function() initialDraftBuilder;
  final LibraryKindAddDraft Function()? manualDraftBuilder;
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
  final LibraryAddSearchCapability search;
  @override
  final LibraryAddResultPolicy resultPolicy;

  @override
  TDraft createInitialDraft() => initialDraftBuilder();

  @override
  LibraryKindAddDraft createManualDraft() =>
      manualDraftBuilder?.call() ?? const _EmptyKindAddDraft();

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

  @override
  AddOwnedItemCommand buildCommand(
    LibraryMetadataItem item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft,
  ) {
    final effectiveDraft = draft is TDraft ? draft : createInitialDraft();
    return AddOwnedItemCommand(
      catalogRef: CatalogEntityRef(
        kind: kind.apiValue,
        entityType: CatalogEntityType.ownedCopy,
        id: item.id,
      ),
      common: common.toOwnedItemCommonDraft(),
      details: effectiveDraft.toOwnedDetailsDraft(),
    );
  }
}
