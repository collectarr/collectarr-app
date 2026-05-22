import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';

Future<bool?> showLibraryAddDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  Color? accent,
  String? initialQuery,
  String? initialBarcode,
}) {
  final request = LibraryAddDialogRequest(
    type: type,
    accent: accent,
    initialQuery: initialQuery,
    initialBarcode: initialBarcode,
  );
  final launcher = type.addDialogLauncher ?? _showDefaultLibraryAddDialog;
  return launcher(context, request);
}

Future<bool?> _showDefaultLibraryAddDialog(
  BuildContext context,
  LibraryAddDialogRequest request,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => LibraryAddDialog(
      type: request.type,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    ),
  );
}