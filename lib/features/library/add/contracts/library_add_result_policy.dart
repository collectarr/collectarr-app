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

typedef LibraryAddCoreGroupArtistBuilder = String? Function(
  CatalogSearchCandidate item,
);

typedef LibraryAddProviderGroupTitleBuilder = String Function(
  ProviderCandidate candidate,
);

typedef LibraryAddProviderGroupArtistBuilder = String? Function(
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

typedef LibraryAddTypedProviderResultVisibilityPredicate = bool Function(
  ProviderSearchCandidate candidate,
  LibraryAddResultPolicyContext context,
);

typedef LibraryAddTypedProviderCandidateGroupPredicate = bool Function(
  ProviderSearchCandidate candidate,
);

typedef LibraryAddTypedProviderGroupTitleBuilder = String Function(
  ProviderSearchCandidate candidate,
);

typedef LibraryAddTypedProviderGroupArtistBuilder = String? Function(
  ProviderSearchCandidate candidate,
);

typedef LibraryAddTypedProviderGroupKeyBuilder = String Function(
  ProviderSearchCandidate candidate,
);

typedef LibraryAddTypedProviderCandidateComparator = int Function(
  ProviderSearchCandidate left,
  ProviderSearchCandidate right,
);

typedef LibraryAddTypedProviderGroupCandidateLabelBuilder = String Function(
  ProviderSearchCandidate candidate,
);

typedef LibraryAddTypedProviderGroupCandidateBadgeBuilder = String Function(
  ProviderSearchCandidate candidate,
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
    this.coreGroupArtistBuilder,
    this.providerGroupTitleBuilder,
    this.providerGroupArtistBuilder,
    this.providerGroupKeyBuilder,
    this.providerCandidateComparator,
    this.providerGroupCandidateLabelBuilder,
    this.providerGroupCandidateBadgeBuilder,
    this.typedProviderResultVisibility,
    this.typedProviderCandidateIsGroup,
    this.typedProviderGroupTitleBuilder,
    this.typedProviderGroupArtistBuilder,
    this.typedProviderGroupKeyBuilder,
    this.typedProviderCandidateComparator,
    this.typedProviderGroupCandidateLabelBuilder,
    this.typedProviderGroupCandidateBadgeBuilder,
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
  final LibraryAddCoreGroupArtistBuilder? coreGroupArtistBuilder;
  final LibraryAddProviderGroupTitleBuilder? providerGroupTitleBuilder;
  final LibraryAddProviderGroupArtistBuilder? providerGroupArtistBuilder;
  final LibraryAddProviderGroupKeyBuilder? providerGroupKeyBuilder;
  final LibraryAddProviderCandidateComparator? providerCandidateComparator;
  final LibraryAddProviderGroupCandidateLabelBuilder?
      providerGroupCandidateLabelBuilder;
  final LibraryAddProviderGroupCandidateBadgeBuilder?
      providerGroupCandidateBadgeBuilder;
  final LibraryAddTypedProviderResultVisibilityPredicate?
      typedProviderResultVisibility;
  final LibraryAddTypedProviderCandidateGroupPredicate?
      typedProviderCandidateIsGroup;
  final LibraryAddTypedProviderGroupTitleBuilder?
      typedProviderGroupTitleBuilder;
  final LibraryAddTypedProviderGroupArtistBuilder?
      typedProviderGroupArtistBuilder;
  final LibraryAddTypedProviderGroupKeyBuilder? typedProviderGroupKeyBuilder;
  final LibraryAddTypedProviderCandidateComparator?
      typedProviderCandidateComparator;
  final LibraryAddTypedProviderGroupCandidateLabelBuilder?
      typedProviderGroupCandidateLabelBuilder;
  final LibraryAddTypedProviderGroupCandidateBadgeBuilder?
      typedProviderGroupCandidateBadgeBuilder;

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

  List<ProviderSearchCandidate> filterProviderResults({
    required List<ProviderSearchCandidate> candidates,
    required LibraryAddResultPolicyState state,
    Set<CatalogEntityRef> ownedCatalogRefs = const {},
  }) {
    final resultContext = context(
      state: state,
      ownedCatalogRefs: ownedCatalogRefs,
    );
    final typedPredicate = typedProviderResultVisibility;
    if (typedPredicate != null) {
      return candidates
          .where((candidate) => typedPredicate(candidate, resultContext))
          .toList(growable: false);
    }
    final predicate = providerResultVisibility;
    if (predicate == null) {
      return candidates;
    }
    return candidates
        .where(
          (candidate) =>
              candidate is! ProviderCandidate ||
              predicate(candidate, resultContext),
        )
        .toList(growable: false);
  }

  bool isProviderGroupCandidate(ProviderSearchCandidate candidate) {
    final typedPredicate = typedProviderCandidateIsGroup;
    if (typedPredicate != null) return typedPredicate(candidate);
    final predicate = providerCandidateIsGroup;
    return predicate == null || candidate is! ProviderCandidate
        ? false
        : predicate(candidate);
  }

  String coreGroupTitle(CatalogSearchCandidate item) {
    final builder = coreGroupTitleBuilder;
    final title = builder == null ? null : builder(item).trim();
    return title == null || title.isEmpty ? item.title : title;
  }

  String providerGroupTitle(ProviderSearchCandidate candidate) {
    final typedBuilder = typedProviderGroupTitleBuilder;
    if (typedBuilder != null) {
      final title = typedBuilder(candidate).trim();
      return title.isEmpty ? candidate.title : title;
    }
    final builder = providerGroupTitleBuilder;
    final title = candidate is ProviderCandidate && builder != null
        ? builder(candidate).trim()
        : null;
    final fallback = candidate.title.trim();
    return title == null || title.isEmpty
        ? (fallback.isEmpty ? 'Untitled' : fallback)
        : title;
  }

  String? coreGroupArtist(CatalogSearchCandidate item) {
    final artist = coreGroupArtistBuilder?.call(item)?.trim();
    return artist == null || artist.isEmpty ? null : artist;
  }

  String? providerGroupArtist(ProviderSearchCandidate candidate) {
    final artist = typedProviderGroupArtistBuilder?.call(candidate)?.trim() ??
        (candidate is ProviderCandidate
            ? providerGroupArtistBuilder?.call(candidate)?.trim()
            : null);
    return artist == null || artist.isEmpty ? null : artist;
  }

  String providerGroupKey(ProviderSearchCandidate candidate) {
    final key = typedProviderGroupKeyBuilder?.call(candidate).trim() ??
        (candidate is ProviderCandidate
            ? providerGroupKeyBuilder?.call(candidate).trim()
            : null);
    if (key != null && key.isNotEmpty) return key;
    return providerGroupTitle(candidate).toLowerCase();
  }

  int compareProviderCandidates(
    ProviderSearchCandidate left,
    ProviderSearchCandidate right,
  ) {
    return typedProviderCandidateComparator?.call(left, right) ??
        (left is ProviderCandidate && right is ProviderCandidate
            ? providerCandidateComparator?.call(left, right)
            : null) ??
        left.title.toLowerCase().compareTo(right.title.toLowerCase());
  }

  String providerGroupCandidateLabel(ProviderSearchCandidate candidate) {
    return typedProviderGroupCandidateLabelBuilder?.call(candidate) ??
        (candidate is ProviderCandidate
            ? providerGroupCandidateLabelBuilder?.call(candidate)
            : null) ??
        '${candidate.title} (group)';
  }

  String providerGroupCandidateBadge(ProviderSearchCandidate candidate) {
    return typedProviderGroupCandidateBadgeBuilder?.call(candidate) ??
        (candidate is ProviderCandidate
            ? providerGroupCandidateBadgeBuilder?.call(candidate)
            : null) ??
        'group';
  }
}
