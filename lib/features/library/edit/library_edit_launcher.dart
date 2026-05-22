import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:flutter/material.dart';

Future<LibraryEditSelection?> showLibraryEditDialog({
  required BuildContext context,
  required LibraryEditDialogRequest request,
}) {
  final builder =
      request.type.editDialogBuilder ?? _buildDefaultLibraryEditDialog;
  return showDialog<LibraryEditSelection>(
    context: context,
    builder: (context) => builder(context, request),
  );
}

Widget _buildDefaultLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return LibraryEditDialog(
    type: request.type,
    item: request.item,
    ownedItem: request.ownedItem,
    accent: request.accent,
    physicalFormats: request.physicalFormats,
    customFieldDefinitions: request.customFieldDefinitions,
    customFieldValues: request.customFieldValues,
    itemImages: request.itemImages,
  );
}