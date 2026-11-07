import 'package:collectarr_app/features/library/forms/field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/vocabulary_options_loader.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryManagedVocabularyField extends ConsumerWidget {
  const LibraryManagedVocabularyField(
      {super.key,
      required this.label,
      required this.listName,
      required this.mediaKind,
      required this.value,
      required this.onChanged,
      this.builtIns = const [],
      this.optionLabel,
      this.enabled = true,
      this.showFieldLabel = true,
      this.showImages = false});
  final String label;
  final String listName;
  final String mediaKind;
  final String? value;
  final List<String> builtIns;
  final String Function(String value)? optionLabel;
  final bool enabled;
  final bool showFieldLabel;

  /// Shows the images loaded for the list's values, and lets its pick list
  /// choose them.
  final bool showImages;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched here so the images are ready when the menu opens on an empty
    // field, which asks for no image of its own.
    final images = showImages
        ? ref.watch(listValueImagesByKeyProvider(listName)).value ?? const {}
        : null;
    return LibraryVocabularyOptionsLoader(
      listName: listName,
      mediaKind: mediaKind,
      builtIns: builtIns,
      selected: [if (value != null) value!],
      builder: (choices) => LibraryDropdownPickField<String>(
        label: label,
        showFieldLabel: showFieldLabel,
        value: value,
        enabled: enabled,
        allowCustomValue: true,
        optionImage: images == null
            ? null
            : (option) => switch (images[listValueImageKey(option)]) {
                  final image? =>
                    ListValueImageView(image, alignment: Alignment.centerRight),
                  null => null,
                },
        options: [
          for (final choice in choices)
            LibraryFieldOption(
                value: choice, label: optionLabel?.call(choice) ?? choice)
        ],
        onChanged: onChanged,
        openPicker: (
                {required label, required selectedValue, required options}) =>
            showPickListSelectDialog(
                context: context,
                label: label,
                selectedValue: selectedValue,
                options: options,
                listName: listName,
                mediaKind: mediaKind,
                allowUserValues: true,
                showImages: showImages,
                db: ref.read(localDatabaseProvider)),
      ),
    );
  }
}
