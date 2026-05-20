import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LibraryNavPlacement { top, left }

class LibraryNavPreferences {
  const LibraryNavPreferences({
    this.order = const [],
    this.hiddenKinds = const {},
    this.placement = LibraryNavPlacement.top,
  });

  final List<String> order;
  final Set<String> hiddenKinds;
  final LibraryNavPlacement placement;

  LibraryNavPreferences copyWith({
    List<String>? order,
    Set<String>? hiddenKinds,
    LibraryNavPlacement? placement,
  }) {
    return LibraryNavPreferences(
      order: order ?? this.order,
      hiddenKinds: hiddenKinds ?? this.hiddenKinds,
      placement: placement ?? this.placement,
    );
  }

  List<String> orderedKinds(Iterable<String> availableKinds) {
    final available = {
      for (final kind in availableKinds) _normalizeKind(kind),
    }..remove('');
    final ordered = <String>[
      for (final kind in order)
        if (available.contains(_normalizeKind(kind))) _normalizeKind(kind),
    ];
    for (final kind in available) {
      if (!ordered.contains(kind)) {
        ordered.add(kind);
      }
    }
    return ordered;
  }

  bool isHidden(String kind) => hiddenKinds.contains(_normalizeKind(kind));

  bool isVisible(String kind) => !isHidden(kind);
}

class LibraryNavPreferencesStore {
  const LibraryNavPreferencesStore();

  static const _orderKey = 'collectarr.library_nav.order';
  static const _hiddenKey = 'collectarr.library_nav.hidden';
  static const _placementKey = 'collectarr.library_nav.placement';

  Future<LibraryNavPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();
    return LibraryNavPreferences(
      order: [
        for (final kind in prefs.getStringList(_orderKey) ?? const <String>[])
          if (_normalizeKind(kind).isNotEmpty) _normalizeKind(kind),
      ],
      hiddenKinds: {
        for (final kind in prefs.getStringList(_hiddenKey) ?? const <String>[])
          if (_normalizeKind(kind).isNotEmpty) _normalizeKind(kind),
      },
      placement: _placementByName(prefs.getString(_placementKey)),
    );
  }

  Future<void> write(LibraryNavPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_orderKey, preferences.order);
    await prefs.setStringList(
      _hiddenKey,
      preferences.hiddenKinds.toList(growable: false),
    );
    await prefs.setString(_placementKey, preferences.placement.name);
  }

  static LibraryNavPlacement _placementByName(String? name) {
    for (final placement in LibraryNavPlacement.values) {
      if (placement.name == name) {
        return placement;
      }
    }
    return LibraryNavPlacement.top;
  }
}

final libraryNavPreferencesProvider = StateNotifierProvider<
    LibraryNavPreferencesController, LibraryNavPreferences>(
  (ref) => LibraryNavPreferencesController()..load(),
);

class LibraryNavPreferencesController
    extends StateNotifier<LibraryNavPreferences> {
  LibraryNavPreferencesController({
    LibraryNavPreferencesStore store = const LibraryNavPreferencesStore(),
  })  : _store = store,
        super(const LibraryNavPreferences());

  final LibraryNavPreferencesStore _store;

  Future<void> load() async {
    state = await _store.read();
  }

  Future<void> setPlacement(LibraryNavPlacement placement) async {
    await _save(state.copyWith(placement: placement));
  }

  Future<void> setOrder(List<String> order) async {
    await _save(
      state.copyWith(order: [
        for (final kind in order)
          if (_normalizeKind(kind).isNotEmpty) _normalizeKind(kind),
      ]),
    );
  }

  Future<void> setKindVisible(String kind, bool visible) async {
    final normalized = _normalizeKind(kind);
    if (normalized.isEmpty) {
      return;
    }
    final hidden = {...state.hiddenKinds};
    if (visible) {
      hidden.remove(normalized);
    } else {
      hidden.add(normalized);
    }
    await _save(state.copyWith(hiddenKinds: hidden));
  }

  Future<void> reset() async {
    await _save(const LibraryNavPreferences());
  }

  Future<void> _save(LibraryNavPreferences preferences) async {
    state = preferences;
    await _store.write(preferences);
  }
}

String _normalizeKind(String kind) => kind.trim().toLowerCase();
