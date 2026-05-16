import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiPreferences {
  const UiPreferences({
    this.animationsEnabled = true,
    this.isLoaded = false,
  });

  final bool animationsEnabled;
  final bool isLoaded;

  UiPreferences copyWith({
    bool? animationsEnabled,
    bool? isLoaded,
  }) {
    return UiPreferences(
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class UiPreferencesStore {
  const UiPreferencesStore();

  static const animationsEnabledKey = 'collectarr.ui.animations_enabled';

  Future<UiPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();
    return UiPreferences(
      animationsEnabled: prefs.getBool(animationsEnabledKey) ?? true,
      isLoaded: true,
    );
  }

  Future<void> write(UiPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      animationsEnabledKey,
      preferences.animationsEnabled,
    );
  }
}

final uiPreferencesProvider =
    StateNotifierProvider<UiPreferencesController, UiPreferences>(
  (ref) => UiPreferencesController()..load(),
);

class UiPreferencesController extends StateNotifier<UiPreferences> {
  UiPreferencesController({
    UiPreferencesStore store = const UiPreferencesStore(),
  })  : _store = store,
        super(const UiPreferences());

  final UiPreferencesStore _store;

  Future<void> load() async {
    state = await _store.read();
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    final next = state.copyWith(
      animationsEnabled: enabled,
      isLoaded: true,
    );
    state = next;
    await _store.write(next);
  }
}
