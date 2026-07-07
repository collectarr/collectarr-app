import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:flutter/material.dart';

Widget buildAnimeLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return buildMovieLibraryEditDialog(context, request);
}
