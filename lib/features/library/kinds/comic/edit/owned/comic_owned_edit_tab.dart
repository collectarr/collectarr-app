import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/owned/comic_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/owned/comic_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:flutter/material.dart';

Widget buildComicOwnedEditSchemaTab({required ComicEditDraft comicDraft}) {
  return EditSchemaRenderer<ComicOwnedDetails, ComicOwnedEditDraft>(
    schema: comicOwnedEditSchema,
    model: comicDraft.ownedEdit.toDetails(),
    draft: comicDraft.ownedEdit,
    showTabBar: false,
    showFooter: false,
    onSave: (_) {},
    onCancel: () {},
  );
}