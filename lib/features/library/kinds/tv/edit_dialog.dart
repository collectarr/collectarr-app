import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:flutter/material.dart';

Widget buildTvLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return LibraryEditRenderer.fromDraft(
    draft: LibraryEditShellState.fromRequest(request),
    onPrevious: request.onPrevious,
    onNext: request.onNext,
    scope: request.resolvedScope,
  );
}
