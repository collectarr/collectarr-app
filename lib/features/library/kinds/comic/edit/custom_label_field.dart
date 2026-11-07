import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/managed_vocabulary_field.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:collectarr_app/features/library/ui/density_scope.dart';
import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom Label with the image the user loaded for it inside the field and
/// its menu rows, as in the reference. The app ships no label images: the
/// user loads them from their own files in the pick list, one label at a time
/// or a folder's worth named after their labels, and those names join the
/// list. The native editor has no pick list button, so it keeps its own.
class ComicCustomLabelField extends ConsumerWidget {
  const ComicCustomLabelField(
      {required this.value, required this.onChanged, super.key});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = LibraryManagedVocabularyField(
      label: 'Custom Label',
      listName: _list,
      mediaKind: 'comic',
      value: value,
      showImages: true,
      builtIns:
          ref.watch(listValueImageValuesProvider(_list)).value ?? const [],
      onChanged: onChanged,
    );
    if (!LibraryMobileEditFormScope.active(context)) return field;
    return Row(children: [
      Expanded(child: field),
      const SizedBox(width: 4),
      _CustomLabelImageButton(label: value),
    ]);
  }
}

/// The list the images are kept for.
final _list = ComicVocabularyIds.customLabel.value;

enum _ImageAction { choose, remove, loadFiles }

class _CustomLabelImageButton extends ConsumerWidget {
  const _CustomLabelImageButton({required this.label});

  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final name = label?.trim() ?? '';
    final image = name.isEmpty
        ? null
        : ref.watch(listValueImageProvider((list: _list, value: name))).value;
    final height = LibraryDensityScope.of(context).metrics.fieldHeight;
    return PopupMenuButton<_ImageAction>(
      tooltip: 'Custom Label image',
      onSelected: (action) => _run(context, ref, action, name),
      itemBuilder: (context) => [
        PopupMenuItem(
            value: _ImageAction.choose,
            enabled: name.isNotEmpty,
            child: Text(name.isEmpty
                ? 'Choose an image for this label...'
                : 'Choose an image for "$name"...')),
        if (image != null)
          const PopupMenuItem(
              value: _ImageAction.remove, child: Text('Remove the image')),
        const PopupMenuItem(
            value: _ImageAction.loadFiles,
            child: Text('Load label images from files...')),
      ],
      child: Container(
        width: height * 2,
        height: height,
        decoration: BoxDecoration(
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(3)),
        alignment: Alignment.center,
        child: Icon(AppIcons.tabImages, size: 15, color: palette.textMuted),
      ),
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, _ImageAction action,
      String name) async {
    final images = ref.read(listValueImagesProvider);
    final messenger = ScaffoldMessenger.maybeOf(context);
    void tell(String message) =>
        messenger?.showSnackBar(SnackBar(content: Text(message)));
    switch (action) {
      case _ImageAction.remove:
        await images.remove(_list, name);
      case _ImageAction.choose:
        final problem = await chooseListValueImage(images, _list, name);
        if (problem != null) tell(problem);
      case _ImageAction.loadFiles:
        // Each file is named after its label, such as "Spawn #1.png".
        final result = await images.loadFiles(_list);
        if (result.loaded > 0 || result.skipped.isNotEmpty) {
          tell(listValueImagesLoadMessage(result));
        }
    }
  }
}
