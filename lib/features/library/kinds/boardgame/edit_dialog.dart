import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:flutter/material.dart';

class BoardGameLibraryEditDialog extends StatelessWidget {
  const BoardGameLibraryEditDialog(
      {super.key, required this.request, this.draft});

  final LibraryEditDialogRequest request;
  final LibraryEditShellState? draft;

  @override
  Widget build(BuildContext context) {
    final resolvedDraft = draft ?? LibraryEditShellState.fromRequest(request);
    return LibraryEditRenderer.fromDraft(
      draft: resolvedDraft,
      onPrevious: request.onPrevious,
      onNext: request.onNext,
      scope: request.resolvedScope,
    );
  }
}

Widget buildBoardGameLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return BoardGameLibraryEditDialog(
    request: request,
    draft: LibraryEditShellState.fromRequest(request),
  );
}
