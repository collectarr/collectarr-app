import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:flutter/material.dart';

Widget buildMangaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return buildComicLibraryEditDialog(context, request);
}
