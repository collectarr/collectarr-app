import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/default_kind_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:flutter/material.dart';

Widget buildMusicLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  final resolvedRequest = request.scope == LibraryEditScope.all
      ? request.copyWith(scope: LibraryEditScope.media)
      : request;
  return buildDefaultKindEditDialog(request: resolvedRequest);
}
