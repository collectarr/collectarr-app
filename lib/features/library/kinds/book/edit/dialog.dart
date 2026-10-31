import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/edit/shell/dialog.dart';
import 'package:flutter/material.dart';

Widget buildBookLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return LibraryEditRenderer.fromRequest(request: request);
}
