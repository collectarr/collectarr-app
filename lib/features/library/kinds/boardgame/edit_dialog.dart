import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:flutter/material.dart';

class BoardGameLibraryEditDialog extends StatelessWidget {
  const BoardGameLibraryEditDialog({super.key, required this.request, this.draft});

  final LibraryEditDialogRequest request;
  final LibraryEditDraft? draft;

  @override
  Widget build(BuildContext context) {
    final resolvedDraft = draft ?? LibraryEditDraft.fromRequest(request);
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
    draft: LibraryEditDraft.fromRequest(request),
  );
}
