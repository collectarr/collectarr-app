import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:flutter/material.dart';

Widget buildComicLibraryEditDialog(
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