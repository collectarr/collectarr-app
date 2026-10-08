import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_vocabulary_options_loader.dart';
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
      this.enabled = true});
  final String label;
  final String listName;
  final String mediaKind;
  final String? value;
  final List<String> builtIns;
  final String Function(String value)? optionLabel;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      LibraryVocabularyOptionsLoader(
        listName: listName,
        mediaKind: mediaKind,
        builtIns: builtIns,
        selected: [if (value != null) value!],
        builder: (choices) => LibraryDropdownPickField<String>(
          label: label,
          value: value,
          enabled: enabled,
          allowCustomValue: true,
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
                  db: ref.read(localDatabaseProvider)),
        ),
      );
}
