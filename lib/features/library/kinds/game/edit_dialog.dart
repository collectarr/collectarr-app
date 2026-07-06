import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:flutter/material.dart';

class GameLibraryEditDialog extends StatelessWidget {
  const GameLibraryEditDialog({super.key, required this.request, this.draft});

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

Widget buildGameLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return GameLibraryEditDialog(
    request: request,
    draft: LibraryEditDraft.fromRequest(request),
  );
}
