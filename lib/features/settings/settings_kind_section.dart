import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/generic/custom_field_cache.dart';
import 'package:collectarr_app/features/library/inspector/custom_fields_section.dart';
import 'package:collectarr_app/features/library/add/mobile/method_preferences.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/features/settings/custom_fields_tab_settings_dialog.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/features/settings/core_data_settings_dialog.dart';
import 'package:collectarr_app/features/settings/library_layout_setting.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Preferences owned by a single library kind; general preferences live in Appearance.
class SettingsKindSection extends ConsumerWidget {
  const SettingsKindSection({super.key, required this.type});

  final LibraryKindRegistration type;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      SettingsTabBody(children: [
        SettingsPanel(
          icon: type.identity.icon,
          title: '${type.identity.title} settings',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SettingsGroup(
              legend: 'Main Screen Layout',
              child: LibraryLayoutSetting(
                  key: ValueKey('settings.kind.layout.${type.kind.apiValue}'),
                  kind: type.kind),
            ),
            const SizedBox(height: 12),
            const SettingsLegend('Adding and updating'),
            SettingsBlockButton(
              label: 'Add/Update from Core settings',
              onPressed: () => showCoreDataSettingsDialog(
                  context: context,
                  accent: appPalette(context).utilityAction,
                  kind: type.kind),
            ),
            const SizedBox(height: 8),
            SettingsBlockButton(
              label: 'Pre-fill settings',
              onPressed: () => showPrefillSettingsDialog(
                  context: context,
                  accent: appPalette(context).utilityAction,
                  kind: type.kind),
            ),
            const SizedBox(height: 6),
            Text('Default location and tags are shared across libraries.',
                style: TextStyle(
                    fontSize: 12, color: appPalette(context).textMuted)),
            if (appPresentationPlatform.isNativeMobile) ...[
              const SizedBox(height: 8),
              SettingsBlockButton(
                label: 'Reset default Add method',
                onPressed: () async {
                  final preferences = await SharedPreferences.getInstance();
                  await preferences
                      .remove(mobileAddDefaultMethodKey(type.kind.apiValue));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Choose an Add method next time.')));
                  }
                },
              ),
            ],
            const SizedBox(height: 14),
            const SettingsLegend('Custom fields'),
            SettingsBlockButton(
              label: 'Custom Fields tab settings',
              onPressed: () async {
                final container =
                    ProviderScope.containerOf(context, listen: false);
                final settings =
                    await CustomFieldsDisplaySettings.read(type.kind.apiValue);
                if (!context.mounted) return;
                final result = await showAppDialog<CustomFieldsDisplaySettings>(
                  context: context,
                  builder: (_) =>
                      CustomFieldsTabSettingsDialog(settings: settings),
                );
                if (result == null) return;
                await result.save(type.kind.apiValue);
                if (!context.mounted) return;
                container.invalidate(libraryCustomFieldCacheProvider);
                invalidateInspectorCustomFields(container);
              },
            ),
          ]),
        ),
      ]);
}
