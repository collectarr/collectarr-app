import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:flutter/material.dart';

class GameLibraryEditDialog extends StatelessWidget {
  const GameLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryEditRenderer.fromRequest(request: request);
  }
}

Widget buildGameLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return GameLibraryEditDialog(request: request);
}
