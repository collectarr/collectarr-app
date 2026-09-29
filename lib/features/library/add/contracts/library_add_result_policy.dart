import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

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

  bool valueFor(String id, {bool fallback = false}) => values[id] ?? fallback;

  LibraryAddResultPolicyState withValue(String id, bool value) =>
      LibraryAddResultPolicyState(
        values: Map.unmodifiable({...values, id: value}),
      );
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

  bool optionIsEnabled(String id) =>
      state.valueFor(id, fallback: defaultValues[id] ?? false);
}

class LibraryAddResultPolicy {
  const LibraryAddResultPolicy({
    this.options = const [],
    this.initialState = const LibraryAddResultPolicyState(),
    this.useGridResults = false,
    this.coreResultVisibility,
    this.coreGroupTitleBuilder,
    this.coreGroupArtistBuilder,
  });

  const LibraryAddResultPolicy.identity() : this();

  final List<LibraryAddResultOption> options;
  final LibraryAddResultPolicyState initialState;
  final bool useGridResults;
  final LibraryAddCoreResultVisibilityPredicate? coreResultVisibility;
  final LibraryAddCoreGroupTitleBuilder? coreGroupTitleBuilder;
  final LibraryAddCoreGroupArtistBuilder? coreGroupArtistBuilder;

  LibraryAddResultPolicyContext context({
    required LibraryAddResultPolicyState state,
    Set<CatalogEntityRef> ownedCatalogRefs = const {},
  }) =>
      LibraryAddResultPolicyContext(
        state: state,
        ownedCatalogRefs: ownedCatalogRefs,
        defaultValues: {
          for (final option in options) option.id: option.initialValue,
        },
      );

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
    if (predicate == null) return items;
    return items
        .where((item) => predicate(item, resultContext))
        .toList(growable: false);
  }

  String coreGroupTitle(CatalogSearchCandidate item) {
    final title = coreGroupTitleBuilder?.call(item).trim();
    return title == null || title.isEmpty ? item.summary.primaryLabel : title;
  }

  String? coreGroupArtist(CatalogSearchCandidate item) {
    final artist = coreGroupArtistBuilder?.call(item)?.trim();
    return artist == null || artist.isEmpty ? null : artist;
  }
}
