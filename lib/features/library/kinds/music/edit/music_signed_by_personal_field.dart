import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_pick_list_field.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:flutter/material.dart';

final class MusicSignedByPersonalField extends StatelessWidget {
  const MusicSignedByPersonalField(
      {super.key, required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => LibraryOrderedPickListField(
        label: 'Signed By',
        listName: MusicVocabularyIds.signedBy.value,
        mediaKind: 'music',
        loadOptions: (db) => MusicVocabularies.nameOptions(
            db, MusicVocabularyIds.signedBy.value),
        values: [
          for (final name in splitPickListValues(value))
            LibraryNamedValue(id: name, name: name)
        ],
        onChanged: (names) =>
            onChanged(joinPickListValues(names.map((value) => value.name))),
      );
}
