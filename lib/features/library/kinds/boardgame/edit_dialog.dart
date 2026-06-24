import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/default_kind_edit_dialog.dart';
import 'package:flutter/material.dart';

class BoardGameLibraryEditDialog extends StatelessWidget {
  const BoardGameLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return buildDefaultKindEditDialog(request: request);
  }
}

Widget buildBoardGameLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return BoardGameLibraryEditDialog(request: request);
}
