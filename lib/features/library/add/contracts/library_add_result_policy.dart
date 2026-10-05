import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

typedef LibraryAddCoreResultVisibilityPredicate = bool Function(
  CatalogSearchCandidate item,
  LibraryAddResultPolicyContext context,
);

class LibraryAddResultOption {
  const LibraryAddResultOption({
    required this.id,
    required this.label,
    this.initialValue = true,
  });

  final String id;
  final String label;
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

class LibraryAddResultPolicy {
  const LibraryAddResultPolicy({
    this.options = const [],
    this.initialState = const LibraryAddResultPolicyState(),
    this.useGridResults = false,
    this.coreResultVisibility,
  });

  const LibraryAddResultPolicy.identity() : this();

  final List<LibraryAddResultOption> options;
  final LibraryAddResultPolicyState initialState;
  final bool useGridResults;
  final LibraryAddCoreResultVisibilityPredicate? coreResultVisibility;

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
