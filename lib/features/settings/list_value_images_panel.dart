import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared image loading and removal; each kind supplies its list and wording.
class ListValueImagesPanel extends ConsumerWidget {
  const ListValueImagesPanel({
    super.key,
    required this.list,
    required this.description,
    this.previewBuilder,
  });

  final String list;
  final String description;
  final Widget Function(String value)? previewBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values =
        ref.watch(listValueImageValuesProvider(list)).value ?? const <String>[];
    final images = ref.read(listValueImagesProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(description,
          style: TextStyle(color: appPalette(context).textMuted, fontSize: 13)),
      const SizedBox(height: 8),
      if (values.isNotEmpty) ...[
        Wrap(spacing: 10, runSpacing: 6, children: [
          for (final value in values)
            Row(mainAxisSize: MainAxisSize.min, children: [
              previewBuilder?.call(value) ??
                  _ImagePreview(list: list, value: value),
              const SizedBox(width: 4),
              Flexible(
                  child: Text(value, style: const TextStyle(fontSize: 13))),
            ]),
        ]),
        const SizedBox(height: 8),
      ],
      SettingsBlockButton(
          label: 'Load icons from files...',
          onPressed: () async {
            final messenger = ScaffoldMessenger.maybeOf(context);
            final result = await images.loadFiles(list);
            if (result.loaded > 0 || result.skipped.isNotEmpty) {
              messenger?.showSnackBar(
                  SnackBar(content: Text(listValueImagesLoadMessage(result))));
            }
          }),
      if (values.isNotEmpty) ...[
        const SizedBox(height: 6),
        SettingsBlockButton(
            label: 'Remove all ${values.length} loaded icons',
            onPressed: () => images.removeAll(list)),
      ],
    ]);
  }
}

class _ImagePreview extends ConsumerWidget {
  const _ImagePreview({required this.list, required this.value});

  final String list;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image =
        ref.watch(listValueImageProvider((list: list, value: value))).value;
    return SizedBox(
        width: 72,
        height: 24,
        child: image == null ? null : ListValueImageView(image));
  }
}
