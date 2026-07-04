import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/default_kind_edit_dialog.dart';
import 'package:flutter/material.dart';

Widget buildTvLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return buildDefaultKindEditDialog(request: request);
}
