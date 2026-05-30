import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:flutter/material.dart';

class GenericLibraryEditDialog extends StatelessWidget {
  const GenericLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryEditDialog.fromDraft(
      draft: LibraryEditDraft.fromRequest(request),
    );
  }
}

Widget buildGenericLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return GenericLibraryEditDialog(request: request);
}