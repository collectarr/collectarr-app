import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:flutter/material.dart';

class ComicLibraryEditDialog extends StatelessWidget {
  const ComicLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryEditRenderer.fromDraft(
      draft: LibraryEditDraft.fromRequest(request),
      onPrevious: request.onPrevious,
      onNext: request.onNext,
      scope: request.resolvedScope,
    );
  }
}

Widget buildComicLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return ComicLibraryEditDialog(request: request);
}
