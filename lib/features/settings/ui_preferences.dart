import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DetailsPanelTemplate { application, light, dark, blue }

AppThemePalette detailsPanelPalette(
        BuildContext context, DetailsPanelTemplate template) =>
    switch (template) {
      DetailsPanelTemplate.application => appPalette(context),
      DetailsPanelTemplate.light => kLightAppThemePalette,
      DetailsPanelTemplate.dark => kDefaultAppThemePalette,
      DetailsPanelTemplate.blue => kDefaultAppThemePalette.copyWith(
          panel: const Color(0xff233143),
          surface: const Color(0xff344359),
          panelRaised: const Color(0xff344359),
          toolbar: const Color(0xff233143)),
    };

class UiPreferences {
  const UiPreferences({
    this.animationsEnabled = true,
    this.disableLibrarySwitchAnimation = false,
    this.disableLibraryCoverPrewarm = false,
    this.flatCovers = false,
    this.gridSpacing = 10.0,
    this.showCoverTitles = true,
    this.fabAddButton = false,
    this.cardCoverWidth = 72.0,
    this.sidebarRowPadding = 4.0,
    this.showInspectorBackdrop = true,
    this.showInspectorBackCover = true,
    this.wrapColumnContent = true,
    this.autoSizeColumns = false,
    this.showCollectionIndicators = true,
    this.showEditIcons = true,
    this.detailsPanelTemplate = DetailsPanelTemplate.application,
    this.confirmRemoval = true,
    this.confirmDuplication = true,
    this.showEbayLinks = true,
    this.ebayWishlistOnly = false,
    this.ebayToolbar = true,
    this.ebayNextToCover = true,
    this.ebayLinksSection = true,
    this.isLoaded = false,
  });

  final bool animationsEnabled;
  final bool disableLibrarySwitchAnimation;
  final bool disableLibraryCoverPrewarm;

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

  final bool showInspectorBackdrop;
  final bool showInspectorBackCover;
  final bool wrapColumnContent;
  final bool autoSizeColumns;
  final bool showCollectionIndicators;
  final bool showEditIcons;
  final DetailsPanelTemplate detailsPanelTemplate;
  final bool confirmRemoval;
  final bool confirmDuplication;
  final bool showEbayLinks;
  final bool ebayWishlistOnly;
  final bool ebayToolbar;
  final bool ebayNextToCover;
  final bool ebayLinksSection;
  final bool isLoaded;

  bool allowsEbayLinks(bool isWishlisted) =>
      showEbayLinks && (!ebayWishlistOnly || isWishlisted);

