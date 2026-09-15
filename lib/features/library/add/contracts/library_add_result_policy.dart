import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

typedef LibraryAddCoreResultVisibilityPredicate = bool Function(
  CatalogSearchCandidate item,
  LibraryAddResultPolicyContext context,
);

typedef LibraryAddProviderResultVisibilityPredicate = bool Function(
  ProviderCandidate candidate,
  LibraryAddResultPolicyContext context,
);

typedef LibraryAddProviderCandidateGroupPredicate = bool Function(
  ProviderCandidate candidate,
);

typedef LibraryAddCoreGroupTitleBuilder = String Function(
  CatalogSearchCandidate item,
);

typedef LibraryAddProviderGroupTitleBuilder = String Function(
  ProviderCandidate candidate,
);

typedef LibraryAddProviderGroupKeyBuilder = String Function(
  ProviderCandidate candidate,
);

typedef LibraryAddProviderCandidateComparator = int Function(
  ProviderCandidate left,
  ProviderCandidate right,
);

typedef LibraryAddProviderGroupCandidateLabelBuilder = String Function(
  ProviderCandidate candidate,
);

typedef LibraryAddProviderGroupCandidateBadgeBuilder = String Function(
  ProviderCandidate candidate,
);

class LibraryAddResultOption {
  const LibraryAddResultOption({
    required this.id,
    required this.label,
    this.initialValue = true,
    this.showInSourceToggles = true,
  });

  final String id;
  final String label;
  final bool initialValue;
  final bool showInSourceToggles;
}

class LibraryAddResultPolicyState {
  const LibraryAddResultPolicyState({this.values = const {}});

  final Map<String, bool> values;

  bool valueFor(String id, {bool fallback = false}) {
    return values[id] ?? fallback;
  }

  LibraryAddResultPolicyState withValue(String id, bool value) {
    return LibraryAddResultPolicyState(
      values: Map.unmodifiable({...values, id: value}),
    );
  }
}

class LibraryAddResultPolicyContext {
  const LibraryAddResultPolicyContext({
    required this.state,
    required this.ownedCatalogRefs,
    required this.defaultValues,
  });

  final LibraryAddResultPolicyState state;
  final Set<CatalogEntityRef> ownedCatalogRefs;
  final Map<String, bool> defaultValues;

  bool optionIsEnabled(String id) {
    return state.valueFor(id, fallback: defaultValues[id] ?? false);
  }
}

class LibraryAddResultPolicy {
  const LibraryAddResultPolicy({
    this.options = const [],
    this.initialState = const LibraryAddResultPolicyState(),
    this.useGridResults = false,
    this.coreResultVisibility,
    this.providerResultVisibility,
    this.providerCandidateIsGroup,
    this.coreGroupTitleBuilder,
    this.providerGroupTitleBuilder,
    this.providerGroupKeyBuilder,
    this.providerCandidateComparator,
    this.providerGroupCandidateLabelBuilder,
    this.providerGroupCandidateBadgeBuilder,
    this.showProviderGroupCandidateAsChild = true,
  });

  const LibraryAddResultPolicy.identity() : this();

  final List<LibraryAddResultOption> options;
  final LibraryAddResultPolicyState initialState;
  final bool useGridResults;
  final LibraryAddCoreResultVisibilityPredicate? coreResultVisibility;
  final LibraryAddProviderResultVisibilityPredicate? providerResultVisibility;
  final LibraryAddProviderCandidateGroupPredicate? providerCandidateIsGroup;
  final LibraryAddCoreGroupTitleBuilder? coreGroupTitleBuilder;
  final LibraryAddProviderGroupTitleBuilder? providerGroupTitleBuilder;
  final LibraryAddProviderGroupKeyBuilder? providerGroupKeyBuilder;
  final LibraryAddProviderCandidateComparator? providerCandidateComparator;
  final LibraryAddProviderGroupCandidateLabelBuilder?
      providerGroupCandidateLabelBuilder;
  final LibraryAddProviderGroupCandidateBadgeBuilder?
      providerGroupCandidateBadgeBuilder;

  /// Whether a synthetic provider group candidate should also be rendered as
  /// a child row. Most grouped searches use the candidate as an actionable
  /// child, but kinds whose group header is itself the group result can hide
  /// the duplicate row while keeping the candidate available for selection.
  final bool showProviderGroupCandidateAsChild;

  LibraryAddResultPolicyContext context({
    required LibraryAddResultPolicyState state,
    Set<CatalogEntityRef> ownedCatalogRefs = const {},
  }) {
    return LibraryAddResultPolicyContext(
      state: state,
      ownedCatalogRefs: ownedCatalogRefs,
      defaultValues: {
        for (final option in options) option.id: option.initialValue,
      },
    );
  }

  List<CatalogSearchCandidate> filterCoreResults({
    required List<CatalogSearchCandidate> items,
    required LibraryAddResultPolicyState state,
    Set<CatalogEntityRef> ownedCatalogRefs = const {},
  }) {
    final resultContext = context(
      state: state,
      ownedCatalogRefs: ownedCatalogRefs,
    );
    final predicate = coreResultVisibility;
    if (predicate == null) {
      return items;
    }
    return items
        .where((item) => predicate(item, resultContext))
        .toList(growable: false);
  }

  List<ProviderCandidate> filterProviderResults({
    required List<ProviderCandidate> candidates,
    required LibraryAddResultPolicyState state,
    Set<CatalogEntityRef> ownedCatalogRefs = const {},
  }) {
    final resultContext = context(
      state: state,
      ownedCatalogRefs: ownedCatalogRefs,
    );
    final predicate = providerResultVisibility;
    if (predicate == null) {
      return candidates;
    }
    return candidates
        .where((candidate) => predicate(candidate, resultContext))
        .toList(growable: false);
  }

  bool isProviderGroupCandidate(ProviderCandidate candidate) {
    final predicate = providerCandidateIsGroup;
    return predicate == null ? false : predicate(candidate);
  }

  String coreGroupTitle(CatalogSearchCandidate item) {
    final builder = coreGroupTitleBuilder;
    final title = builder == null ? null : builder(item).trim();
    return title == null || title.isEmpty ? item.title : title;
  }

  String providerGroupTitle(ProviderCandidate candidate) {
    final builder = providerGroupTitleBuilder;
    final title = builder == null ? null : builder(candidate).trim();
    final fallback = candidate.title.trim();
    return title == null || title.isEmpty
        ? (fallback.isEmpty ? 'Untitled' : fallback)
        : title;
  }

  String providerGroupKey(ProviderCandidate candidate) {
    final key = providerGroupKeyBuilder?.call(candidate).trim();
    if (key != null && key.isNotEmpty) return key;
    return providerGroupTitle(candidate).toLowerCase();
  }

  int compareProviderCandidates(
    ProviderCandidate left,
    ProviderCandidate right,
  ) {
    return providerCandidateComparator?.call(left, right) ??
        left.title.toLowerCase().compareTo(right.title.toLowerCase());
  }

  String providerGroupCandidateLabel(ProviderCandidate candidate) {
    return providerGroupCandidateLabelBuilder?.call(candidate) ??
        '${candidate.title} (group)';
  }

  String providerGroupCandidateBadge(ProviderCandidate candidate) {
    return providerGroupCandidateBadgeBuilder?.call(candidate) ?? 'group';
  }
}
