import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_item.dart';

typedef LibraryAddCoreResultVisibilityPredicate = bool Function(
  LibraryAddCatalogItem item,
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
  LibraryAddCatalogItem item,
);

typedef LibraryAddProviderGroupTitleBuilder = String Function(
  ProviderCandidate candidate,
);

typedef LibraryAddProviderCandidateComparator = int Function(
  ProviderCandidate left,
  ProviderCandidate right,
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
    this.providerCandidateComparator,
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
  final LibraryAddProviderCandidateComparator? providerCandidateComparator;

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

  List<LibraryAddCatalogItem> filterCoreResults({
    required List<LibraryAddCatalogItem> items,
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

  String coreGroupTitle(LibraryAddCatalogItem item) {
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

  int compareProviderCandidates(
    ProviderCandidate left,
    ProviderCandidate right,
  ) {
    return providerCandidateComparator?.call(left, right) ??
        left.title.toLowerCase().compareTo(right.title.toLowerCase());
  }
}
