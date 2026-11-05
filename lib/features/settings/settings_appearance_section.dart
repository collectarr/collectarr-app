import 'kind_settings_controls.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/localization/app_languages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/features/settings/title_case_exceptions_dialog.dart';
import 'package:collectarr_app/core/utils/title_case.dart';
import 'ebay_search_preferences.dart';
import 'dart:async';
import 'package:collectarr_app/features/settings/local_font_settings_panel.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/state/theme_mode_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';
import 'package:collectarr_app/features/settings/settings_kind_section.dart';
import 'package:collectarr_app/features/library/home/catalog.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/nav_preferences.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';

/// Shared and kind-specific customization settings.
class SettingsAppearanceSection extends ConsumerStatefulWidget {
  const SettingsAppearanceSection(
      {super.key, required this.groups, this.initialKind});

  final List<SettingsKindGroup> groups;
  final String? initialKind;

  @override
  ConsumerState<SettingsAppearanceSection> createState() =>
      _SettingsAppearanceSectionState();
}

class _SettingsAppearanceSectionState
    extends ConsumerState<SettingsAppearanceSection> {
  String? _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectInitialKind();
  }

  @override
  void didUpdateWidget(covariant SettingsAppearanceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialKind != widget.initialKind) _selectInitialKind();
  }

  void _selectInitialKind() {
    _selectedTab = widget.groups
        .where((group) =>
            group.types.any((type) => type.kind.apiValue == widget.initialKind))
        .firstOrNull
        ?.id;
  }

  @override
  Widget build(BuildContext context) =>
      _buildAppearanceSection(ref.watch(uiPreferencesProvider));

  Widget _buildAppearanceSection(UiPreferences preferences) {
    final controller = ref.read(uiPreferencesProvider.notifier);
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final catalog =
        ref.watch(mediaCatalogProvider).value ?? fallbackMediaCatalog;
    final availableKinds = orderedLibraryHomeTypes(catalog, navPreferences);
    final modules = settingsKindGroups([
      for (final type in availableKinds)
        if (defaultLibraryKindRegistry.tryGet(type.mediaKind)
            case final registration?)
          registration,
    ]);
    final visibleCount = modules
        .where((group) =>
            navPreferences.isVisible(group.primaryType.kind.apiValue))
        .length;
    // The reference Settings page: Customization, Localization, Behaviour
    // and Sorting on the left; Auto Capitalization and eBay links on the
    // right.
    final customization = SettingsPanel(
        icon: Icons.palette_outlined,
        title: 'General',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SettingsGroupPair(
            left: SettingsGroup(
              legend: 'Application Skin',
              child: SettingsSelect<ThemeMode>(
                value: ref.watch(appThemeModeProvider),
                values: const [
                  ThemeMode.system,
                  ThemeMode.light,
                  ThemeMode.dark
                ],
                labelOf: (mode) => switch (mode) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                },
                onChanged: (mode) =>
                    ref.read(appThemeModeProvider.notifier).setMode(mode),
              ),
            ),
            right: SettingsGroup(
              legend: 'Template for Details Panel',
              child: SettingsSelect<DetailsPanelTemplate>(
                value: preferences.detailsPanelTemplate,
                values: DetailsPanelTemplate.values,
                labelOf: (value) => value == DetailsPanelTemplate.application
                    ? 'Follow application'
                    : value.name[0].toUpperCase() + value.name.substring(1),
                onChanged: controller.setDetailsPanelTemplate,
              ),
            ),
          ),
          const SettingsLegend('Details Panel'),
          const KindSettingsControls(),
          SettingsCheck(
              label: 'Show backdrop',
              value: preferences.showInspectorBackdrop,
              onChanged: controller.setShowInspectorBackdrop),
          SettingsCheck(
              label: 'Show back cover if space is available',
              value: preferences.showInspectorBackCover,
              onChanged: controller.setShowInspectorBackCover),
          const SizedBox(height: 10),
          const SettingsLegend('List View'),
          SettingsCheck(
              label: 'Wrap column content',
              value: preferences.wrapColumnContent,
              onChanged: controller.setWrapColumnContent),
          SettingsCheck(
              label: 'Auto-size column widths',
              value: preferences.autoSizeColumns,
              onChanged: controller.setAutoSizeColumns),
          SettingsCheck(
              label: 'Show Collection Status indicators',
              value: preferences.showCollectionIndicators,
              onChanged: controller.setShowCollectionIndicators),
          SettingsCheck(
              label: 'Show pencil icons (for editing)',
              value: preferences.showEditIcons,
              onChanged: controller.setShowEditIcons),
          const SizedBox(height: 10),
          const SettingsLegend('Motion'),
          SettingsCheck(
              label: 'Animations',
              value: preferences.animationsEnabled,
              onChanged: controller.setAnimationsEnabled),
          const SizedBox(height: 10),
          const SettingsLegend('Enabled libraries'),
          for (final group in modules)
            SettingsCheck(
              key: ValueKey('settings.library.enabled.${group.id}'),
              label: group.title,
              value: navPreferences.isVisible(group.primaryType.kind.apiValue),
              onChanged: navPreferences
                          .isVisible(group.primaryType.kind.apiValue) &&
                      visibleCount <= 1
                  ? null
                  : (visible) => ref
                      .read(libraryNavPreferencesProvider.notifier)
                      .setKindVisible(group.primaryType.kind.apiValue, visible,
                          availableKinds:
                              availableKinds.map((item) => item.kind)),
            ),
          Text('Keep at least one library enabled.',
              style: TextStyle(
                  fontSize: 12, color: appPalette(context).textMuted)),
        ]));
    final localization = SettingsPanel(
        icon: Icons.language,
        title: 'Localization',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // The reference's languages with their flags; Collectarr is
          // English-only so far, so the others are listed but disabled.
          SettingsGroup(
            legend: 'Application Language',
            child: SettingsSelect<AppLanguage>(
                value: kAppLanguages.first,
                values: kAppLanguages,
                labelOf: (language) => language.translated
                    ? language.nativeName
                    : '${language.nativeName} (not translated yet)',
                leadingOf: (language) => SvgPicture.asset(language.flagAsset,
                    width: 21, height: 16, fit: BoxFit.fill),
                isOptionEnabled: (language) => language.translated,
                onChanged: (_) {}),
          ),
          SettingsGroup(
            legend: 'Time zone',
            child: SettingsSelect<String>(
                value: preferences.formats.timeZone,
                values: [
                  deviceTimeZone,
                  if (preferences.formats.timeZone != deviceTimeZone &&
                      !kTimeZones.contains(preferences.formats.timeZone))
                    preferences.formats.timeZone,
                  for (var i = 0; i < kTimeZones.length; i++) ...[
                    if (i == 0 ||
                        kTimeZones[i].split('/').first !=
                            kTimeZones[i - 1].split('/').first)
                      '@${kTimeZones[i].split('/').first}',
                    kTimeZones[i],
                  ],
                ],
                labelOf: (value) => value.startsWith('@')
                    ? value.substring(1)
                    : timeZoneLabel(value),
                isOptionEnabled: (value) => !value.startsWith('@'),
                onChanged: (tz) => controller
                    .setFormats(preferences.formats.copyWith(timeZone: tz))),
          ),
          SettingsGroupPair(
            left: SettingsGroup(
              legend: 'Currency',
              child: SettingsSelect<String>(
                value: preferences.formats.currency,
                values: kCurrencyCodes,
                labelOf: (code) => code,
                // As in the reference, a new currency starts on its default
                // display, since the choices depend on the currency.
                onChanged: (code) => controller.setFormats(preferences.formats
                    .copyWith(
                        currency: code,
                        currencyDisplay: defaultCurrencyDisplay(code))),
              ),
            ),
            right: SettingsGroup(
              legend: 'Currency display',
              child: SettingsSelect<CurrencyDisplay>(
                value: currencyDisplaysFor(preferences.formats.currency)
                        .contains(preferences.formats.currencyDisplay)
                    ? preferences.formats.currencyDisplay
                    : CurrencyDisplay.symbol,
                values: currencyDisplaysFor(preferences.formats.currency),
                labelOf: (value) =>
                    currencyLabel(preferences.formats.currency, value),
                onChanged: (value) => controller.setFormats(
                    preferences.formats.copyWith(currencyDisplay: value)),
              ),
            ),
          ),
          SettingsGroup(
            legend: 'Number format',
            child: SettingsSelect<NumberFormatStyle>(
              value: preferences.formats.number,
              values: NumberFormatStyle.values,
              labelOf: (value) => value.example,
              onChanged: (value) => controller
                  .setFormats(preferences.formats.copyWith(number: value)),
            ),
          ),
          SettingsGroupPair(
            left: SettingsGroup(
              legend: 'Date format (for displaying)',
              child: SettingsSelect<DateDisplayFormat>(
                value: preferences.formats.date,
                values: DateDisplayFormat.values,
                labelOf: (value) => value.example,
                onChanged: (value) => controller
                    .setFormats(preferences.formats.copyWith(date: value)),
              ),
            ),
            right: SettingsGroup(
              legend: 'Date format (when editing)',
              child: SettingsSelect<DateEntryOrder>(
                value: preferences.formats.dateEntry,
                values: DateEntryOrder.values,
                labelOf: (value) => value.label,
                onChanged: (value) => controller
                    .setFormats(preferences.formats.copyWith(dateEntry: value)),
              ),
            ),
          ),
        ]));
    final behaviour = SettingsPanel(
        icon: Icons.help_outline,
        title: 'Behaviour',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SettingsLegend('Ask for confirmation'),
          SettingsCheck(
              label: 'when removing items',
              value: preferences.confirmRemoval,
              onChanged: controller.setConfirmRemoval),
          SettingsCheck(
              label: 'when duplicating items',
              value: preferences.confirmDuplication,
              onChanged: controller.setConfirmDuplication),
        ]));
    final sorting = SettingsPanel(
        icon: Icons.sort_by_alpha,
        title: 'Sorting',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SettingsLegend('When sorting...'),
          SettingsCheck(
              label: 'ignore sort titles',
              value: preferences.ignoreSortTitles,
              onChanged: controller.setIgnoreSortTitles),
          SettingsCheck(
              label: 'ignore sort names for Persons',
              value: preferences.ignoreSortNames,
              onChanged: controller.setIgnoreSortNames),
          const SizedBox(height: 10),
          const SettingsLegend('When displaying...'),
          SettingsCheck(
              label: 'show sort titles',
              value: preferences.showSortTitles,
              onChanged: controller.setShowSortTitles),
          SettingsCheck(
              label: 'show sort names for Persons',
              value: preferences.showSortNames,
              onChanged: controller.setShowSortNames),
        ]));
    final autoCap = SettingsPanel(
        icon: Icons.text_format,
        title: 'Auto Capitalization',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SettingsLegend('Auto Cap item titles'),
          SettingsCheck(
              label: 'when adding from Core',
              value: preferences.autocapFromCore,
              onChanged: controller.setAutocapFromCore),
          SettingsCheck(
              label: 'as you type in edit screen',
              value: preferences.autocapAsYouType,
              onChanged: controller.setAutocapAsYouType),
          const SizedBox(height: 10),
          SettingsGroup(
            legend: 'Auto Cap Method',
            child: SettingsSelect<TitleCaseMethod>(
              value: preferences.titleCaseMethod,
              values: TitleCaseMethod.values,
              labelOf: (method) => method.label,
              onChanged: controller.setTitleCaseMethod,
            ),
          ),
          SettingsBlockButton(
            label: 'Manage Exceptions',
            onPressed: preferences.titleCaseMethod !=
                    TitleCaseMethod.eachWordWithExceptions
                ? null
                : () async {
                    final updated = await showTitleCaseExceptionsDialog(context,
                        exceptions: preferences.titleCaseExceptions);
                    if (updated != null) {
                      await controller.setTitleCaseExceptions(updated);
                    }
                  },
          ),
        ]));
    final ebay = SettingsPanel(
        icon: Icons.shopping_bag_outlined,
        title: 'eBay search links',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SettingsLegend('Show/Hide eBay links'),
          SettingsRadio<bool>(
              label: 'Show eBay links',
              value: true,
              groupValue: preferences.showEbayLinks,
              onChanged: controller.setShowEbayLinks),
          SettingsRadio<bool>(
              label: 'Hide all eBay links',
              value: false,
              groupValue: preferences.showEbayLinks,
              onChanged: controller.setShowEbayLinks),
          const SizedBox(height: 10),
          const SettingsLegend('Show based on Collection Status'),
          SettingsRadio<bool>(
              label: 'Show for all entries',
              value: false,
              groupValue: preferences.ebayWishlistOnly,
              onChanged: controller.setEbayWishlistOnly),
          SettingsRadio<bool>(
              label: 'Show for Wish List entries only',
              value: true,
              groupValue: preferences.ebayWishlistOnly,
              onChanged: controller.setEbayWishlistOnly),
          const SizedBox(height: 10),
          const SettingsLegend('eBay link position'),
          SettingsCheck(
              label: 'Toolbar',
              value: preferences.ebayToolbar,
              onChanged: controller.setEbayToolbar),
          SettingsCheck(
              label: 'Details panel: next to cover',
              value: preferences.ebayNextToCover,
              onChanged: controller.setEbayNextToCover),
          SettingsCheck(
              label: 'Details panel: Links section',
              value: preferences.ebayLinksSection,
              onChanged: controller.setEbayLinksSection),
          const SizedBox(height: 10),
          const SettingsLegend('eBay search filter'),
          for (final filter in EbaySearchFilter.values) ...[
            SettingsRadio<EbaySearchFilter>(
                label: filter.label,
                value: filter,
                groupValue: preferences.ebaySearchFilter,
                onChanged: controller.setEbaySearchFilter),
            if (filter == EbaySearchFilter.automatic)
              Padding(
                padding: const EdgeInsets.only(left: 23, bottom: 4),
                child: Text(
                    'shows “All eBay listings” for Wish List entries and '
                    '“Sold listings only” for other entries.',
                    style: TextStyle(
                        fontSize: 12, color: appPalette(context).textMuted)),
              ),
          ],
          const SizedBox(height: 10),
          SettingsGroup(
            legend: 'eBay region',
            child: SettingsSelect<EbayRegion>(
              value: preferences.ebayRegion,
              values: EbayRegion.values,
              labelOf: (region) => region.label,
              onChanged: controller.setEbayRegion,
            ),
          ),
        ]));
    final selectedGroup =
        widget.groups.indexWhere((group) => group.id == _selectedTab);
    final initialIndex = _selectedTab == '@typography'
        ? widget.groups.length + 1
        : selectedGroup < 0
            ? 0
            : selectedGroup + 1;
    return DefaultTabController(
      key: ValueKey(
          'customization:${widget.initialKind}:${widget.groups.map((group) => '${group.id}:${group.types.map((type) => type.kind.apiValue).join(',')}').join('|')}'),
      initialIndex: initialIndex,
      length: widget.groups.length + 2,
      child: Column(children: [
        TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          onTap: (index) {
            _selectedTab = index == 0
                ? null
                : index == widget.groups.length + 1
                    ? '@typography'
                    : widget.groups[index - 1].id;
          },
          tabs: [
            const Tab(text: 'General'),
            for (final group in widget.groups)
              Tab(
                  key: ValueKey('settings.kind.tab.${group.id}'),
                  text: group.title),
            const Tab(text: 'Typography'),
          ],
        ),
        Expanded(
            child: TabBarView(children: [
          SettingsTabBody.columns(
            left: [customization, localization, behaviour, sorting],
            right: [
              autoCap,
              ebay,
            ],
            footer: SettingsResetAction(
                label: 'Reset customization defaults',
                onReset: _resetAppearanceDefaults),
          ),
          for (final group in widget.groups)
            SettingsKindSection(
                key: ValueKey('settings.kind.${group.id}'), types: group.types),
          const SettingsTabBody(twoColumns: true, children: [
            SettingsPanel(
                icon: Icons.text_fields_outlined,
                title: 'Typography',
                child: LocalFontSettingsPanel()),
          ]),
        ])),
      ]),
    );
  }

  Future<void> _resetAppearanceDefaults() async {
    await ref.read(uiPreferencesProvider.notifier).resetDefaults();
    if (mounted) {
      showSettingsToast('Customization defaults restored',
          tone: AppToastTone.success);
    }
  }
}
