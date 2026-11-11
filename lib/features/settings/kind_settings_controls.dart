import 'package:collectarr_app/features/settings/kind_settings_provider.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:collectarr_app/features/library/providers/nav_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kind_settings.dart';

/// Shared editor mechanics; declarations and specialized editors belong to kinds.
class KindSettingsControls extends ConsumerWidget {
  const KindSettingsControls({super.key, required this.kind});
  final CatalogMediaKind kind;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(libraryNavPreferencesProvider);
    final compatible = {
      for (final e in collectarrKindSettings.entries)
        if (nav.isVisible(e.key.apiValue)) e.key: e.value
    };
    final settings = [
      ...?collectarrKindSettings[kind]?.settings,
    ]..sort((a, b) => a.order.compareTo(b.order));
    if (settings.isEmpty) return const SizedBox.shrink();
    Future<void> save(Future<void> operation) async {
      try {
        await operation;
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not save settings: $error')));
        }
      }
    }

    return ref.watch(kindSettingsProvider).when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stack) => Column(children: [
            Text('Could not load library settings: $error'),
            TextButton(
                onPressed: () => ref.invalidate(kindSettingsProvider),
                child: const Text('Retry'))
          ]),
          data: (values) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final setting in settings)
              Builder(builder: (context) {
                final value = values.resolve(setting, kind: kind);
                final overridden = values.hasOverride(setting, kind);
                final controller = ref.read(kindSettingsProvider.notifier);
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(setting.label)),
                        setting.buildEditor(
                            context,
                            value,
                            (next) => save(
                                controller.setOverride(setting, kind, next)))
                      ]),
                      if (setting.scope ==
                          KindSettingScope.kindOverridable) ...[
                        Text(overridden
                            ? 'Overridden for this kind'
                            : 'Inherited shared setting'),
                        Wrap(children: [
                          TextButton(
                              onPressed: () => save(overridden
                                  ? controller.reset(setting, kind)
                                  : controller.setOverride(
                                      setting, kind, value)),
                              child: Text(overridden
                                  ? 'Use shared setting / Reset override'
                                  : 'Set for this kind')),
                          TextButton(
                              onPressed: () => save(
                                  controller.apply(setting, value, compatible)),
                              child:
                                  const Text('Apply to all compatible kinds')),
                        ]),
                      ],
                    ]);
              }),
          ]),
        );
  }
}
