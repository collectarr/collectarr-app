import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:flutter/material.dart';

class GameLibraryEditDialog extends StatelessWidget {
  const GameLibraryEditDialog({super.key, required this.request, this.draft});

  final LibraryEditDialogRequest request;
  final LibraryEditShellState? draft;

  @override
  Widget build(BuildContext context) {
    return LibraryEditRenderer.fromRequest(request: request, draft: draft);
  }
}

Widget buildGameLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return GameLibraryEditDialog(request: request);
}
