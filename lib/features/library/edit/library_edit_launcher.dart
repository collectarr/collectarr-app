import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_builders.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:flutter/material.dart';

Future<LibraryEditSelection?> showLibraryEditDialog({
  required BuildContext context,
  required LibraryEditDialogRequest request,
}) {
  final builder =
      request.type.editDialogBuilder ?? buildGenericLibraryEditDialog;
  return showDialog<LibraryEditSelection>(
    context: context,
    builder: (context) => builder(context, request),
  );
}