  UiPreferences copyWith({
    bool? animationsEnabled,
    bool? disableLibrarySwitchAnimation,
    bool? disableLibraryCoverPrewarm,
    bool? flatCovers,
    double? gridSpacing,
    bool? showCoverTitles,
    bool? fabAddButton,
    double? cardCoverWidth,
    double? sidebarRowPadding,
    bool? showInspectorBackdrop,
    bool? showInspectorBackCover,
    bool? wrapColumnContent,
    bool? autoSizeColumns,
    bool? showCollectionIndicators,
    bool? showEditIcons,
    DetailsPanelTemplate? detailsPanelTemplate,
    bool? confirmRemoval,
    bool? confirmDuplication,
    bool? showEbayLinks,
    bool? ebayWishlistOnly,
    bool? ebayToolbar,
    bool? ebayNextToCover,
    bool? ebayLinksSection,
    bool? isLoaded,
  }) {
    return UiPreferences(
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      disableLibrarySwitchAnimation:
          disableLibrarySwitchAnimation ?? this.disableLibrarySwitchAnimation,
      disableLibraryCoverPrewarm:
          disableLibraryCoverPrewarm ?? this.disableLibraryCoverPrewarm,
      flatCovers: flatCovers ?? this.flatCovers,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      showCoverTitles: showCoverTitles ?? this.showCoverTitles,
      fabAddButton: fabAddButton ?? this.fabAddButton,
      cardCoverWidth: cardCoverWidth ?? this.cardCoverWidth,
      sidebarRowPadding: sidebarRowPadding ?? this.sidebarRowPadding,
      showInspectorBackdrop:
          showInspectorBackdrop ?? this.showInspectorBackdrop,
      showInspectorBackCover:
          showInspectorBackCover ?? this.showInspectorBackCover,
      wrapColumnContent: wrapColumnContent ?? this.wrapColumnContent,
      autoSizeColumns: autoSizeColumns ?? this.autoSizeColumns,
      showCollectionIndicators:
          showCollectionIndicators ?? this.showCollectionIndicators,
      showEditIcons: showEditIcons ?? this.showEditIcons,
      detailsPanelTemplate: detailsPanelTemplate ?? this.detailsPanelTemplate,
      confirmRemoval: confirmRemoval ?? this.confirmRemoval,
      confirmDuplication: confirmDuplication ?? this.confirmDuplication,
      showEbayLinks: showEbayLinks ?? this.showEbayLinks,
      ebayWishlistOnly: ebayWishlistOnly ?? this.ebayWishlistOnly,
      ebayToolbar: ebayToolbar ?? this.ebayToolbar,
      ebayNextToCover: ebayNextToCover ?? this.ebayNextToCover,
      ebayLinksSection: ebayLinksSection ?? this.ebayLinksSection,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class UiPreferencesStore {
  const UiPreferencesStore();

  static const _prefix = 'collectarr.ui';
  static const animationsEnabledKey = '$_prefix.animations_enabled';
  static const disableLibrarySwitchAnimationKey =
      '$_prefix.disable_library_switch_animation';
  static const disableLibraryCoverPrewarmKey =
      '$_prefix.disable_library_cover_prewarm';
  static const flatCoversKey = '$_prefix.flat_covers';
  static const gridSpacingKey = '$_prefix.grid_spacing';
  static const showCoverTitlesKey = '$_prefix.show_cover_titles';
  static const fabAddButtonKey = '$_prefix.fab_add_button';
  static const cardCoverWidthKey = '$_prefix.card_cover_width';
  static const sidebarRowPaddingKey = '$_prefix.sidebar_row_padding';

  static const showInspectorBackdropKey = '$_prefix.show_inspector_backdrop';

  static const showInspectorBackCoverKey = '$_prefix.show_inspector_back_cover';

  static const wrapColumnContentKey = '$_prefix.wrap_column_content';

  static const autoSizeColumnsKey = '$_prefix.auto_size_columns';

  static const showCollectionIndicatorsKey =
      '$_prefix.show_collection_indicators';

  static const showEditIconsKey = '$_prefix.show_edit_icons';

  static const detailsPanelTemplateKey = '$_prefix.details_panel_template';

  static const confirmRemovalKey = '$_prefix.confirm_removal';

  static const confirmDuplicationKey = '$_prefix.confirm_duplication';

  static const showEbayLinksKey = '$_prefix.show_ebay_links';

  static const ebayWishlistOnlyKey = '$_prefix.ebay_wishlist_only';

  static const ebayToolbarKey = '$_prefix.ebay_toolbar';

  static const ebayNextToCoverKey = '$_prefix.ebay_next_to_cover';

  static const ebayLinksSectionKey = '$_prefix.ebay_links_section';

  Future<UiPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();
    return UiPreferences(
      animationsEnabled: prefs.getBool(animationsEnabledKey) ?? true,
      disableLibrarySwitchAnimation:
          prefs.getBool(disableLibrarySwitchAnimationKey) ?? false,
      disableLibraryCoverPrewarm:
          prefs.getBool(disableLibraryCoverPrewarmKey) ?? false,
      flatCovers: prefs.getBool(flatCoversKey) ?? false,
      gridSpacing: prefs.getDouble(gridSpacingKey) ?? 10.0,
      showCoverTitles: prefs.getBool(showCoverTitlesKey) ?? true,
      fabAddButton: prefs.getBool(fabAddButtonKey) ?? false,
      cardCoverWidth: prefs.getDouble(cardCoverWidthKey) ?? 72.0,
      sidebarRowPadding: prefs.getDouble(sidebarRowPaddingKey) ?? 4.0,
      showInspectorBackdrop: prefs.getBool(showInspectorBackdropKey) ?? true,
      showInspectorBackCover: prefs.getBool(showInspectorBackCoverKey) ?? true,
      wrapColumnContent: prefs.getBool(wrapColumnContentKey) ?? true,
      autoSizeColumns: prefs.getBool(autoSizeColumnsKey) ?? false,
      showCollectionIndicators:
          prefs.getBool(showCollectionIndicatorsKey) ?? true,
      showEditIcons: prefs.getBool(showEditIconsKey) ?? true,
      detailsPanelTemplate: DetailsPanelTemplate.values
              .where((value) =>
                  value.name == prefs.getString(detailsPanelTemplateKey))
              .firstOrNull ??
          DetailsPanelTemplate.application,
      confirmRemoval: prefs.getBool(confirmRemovalKey) ?? true,
      confirmDuplication: prefs.getBool(confirmDuplicationKey) ?? true,
      showEbayLinks: prefs.getBool(showEbayLinksKey) ?? true,
      ebayWishlistOnly: prefs.getBool(ebayWishlistOnlyKey) ?? false,
      ebayToolbar: prefs.getBool(ebayToolbarKey) ?? true,
      ebayNextToCover: prefs.getBool(ebayNextToCoverKey) ?? true,
      ebayLinksSection: prefs.getBool(ebayLinksSectionKey) ?? true,
      isLoaded: true,
    );
  }

  Future<void> write(UiPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(animationsEnabledKey, preferences.animationsEnabled);
    await prefs.setBool(
      disableLibrarySwitchAnimationKey,
      preferences.disableLibrarySwitchAnimation,
    );
    await prefs.setBool(
      disableLibraryCoverPrewarmKey,
      preferences.disableLibraryCoverPrewarm,
    );
    await prefs.setBool(
        showInspectorBackdropKey, preferences.showInspectorBackdrop);
    await prefs.setBool(
        showInspectorBackCoverKey, preferences.showInspectorBackCover);
    await prefs.setBool(wrapColumnContentKey, preferences.wrapColumnContent);
    await prefs.setBool(autoSizeColumnsKey, preferences.autoSizeColumns);
    await prefs.setBool(
        showCollectionIndicatorsKey, preferences.showCollectionIndicators);
    await prefs.setBool(showEditIconsKey, preferences.showEditIcons);
    await prefs.setString(
        detailsPanelTemplateKey, preferences.detailsPanelTemplate.name);
    await prefs.setBool(confirmRemovalKey, preferences.confirmRemoval);
    await prefs.setBool(confirmDuplicationKey, preferences.confirmDuplication);
    await prefs.setBool(showEbayLinksKey, preferences.showEbayLinks);
    await prefs.setBool(ebayWishlistOnlyKey, preferences.ebayWishlistOnly);
    await prefs.setBool(ebayToolbarKey, preferences.ebayToolbar);
    await prefs.setBool(ebayNextToCoverKey, preferences.ebayNextToCover);
    await prefs.setBool(ebayLinksSectionKey, preferences.ebayLinksSection);
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

  Future<void> setShowInspectorBackdrop(bool value) =>
      _update((s) => s.copyWith(showInspectorBackdrop: value));

  Future<void> setShowInspectorBackCover(bool value) =>
      _update((s) => s.copyWith(showInspectorBackCover: value));

  Future<void> setWrapColumnContent(bool value) =>
      _update((s) => s.copyWith(wrapColumnContent: value));

  Future<void> setAutoSizeColumns(bool value) =>
      _update((s) => s.copyWith(autoSizeColumns: value));

  Future<void> setShowCollectionIndicators(bool value) =>
      _update((s) => s.copyWith(showCollectionIndicators: value));

  Future<void> setShowEditIcons(bool value) =>
      _update((s) => s.copyWith(showEditIcons: value));

  Future<void> setDetailsPanelTemplate(DetailsPanelTemplate value) =>
      _update((s) => s.copyWith(detailsPanelTemplate: value));

  Future<void> setConfirmRemoval(bool value) =>
      _update((s) => s.copyWith(confirmRemoval: value));

  Future<void> setConfirmDuplication(bool value) =>
      _update((s) => s.copyWith(confirmDuplication: value));

  Future<void> setShowEbayLinks(bool value) =>
      _update((s) => s.copyWith(showEbayLinks: value));

  Future<void> setEbayWishlistOnly(bool value) =>
      _update((s) => s.copyWith(ebayWishlistOnly: value));

  Future<void> setEbayToolbar(bool value) =>
      _update((s) => s.copyWith(ebayToolbar: value));

  Future<void> setEbayNextToCover(bool value) =>
      _update((s) => s.copyWith(ebayNextToCover: value));

  Future<void> setEbayLinksSection(bool value) =>
      _update((s) => s.copyWith(ebayLinksSection: value));

  Future<void> resetDefaults() =>
      _update((_) => const UiPreferences(isLoaded: true));
}
