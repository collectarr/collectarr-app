import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/localization/app_languages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/features/settings/title_case_exceptions_dialog.dart';
import 'package:collectarr_app/core/utils/title_case.dart';
import 'ebay_search_preferences.dart';
import 'package:collectarr_app/features/settings/library_layout_setting.dart';
import 'dart:async';
import 'package:collectarr_app/features/settings/local_font_settings_panel.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/core_data_settings_dialog.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/state/theme_mode_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';

/// Settings > Appearance: the reference Settings page and cover options.
class SettingsAppearanceSection extends ConsumerStatefulWidget {
  const SettingsAppearanceSection({super.key});

  @override
  ConsumerState<SettingsAppearanceSection> createState() =>
      _SettingsAppearanceSectionState();
}

class _SettingsAppearanceSectionState
    extends ConsumerState<SettingsAppearanceSection> {
  @override
  Widget build(BuildContext context) =>
      _buildAppearanceSection(ref.watch(uiPreferencesProvider));

  Widget _buildAppearanceSection(UiPreferences preferences) {
    final controller = ref.read(uiPreferencesProvider.notifier);
    // The shell resolves the kind from the route, also on a reload.
    final kindIdentity = libraryKindRegistrationForKind(
            catalogMediaKindFromValue(
                LibraryAccentScope.maybeOf(context)?.kind ??
                    ref.watch(selectedLibraryKindProvider)))
        .identity;
    final kindPlural = kindIdentity.pluralLabel.toLowerCase();
    final kindSingular = kindIdentity.singularLabel.toLowerCase();
    // The reference Settings page: Customization, Localization, Behaviour
    // and Sorting on the left; Auto Capitalization and eBay links on the
    // right.
    final customization = SettingsPanel(
        icon: Icons.palette_outlined,
        title: 'Customization',
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
          SettingsGroupPair(
            left: const SettingsGroup(
                legend: 'Main Screen Layout', child: LibraryLayoutSetting()),
            right: const SizedBox.shrink(),
          ),
          const SettingsLegend('Details Panel'),
          if (kindIdentity.hasTrailers)
            SettingsCheck(
                label: 'Show trailer videos',
                value: preferences.showInspectorTrailers,
                onChanged: controller.setShowInspectorTrailers),
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
        ]));
    final localization = SettingsPanel(
        icon: Icons.language,
        title: 'Localization',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // The reference's languages with their flags; Collectarr is
          // English-only so far, so the others are listed but disabled. The
          // time zone follows the device.
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
                value: 'Device time zone',
                values: const ['Device time zone'],
                labelOf: (value) => value,
                onChanged: null),
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
              label: 'when removing $kindPlural',
              value: preferences.confirmRemoval,
              onChanged: controller.setConfirmRemoval),
          SettingsCheck(
              label: 'when duplicating $kindPlural',
              value: preferences.confirmDuplication,
              onChanged: controller.setConfirmDuplication),
          const SizedBox(height: 10),
          const SettingsLegend('Adding from Core'),
          SettingsBlockButton(
            label: 'Add/Update from Core settings',
            onPressed: () => showCoreDataSettingsDialog(
                context: context,
                accent: kindIdentity.accent,
                kind: kindIdentity.kind),
          ),
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
          SettingsLegend('Auto Cap $kindSingular titles'),
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
    return DefaultTabController(
      length: 3,
      child: Column(children: [
        const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(text: 'Customization'),
              Tab(text: 'Covers & layout'),
              Tab(text: 'Typography'),
            ]),
        Expanded(
            child: TabBarView(children: [
          SettingsTabBody.columns(
            left: [customization, localization, behaviour, sorting],
            right: [autoCap, ebay],
            footer: SettingsResetAction(
                label: 'Reset appearance defaults',
                onReset: _resetAppearanceDefaults),
          ),
          _buildCoverAppearanceSection(preferences),
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

  Widget _buildCoverAppearanceSection(UiPreferences uiPreferences) {
    return SettingsTabBody(
      children: [
        SettingsPanel(
          icon: Icons.motion_photos_auto_outlined,
          title: 'Appearance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Cover grid',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.grid_view_sharp),
                title: const Text('Flat covers'),
                subtitle: const Text(
                  'Remove the shadow from cover tiles.',
                ),
                value: uiPreferences.flatCovers,
                onChanged: (value) => ref
                    .read(uiPreferencesProvider.notifier)
                    .setFlatCovers(value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.title),
                title: const Text('Show titles in grid'),
                subtitle: const Text(
                  'Show title text below covers in grid view.',
                ),
                value: uiPreferences.showCoverTitles,
                onChanged: (value) => ref
                    .read(uiPreferencesProvider.notifier)
                    .setShowCoverTitles(value),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.space_bar),
                title: const Text('Grid spacing'),
                subtitle: AppSlider(
                  value: uiPreferences.gridSpacing.clamp(4.0, 24.0),
                  min: 4,
                  max: 24,
                  divisions: 20,
                  label:
                      '${uiPreferences.gridSpacing.clamp(4.0, 24.0).round()} px',
                  onChanged: (value) => ref
                      .read(uiPreferencesProvider.notifier)
                      .setGridSpacing(value.roundToDouble()),
                ),
              ),
              const Divider(height: 24),
              Text('Card view',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.photo_size_select_large),
                title: const Text('Card cover width'),
                subtitle: AppSlider(
                  value: uiPreferences.cardCoverWidth.clamp(60.0, 120.0),
                  min: 60,
                  max: 120,
                  divisions: 12,
                  label:
                      '${uiPreferences.cardCoverWidth.clamp(60.0, 120.0).round()} px',
                  onChanged: (value) => ref
                      .read(uiPreferencesProvider.notifier)
                      .setCardCoverWidth(value.roundToDouble()),
                ),
              ),
              const Divider(height: 24),
              Text('Layout',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.add_circle_outline),
                title: const Text('Floating Add button'),
                subtitle: const Text(
                  'Use a floating action button instead of inline toolbar button.',
                ),
                value: uiPreferences.fabAddButton,
                onChanged: (value) => ref
                    .read(uiPreferencesProvider.notifier)
                    .setFabAddButton(value),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.density_small),
                title: const Text('Sidebar row padding'),
                subtitle: AppSlider(
                  value: uiPreferences.sidebarRowPadding.clamp(0.0, 8.0),
                  min: 0,
                  max: 8,
                  divisions: 8,
                  label:
                      '${uiPreferences.sidebarRowPadding.clamp(0.0, 8.0).round()} px',
                  onChanged: (value) => ref
                      .read(uiPreferencesProvider.notifier)
                      .setSidebarRowPadding(value.roundToDouble()),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _resetAppearanceDefaults,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset appearance defaults'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _resetAppearanceDefaults() async {
    await ref.read(uiPreferencesProvider.notifier).resetDefaults();
    if (mounted) {
      showSettingsToast('Appearance defaults restored',
          tone: AppToastTone.success);
    }
  }
}
