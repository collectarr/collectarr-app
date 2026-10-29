import 'package:collectarr_app/features/library/forms/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import '../draft.dart';
import 'entry_draft.dart';
import 'entry_schema.dart';
import 'package:flutter/material.dart';

Widget buildComicEntryFields(
    {required ComicEditDraft comicDraft, required VoidCallback onChanged}) {
  return LibraryFieldSpecRenderer<ComicEntryEditDraft>.embedded(
    schema: LibraryFormSchema(sections: [
      for (final section in comicEntryEditSchema.tabs.single.sections)
        LibraryFormSectionSpec(
          id: section.id,
          label: section.label,
          fields: [
            for (final field in section.fields)
              if (field.id != 'last_bag_board_date') field
          ],
        ),
    ]),
    draft: comicDraft.entryEdit,
    mediaKind: 'comic',
    onChanged: onChanged,
  );
}
