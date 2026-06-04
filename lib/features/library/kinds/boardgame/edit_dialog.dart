import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:flutter/material.dart';

class BoardGameLibraryEditDialog extends StatelessWidget {
  const BoardGameLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryEditRenderer.fromDraft(
      draft: LibraryEditDraft.fromRequest(request),
      onPrevious: request.onPrevious,
      onNext: request.onNext,
    );
  }
}

Widget buildBoardGameLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return BoardGameLibraryEditDialog(request: request);
}
