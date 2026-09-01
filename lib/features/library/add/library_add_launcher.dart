import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:flutter/material.dart';

Future<LibraryAddDialogResult?> showLibraryAddDialog({
  required BuildContext context,
  required LibraryKindRuntime type,
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
  final launcher = type.add.dialogLauncher ?? _showDefaultLibraryAddDialog;
  return launcher(context, request);
}

Future<LibraryAddDialogResult?> _showDefaultLibraryAddDialog(
  BuildContext context,
  LibraryAddDialogRequest request,
) {
  final windowClass = AppWindowClass.of(context);
  if (windowClass.isCompact) {
    return Navigator.of(context).push<LibraryAddDialogResult>(
      MaterialPageRoute<LibraryAddDialogResult>(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          body: SafeArea(
            child: LibraryAddDialog(
              type: request.type,
              accent: request.accent,
              initialQuery: request.initialQuery,
              initialBarcode: request.initialBarcode,
            ),
          ),
        ),
      ),
    );
  }
  return showDialog<LibraryAddDialogResult>(
    context: context,
    builder: (context) => LibraryAddDialog(
      type: request.type,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    ),
  );
}
