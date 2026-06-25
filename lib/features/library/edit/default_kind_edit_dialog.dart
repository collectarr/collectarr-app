import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:flutter/material.dart';

Widget buildDefaultKindEditDialog({
  required LibraryEditDialogRequest request,
}) {
  return LibraryEditRenderer.fromDraft(
    draft: LibraryEditDraft.fromRequest(request),
    onPrevious: request.onPrevious,
    onNext: request.onNext,
    scope: request.scope,
  );
}
