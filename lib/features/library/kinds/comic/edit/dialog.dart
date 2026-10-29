import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'catalog_item/catalog_item_dialog.dart';
import 'package:flutter/material.dart';

class ComicLibraryEditDialog extends StatelessWidget {
  const ComicLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return ComicItemEditDialog(request: request);
  }
}

Widget buildComicLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return ComicLibraryEditDialog(request: request);
}
