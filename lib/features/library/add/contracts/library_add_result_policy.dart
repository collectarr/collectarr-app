import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

typedef LibraryAddCoreResultVisibilityPredicate = bool Function(
  CatalogSearchCandidate item,
  LibraryAddResultPolicyContext context,
);

typedef LibraryAddCoreGroupTitleBuilder = String Function(
  CatalogSearchCandidate item,
);

typedef LibraryAddCoreGroupArtistBuilder = String? Function(
  CatalogSearchCandidate item,
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
    this.coreGroupTitleBuilder,
    this.coreGroupArtistBuilder,
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
  final LibraryAddCoreGroupTitleBuilder? coreGroupTitleBuilder;
  final LibraryAddCoreGroupArtistBuilder? coreGroupArtistBuilder;
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
    return candidates;
  }

  bool isProviderGroupCandidate(ProviderSearchCandidate candidate) {
    final typedPredicate = typedProviderCandidateIsGroup;
    if (typedPredicate != null) return typedPredicate(candidate);
    return false;
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
    final fallback = candidate.title.trim();
    return fallback.isEmpty ? 'Untitled' : fallback;
  }

  String? coreGroupArtist(CatalogSearchCandidate item) {
    final artist = coreGroupArtistBuilder?.call(item)?.trim();
    return artist == null || artist.isEmpty ? null : artist;
  }

  String? providerGroupArtist(ProviderSearchCandidate candidate) {
    final artist = typedProviderGroupArtistBuilder?.call(candidate)?.trim();
    return artist == null || artist.isEmpty ? null : artist;
  }

  String providerGroupKey(ProviderSearchCandidate candidate) {
    final key = typedProviderGroupKeyBuilder?.call(candidate).trim();
    if (key != null && key.isNotEmpty) return key;
    return providerGroupTitle(candidate).toLowerCase();
  }

  int compareProviderCandidates(
    ProviderSearchCandidate left,
    ProviderSearchCandidate right,
  ) {
    return typedProviderCandidateComparator?.call(left, right) ??
        left.title.toLowerCase().compareTo(right.title.toLowerCase());
  }

  String providerGroupCandidateLabel(ProviderSearchCandidate candidate) {
    return typedProviderGroupCandidateLabelBuilder?.call(candidate) ??
        '${candidate.title} (group)';
  }

  String providerGroupCandidateBadge(ProviderSearchCandidate candidate) {
    return typedProviderGroupCandidateBadgeBuilder?.call(candidate) ?? 'group';
  }
}
