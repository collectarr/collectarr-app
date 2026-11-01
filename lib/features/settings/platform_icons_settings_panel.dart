import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Platform icons the user loads from their own files, each named after its
/// platform ("Nintendo Switch.svg"). Collectarr ships only free logos; a
/// loaded icon takes the place of the logo or glyph wherever the platform
/// shows.
class PlatformIconsSettingsPanel extends ConsumerWidget {
  const PlatformIconsSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final platforms =
        ref.watch(listValueImageValuesProvider(platformIconsList)).value ??
            const <String>[];
    final images = ref.read(listValueImagesProvider);
    Future<void> load() async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final result = await images.loadFiles(platformIconsList);
      if (result.loaded > 0 || result.skipped.isNotEmpty) {
        messenger?.showSnackBar(
            SnackBar(content: Text(listValueImagesLoadMessage(result))));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
          'Load icons from your own files, each named after its platform, '
          'such as "Nintendo Switch.svg". They replace the built-in logo '
          'wherever the platform shows.',
          style: TextStyle(color: palette.textMuted, fontSize: 13)),
      const SizedBox(height: 8),
      if (platforms.isNotEmpty) ...[
        Wrap(spacing: 10, runSpacing: 6, children: [
          for (final platform in platforms)
            Row(mainAxisSize: MainAxisSize.min, children: [
              PlatformIcon(platform, size: 18),
              const SizedBox(width: 4),
              Text(platform, style: const TextStyle(fontSize: 13)),
            ]),
        ]),
        const SizedBox(height: 8),
      ],
      SettingsBlockButton(label: 'Load icons from files...', onPressed: load),
      if (platforms.isNotEmpty) ...[
        const SizedBox(height: 6),
        SettingsBlockButton(
            label: 'Remove all ${platforms.length} loaded icons',
            onPressed: () => images.removeAll(platformIconsList)),
      ],
    ]);
  }
}
