import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/generic_library_edit_dialog.dart';
import 'package:flutter/material.dart';

Widget buildGenericLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return GenericLibraryEditDialog(request: request);
}