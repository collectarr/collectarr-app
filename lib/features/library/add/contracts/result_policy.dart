import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/widgets.dart';

typedef LibraryAddCoreResultVisibilityPredicate = bool Function(
  CatalogSearchCandidate item,
  LibraryAddResultPolicyContext context,
);

class LibraryAddResultOption {
  const LibraryAddResultOption({
    required this.id,
    required this.label,
    required this.icon,
    this.initialValue = true,
  });

  final String id;

  /// The toggle's tooltip.
  final String label;

  /// The glyph the toggle strikes through.
  final IconData icon;
  final bool initialValue;
}

class LibraryAddResultPolicyState {
  const LibraryAddResultPolicyState({this.values = const {}});

  final Map<String, bool> values;

  bool valueFor(String id, {bool fallback = false}) => values[id] ?? fallback;

  LibraryAddResultPolicyState withValue(String id, bool value) =>
      LibraryAddResultPolicyState(
        values: Map.unmodifiable({...values, id: value}),
      );
}

class LibraryAddResultPolicyContext {
  const LibraryAddResultPolicyContext({
    required this.state,
    required this.entryCatalogRefs,
    required this.defaultValues,
  });

  final LibraryAddResultPolicyState state;
  final Set<CatalogItemRef> entryCatalogRefs;
  final Map<String, bool> defaultValues;

  bool optionIsEnabled(String id) =>
      state.valueFor(id, fallback: defaultValues[id] ?? false);
}

/// Lists Core results once per group and offers the group's variants as a
/// cover grid beside the list, as the reference's Add Games lists a game once
/// per platform and shows its editions. The kind decides what a group and a
/// variant are; the shared pane only lays them out.
class LibraryAddResultGrouping {
  const LibraryAddResultGrouping({
    required this.groupKey,
    required this.groupDetail,
    required this.variantLabel,
    required this.variantBadge,
    this.variantFacet,
  });

  /// Results with the same key form one row.
  final String Function(CatalogSearchCandidate item) groupKey;

  /// The line under a group's title, in the row and above the variants.
  final Widget Function(BuildContext context, CatalogSearchCandidate item)
      groupDetail;

  /// The caption under a variant's cover.
  final String Function(CatalogSearchCandidate item) variantLabel;

  /// The short tag at the right of a variant's caption.
  final String Function(CatalogSearchCandidate item) variantBadge;

  /// Segments above the variants that narrow the chosen group's variants,
  /// such as release regions; null when the kind has none.
  final LibraryAddVariantFacet? variantFacet;

  static const listWidth = 460.0;
  static const minListWidth = 240.0;
  static const dialogWidth = 1200.0;
}

/// Segments that narrow a group's variants without a new search. "All"
/// comes first; a segment without variants in the chosen group is disabled.
class LibraryAddVariantFacet {
  const LibraryAddVariantFacet({required this.segments, required this.valueOf});

  /// The segments after "All", as value and label.
  final List<({String value, String label})> segments;

  /// The segment a variant belongs to; null lists it under every segment.
  final String? Function(CatalogSearchCandidate item) valueOf;
}

/// The search results a kind's [LibraryAddResultsBuilder] draws.
@immutable
class LibraryAddResultsRequest {
  const LibraryAddResultsRequest({
    required this.type,
    required this.accent,
    required this.notice,
    required this.results,
    required this.selectedResultId,
    required this.checkedResultIds,
    required this.entryCatalogRefs,
    required this.coreMatchSummary,
    required this.onSelectResult,
    required this.onToggleResultCheck,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final Widget notice;
  final List<CatalogSearchCandidate> results;
  final String? selectedResultId;
  final Set<String> checkedResultIds;
  final Set<CatalogItemRef> entryCatalogRefs;
  final String? Function(CatalogSearchCandidate item)? coreMatchSummary;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onToggleResultCheck;
}

typedef LibraryAddResultsBuilder = Widget Function(
  BuildContext context,
  LibraryAddResultsRequest request,
);

class LibraryAddResultPolicy {
  const LibraryAddResultPolicy({
    this.options = const [],
    this.initialState = const LibraryAddResultPolicyState(),
    this.resultsBuilder,
    this.coreResultVisibility,
    this.grouping,
  });

  const LibraryAddResultPolicy.identity() : this();

  final List<LibraryAddResultOption> options;
  final LibraryAddResultPolicyState initialState;

  /// Draws a non-empty result list; null is the standard rows with tick
  /// boxes.
  final LibraryAddResultsBuilder? resultsBuilder;
  final LibraryAddCoreResultVisibilityPredicate? coreResultVisibility;
  final LibraryAddResultGrouping? grouping;

  /// This policy listing its results in one column.
  LibraryAddResultPolicy get ungrouped => grouping == null
      ? this
      : LibraryAddResultPolicy(
          options: options,
          initialState: initialState,
          resultsBuilder: resultsBuilder,
          coreResultVisibility: coreResultVisibility,
        );

  LibraryAddResultPolicyContext context({
    required LibraryAddResultPolicyState state,
    Set<CatalogItemRef> entryCatalogRefs = const {},
  }) =>
      LibraryAddResultPolicyContext(
        state: state,
        entryCatalogRefs: entryCatalogRefs,
        defaultValues: {
          for (final option in options) option.id: option.initialValue,
        },
      );

  List<CatalogSearchCandidate> filterCoreResults({
    required List<CatalogSearchCandidate> items,
    required LibraryAddResultPolicyState state,
    Set<CatalogItemRef> entryCatalogRefs = const {},
  }) {
    final resultContext = context(
      state: state,
      entryCatalogRefs: entryCatalogRefs,
    );
    final predicate = coreResultVisibility;
    if (predicate == null) return items;
    return items
        .where((item) => predicate(item, resultContext))
        .toList(growable: false);
  }
}
