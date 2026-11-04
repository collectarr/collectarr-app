import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LibraryNavPlacement { top, left }

class LibraryNavPreferences {
  const LibraryNavPreferences({
    this.order = const [],
    this.hiddenKinds = const {},
    this.accentHexByKind = const {},
    this.placement = LibraryNavPlacement.top,
    this.collapsed = false,
  });

  final List<String> order;
  final Set<String> hiddenKinds;
  final Map<String, int> accentHexByKind;
  final LibraryNavPlacement placement;
  final bool collapsed;

  LibraryNavPreferences copyWith({
    List<String>? order,
    Set<String>? hiddenKinds,
    Map<String, int>? accentHexByKind,
    LibraryNavPlacement? placement,
    bool? collapsed,
  }) {
    return LibraryNavPreferences(
      order: order ?? this.order,
      hiddenKinds: hiddenKinds ?? this.hiddenKinds,
      accentHexByKind: accentHexByKind ?? this.accentHexByKind,
      placement: placement ?? this.placement,
      collapsed: collapsed ?? this.collapsed,
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

  bool isHidden(String kind) => hiddenKinds.contains(_moduleKind(kind));

  bool isVisible(String kind) => !isHidden(kind);
}

class LibraryNavPreferencesStore {
  const LibraryNavPreferencesStore();

  static const _orderKey = 'collectarr.library_nav.order';
  static const _hiddenKey = 'collectarr.library_nav.hidden';
  static const _accentByKindKey = 'collectarr.library_nav.accent_by_kind';
  static const _placementKey = 'collectarr.library_nav.placement';
  static const _collapsedKey = 'collectarr.library_nav.collapsed';

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
      accentHexByKind: {
        for (final entry
            in prefs.getStringList(_accentByKindKey) ?? const <String>[])
          if (_parseAccentEntry(entry) case final parsed?) parsed.$1: parsed.$2,
      },
      placement: _placementByName(prefs.getString(_placementKey)),
      collapsed: prefs.getBool(_collapsedKey) ?? false,
    );
  }

  Future<void> write(LibraryNavPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_orderKey, preferences.order);
    await prefs.setStringList(
      _hiddenKey,
      preferences.hiddenKinds.toList(growable: false),
    );
    await prefs.setStringList(
      _accentByKindKey,
      [
        for (final entry in preferences.accentHexByKind.entries)
          '${entry.key}:${entry.value.toRadixString(16)}',
      ],
    );
    await prefs.setString(_placementKey, preferences.placement.name);
    await prefs.setBool(_collapsedKey, preferences.collapsed);
  }

  (String, int)? _parseAccentEntry(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }
    final kind = _normalizeKind(parts.first);
    if (kind.isEmpty) {
      return null;
    }
    final accent = int.tryParse(parts.last, radix: 16);
    if (accent == null) {
      return null;
    }
    return (kind, accent);
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

final libraryNavPreferencesProvider =
    NotifierProvider<LibraryNavPreferencesController, LibraryNavPreferences>(
  LibraryNavPreferencesController.new,
);

class LibraryNavPreferencesController extends Notifier<LibraryNavPreferences> {
  final LibraryNavPreferencesStore _store = const LibraryNavPreferencesStore();
  int _revision = 0;

  @override
  LibraryNavPreferences build() {
    load();
    return const LibraryNavPreferences();
  }

  Future<void> load() async {
    final revision = _revision;
    final loaded = await _store.read();
    if (revision != _revision) return;
    state = loaded;
    _cachedLibraryAccentHexByKind = state.accentHexByKind;
  }

  Future<void> toggleCollapsed() async {
    await _save(state.copyWith(collapsed: !state.collapsed));
  }

  Future<void> setKindVisible(String kind, bool visible,
      {required Iterable<String> availableKinds}) async {
    final normalized = _moduleKind(kind);
    final available = availableKinds.map(_moduleKind).toSet();
    if (!available.contains(normalized)) return;
    final hidden = {
      for (final item in state.hiddenKinds)
        if (_moduleKind(item) == _normalizeKind(item)) _normalizeKind(item),
    };
    if (visible) {
      hidden.remove(normalized);
    } else {
      if (available.where((item) => !hidden.contains(item)).length <= 1) return;
      hidden.add(normalized);
    }
    await _save(state.copyWith(hiddenKinds: hidden));
  }

  Future<void> reset() async {
    await _save(const LibraryNavPreferences());
  }

  Future<void> _save(LibraryNavPreferences preferences) async {
    _revision++;
    state = preferences;
    _cachedLibraryAccentHexByKind = preferences.accentHexByKind;
    await _store.write(preferences);
  }
}

Map<String, int> _cachedLibraryAccentHexByKind = const {};

int? cachedLibraryAccentHexForKind(CatalogMediaKind kind) {
  return _cachedLibraryAccentHexByKind[kind.apiValue];
}

String _normalizeKind(String kind) => kind.trim().toLowerCase();

/// Kinds in one collection family share their top-level module's visibility.
String _moduleKind(String kind) {
  final normalized = _normalizeKind(kind);
  final registry = defaultLibraryKindRegistry;
  final family = registry
      .tryGet(catalogMediaKindFromValue(normalized))
      ?.identity
      .collectionFamily;
  if (family == null) return normalized;
  for (final registration in registry.allKinds) {
    if (registration.identity.collectionFamily == family &&
        registration.identity.isTopLevel) {
      return registration.kind.apiValue;
    }
  }
  return normalized;
}
