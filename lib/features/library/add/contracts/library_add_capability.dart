import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
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

typedef LibraryAddEntryPayloadBuilder<TDraft extends LibraryAddKindDraft>
    = LibraryEntryCreatePayload Function(
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
    this.browse,
    this.presentation = const LibraryAddSearchPresentationCapability(),
  });

  final LibraryAddSearchInputCapability input;
  final LibraryAddCoreSearchCapability core;
  final LibraryAddCoverScanCapability? coverScan;

  /// Adds a tab that finds a group of catalog items, such as a comic
  /// series, and checks those to add.
  final LibraryAddBrowseCapability? browse;
  final LibraryAddSearchPresentationCapability presentation;
}

/// One Core group of catalog items in the Add dialog's browse tab.
@immutable
class LibraryAddBrowseGroup {
  const LibraryAddBrowseGroup({
    required this.title,
    required this.countLabel,
    required this.query,
    this.details,
    this.period,
    this.coverImageUrl,
  });

  final String title;

  /// How many items the group holds, as "12".
  final String countLabel;

  /// The Core query parameters that select exactly this group's items.
  final Map<String, Object> query;

  /// The kind's facts about the group, as one line.
  final String? details;

  /// The years the group spans, right-aligned under the count.
  final String? period;
  final String? coverImageUrl;
}

class LibraryAddBrowseCapability {
  const LibraryAddBrowseCapability({
    required this.label,
    required this.hintText,
    required this.icon,
    required this.searchGroups,
    required this.loadItemRows,
    this.coverBlock,
  });

  /// Names the tab, the group list and its empty state, as "Series".
  final String label;
  final String hintText;
  final IconData icon;

  /// Groups whose title matches the query.
  final Future<List<LibraryAddBrowseGroup>> Function(
      ApiClient api, String query) searchGroups;

  /// Core search envelopes for every item of a group, in order.
  final Future<List<Map<String, dynamic>>> Function(
      ApiClient api, LibraryAddBrowseGroup group) loadItemRows;

  /// The labels around each item's cover; set, a group's items show as a
  /// cover grid (or a list) instead of result rows.
  final LibraryAddCoverBlock Function(CatalogSearchCandidate item)? coverBlock;
}

/// What the cover grid writes around one item's cover: a boxed badge with
/// its period beside, and a caption below.
class LibraryAddCoverBlock {
  const LibraryAddCoverBlock({
    required this.badge,
    this.month,
    this.year,
    this.caption,
  });

  final String badge;
  final String? month;
  final int? year;
  final String? caption;
}

/// An Add tab that searches Core by one typed code, labelled by the kind.
class LibraryAddCodeSearchTab {
  const LibraryAddCodeSearchTab({
    required this.label,
    required this.hintText,
    this.icon,
  });

  final String label;
  final String hintText;
  final IconData? icon;
}

class LibraryAddSearchInputCapability {
  const LibraryAddSearchInputCapability({
    this.initialAdvancedFilters = const {},
    this.advancedFilterDescriptorsBuilder = _noAdvancedFilters,
    this.searchInputPredicate,
    this.codeSearchTab,
  });

  final Map<LibraryAddFilterId, LibraryAddFilterValue> initialAdvancedFilters;

  /// An extra tab that searches Core by a code the kind names.
  final LibraryAddCodeSearchTab? codeSearchTab;
  final LibraryAddAdvancedFilterDescriptorsBuilder
      advancedFilterDescriptorsBuilder;
  final LibraryAddSearchInputPredicate? searchInputPredicate;

  bool hasSearchInput(LibraryAddSearchContext context) =>
      searchInputPredicate?.call(context) ?? context.hasAnyInput;
}

List<LibraryAddAdvancedFilterField<String>> _noAdvancedFilters(
  LibraryAddModeBarRequest request,
) =>
    const [];

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
    this.queryTrailingBuilder,
    this.coreMatchSummaryBuilder,
  });

  /// Kind controls in the results header, such as a format filter.
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      controlsBuilder;

  /// Kind controls between the title field and Search, such as a platform
  /// picker that scopes the search.
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      queryTrailingBuilder;
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

  /// Kind-entry validation copy for a manual candidate that could not be
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

  LibraryAddPreviewPaneBuilder? get previewPaneBuilder;
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

  AddLibraryEntryCommand buildCommand(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft, {
    LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft(),
  });

  AddLibraryEntryCommand buildCommandFromDetails(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    JsonEncodable details, {
    LibraryAddKindDraft? draft,
    LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft(),
    String? kindValue,
  });
}

class _EmptyKindAddDraft implements LibraryKindAddDraft {
  _EmptyKindAddDraft();

  @override
  String catalogTitle = '';
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
    this.previewPaneBuilder,
    this.chrome = const LibraryAddChromeConfig(),
    required this.search,
    this.entryPayloadBuilder,
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
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
  @override
  final LibraryAddChromeConfig chrome;
  @override
  final LibraryAddSearchCapability search;
  final LibraryAddEntryPayloadBuilder<TDraft>? entryPayloadBuilder;
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
      manualDraftBuilder?.call() ?? _EmptyKindAddDraft();

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

  LibraryEntryCreatePayload _buildEntryPayload(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    TDraft draft,
    JsonEncodable details, {
    String? kindValue,
  }) {
    try {
      final payload = entryPayloadBuilder?.call(
        item,
        common,
        draft,
        details,
        kindValue: kindValue,
      );
      if (payload == null) {
        throw StateError(
          'Kind ${kind.apiValue} must provide an entry create payload.',
        );
      }
      return payload;
    } on TypeError catch (error) {
      throw StateError(
        'Kind ${kind.apiValue} received details entry by another kind: '
        '$error',
      );
    }
  }

  @override
  AddLibraryEntryCommand buildCommand(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft, {
    LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft(),
  }) {
    final effectiveDraft = _resolveDraft(
      draft,
      operation: 'build an add command',
    );
    final details = effectiveDraft.toEntryDetailsDraft();
    final typedPayload = _buildEntryPayload(
      item,
      common,
      effectiveDraft,
      details,
    );
    return AddLibraryEntryCommand(
      catalogRef: item.reference,
      typedPayload: typedPayload,
      tracking: LibraryEntryTrackingDraft(
        status: mediaTrackingStatusFromValue(tracking.readStatus),
        rating: tracking.rating,
        startedAt: tracking.startedAt,
        finishedAt: tracking.finishedAt,
        notes: tracking.notes,
      ),
    );
  }

  @override
  AddLibraryEntryCommand buildCommandFromDetails(
    CatalogSearchCandidate item,
    LibraryAddCommonDraft common,
    JsonEncodable details, {
    LibraryAddKindDraft? draft,
    LibraryAddTrackingDraft tracking = const LibraryAddTrackingDraft(),
    String? kindValue,
  }) {
    final effectiveDraft = _resolveDraft(
      draft,
      operation: 'build an add command from details',
    );
    final typedPayload = _buildEntryPayload(
      item,
      common,
      effectiveDraft,
      details,
      kindValue: kindValue,
    );
    return AddLibraryEntryCommand(
      catalogRef: item.reference,
      typedPayload: typedPayload,
      tracking: LibraryEntryTrackingDraft(
        status: mediaTrackingStatusFromValue(tracking.readStatus),
        rating: tracking.rating,
        startedAt: tracking.startedAt,
        finishedAt: tracking.finishedAt,
        notes: tracking.notes,
      ),
    );
  }
}
