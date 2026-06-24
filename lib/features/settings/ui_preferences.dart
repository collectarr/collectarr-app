import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiPreferences {
  const UiPreferences({
    this.animationsEnabled = true,
    this.flatCovers = false,
    this.gridSpacing = 10.0,
    this.showCoverTitles = true,
    this.fabAddButton = false,
    this.cardCoverWidth = 72.0,
    this.sidebarRowPadding = 4.0,
    this.isLoaded = false,
  });

  final bool animationsEnabled;

  /// Remove shadows and borders from cover tiles for a flatter look.
  final bool flatCovers;

  /// Spacing between grid tiles in pixels (4–14).
  final double gridSpacing;

  /// Show title text below covers in grid view.
  final bool showCoverTitles;

  /// Use a floating action button for Add instead of inline toolbar button.
  final bool fabAddButton;

  /// Cover width in card view (60–120).
  final double cardCoverWidth;

  /// Vertical padding inside series sidebar rows (0–8).
  final double sidebarRowPadding;

  final bool isLoaded;

  UiPreferences copyWith({
    bool? animationsEnabled,
    bool? flatCovers,
    double? gridSpacing,
    bool? showCoverTitles,
    bool? fabAddButton,
    double? cardCoverWidth,
    double? sidebarRowPadding,
    bool? isLoaded,
  }) {
    return UiPreferences(
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      flatCovers: flatCovers ?? this.flatCovers,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      showCoverTitles: showCoverTitles ?? this.showCoverTitles,
      fabAddButton: fabAddButton ?? this.fabAddButton,
      cardCoverWidth: cardCoverWidth ?? this.cardCoverWidth,
      sidebarRowPadding: sidebarRowPadding ?? this.sidebarRowPadding,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class UiPreferencesStore {
  const UiPreferencesStore();

  static const _prefix = 'collectarr.ui';
  static const animationsEnabledKey = '$_prefix.animations_enabled';
  static const flatCoversKey = '$_prefix.flat_covers';
  static const gridSpacingKey = '$_prefix.grid_spacing';
  static const showCoverTitlesKey = '$_prefix.show_cover_titles';
  static const fabAddButtonKey = '$_prefix.fab_add_button';
  static const cardCoverWidthKey = '$_prefix.card_cover_width';
  static const sidebarRowPaddingKey = '$_prefix.sidebar_row_padding';

  Future<UiPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();
    return UiPreferences(
      animationsEnabled: prefs.getBool(animationsEnabledKey) ?? true,
      flatCovers: prefs.getBool(flatCoversKey) ?? false,
      gridSpacing: prefs.getDouble(gridSpacingKey) ?? 10.0,
      showCoverTitles: prefs.getBool(showCoverTitlesKey) ?? true,
      fabAddButton: prefs.getBool(fabAddButtonKey) ?? false,
      cardCoverWidth: prefs.getDouble(cardCoverWidthKey) ?? 72.0,
      sidebarRowPadding: prefs.getDouble(sidebarRowPaddingKey) ?? 4.0,
      isLoaded: true,
    );
  }

  Future<void> write(UiPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(animationsEnabledKey, preferences.animationsEnabled);
    await prefs.setBool(flatCoversKey, preferences.flatCovers);
    await prefs.setDouble(gridSpacingKey, preferences.gridSpacing);
    await prefs.setBool(showCoverTitlesKey, preferences.showCoverTitles);
    await prefs.setBool(fabAddButtonKey, preferences.fabAddButton);
    await prefs.setDouble(cardCoverWidthKey, preferences.cardCoverWidth);
    await prefs.setDouble(sidebarRowPaddingKey, preferences.sidebarRowPadding);
  }
}

final uiPreferencesProvider =
    NotifierProvider<UiPreferencesController, UiPreferences>(
  UiPreferencesController.new,
);

class UiPreferencesController extends Notifier<UiPreferences> {
  final UiPreferencesStore _store = const UiPreferencesStore();

  @override
  UiPreferences build() {
    load();
    return const UiPreferences();
  }

  Future<void> load() async {
    state = await _store.read();
  }

  Future<void> _update(UiPreferences Function(UiPreferences) updater) async {
    final next = updater(state).copyWith(isLoaded: true);
    state = next;
    await _store.write(next);
  }

  Future<void> setAnimationsEnabled(bool enabled) =>
      _update((s) => s.copyWith(animationsEnabled: enabled));

  Future<void> setFlatCovers(bool flat) =>
      _update((s) => s.copyWith(flatCovers: flat));

  Future<void> setGridSpacing(double spacing) =>
      _update((s) => s.copyWith(gridSpacing: spacing));

  Future<void> setShowCoverTitles(bool show) =>
      _update((s) => s.copyWith(showCoverTitles: show));

  Future<void> setFabAddButton(bool fab) =>
      _update((s) => s.copyWith(fabAddButton: fab));

  Future<void> setCardCoverWidth(double width) =>
      _update((s) => s.copyWith(cardCoverWidth: width));

  Future<void> setSidebarRowPadding(double padding) =>
      _update((s) => s.copyWith(sidebarRowPadding: padding));

  Future<void> resetDefaults() =>
      _update((_) => const UiPreferences(isLoaded: true));
}
