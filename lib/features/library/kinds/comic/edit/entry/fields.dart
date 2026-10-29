import 'package:collectarr_app/features/library/forms/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'entry_draft.dart';
import 'entry_schema.dart';
import 'package:flutter/material.dart';

Widget buildComicEntryField(
        {required String id,
        required ComicEntryEditDraft draft,
        required VoidCallback onChanged}) =>
    LibraryFieldSpecRenderer<ComicEntryEditDraft>.embedded(
      key: ValueKey('comic-entry-$id'),
      schema: LibraryFormSchema(sections: [
        LibraryFormSectionSpec(
          id: id,
          label: '',
          maxColumns: 1,
          fields: [
            for (final section in comicEntryEditSchema.tabs.single.sections)
              for (final field in section.fields)
                if (field.id == id) field
          ],
        )
      ]),
      draft: draft,
      mediaKind: 'comic',
      onChanged: onChanged,
    );
