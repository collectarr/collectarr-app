import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/entry/entry_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/entry/entry_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:flutter/material.dart';

Widget buildComicEntryEditSchemaTab({required ComicEditDraft comicDraft}) {
  return EditSchemaRenderer<ComicEntryDetails, ComicEntryEditDraft>.embedded(
    schema: comicEntryEditSchema,
    model: comicDraft.entryEdit.toDetails(),
    draft: comicDraft.entryEdit,
    mediaKind: 'comic',
    showTabBar: false,
  );
}
