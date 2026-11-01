import 'package:collectarr_app/features/library/add/dialog.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:flutter/material.dart';

Future<LibraryAddDialogResult?> showLibraryAddDialog({
  required BuildContext context,
  required LibraryKindRegistration type,
  Color? accent,
  String? initialQuery,
  String? initialIdentifier,
  bool startManually = false,
}) {
  final request = LibraryAddDialogRequest(
    type: type,
    accent: accent,
    initialQuery: initialQuery,
    initialIdentifier: initialIdentifier,
  );
  return _showDefaultLibraryAddDialog(context, request, startManually);
}

Future<LibraryAddDialogResult?> _showDefaultLibraryAddDialog(
  BuildContext context,
  LibraryAddDialogRequest request,
  bool startManually,
) {
  if (isMobileApp) {
    return Navigator.of(context, rootNavigator: true)
        .push<LibraryAddDialogResult>(
      MaterialPageRoute<LibraryAddDialogResult>(
        fullscreenDialog: true,
        builder: (context) => LibraryAddDialog(
          type: request.type,
          accent: request.accent,
          initialQuery: request.initialQuery,
          initialIdentifier: request.initialIdentifier,
          startManually: startManually,
        ),
      ),
    );
  }
  return showAppDialog<LibraryAddDialogResult>(
    context: context,
    barrierDismissible: false,
    // Add Manually brings its own barrier; the Add dialog stays hidden.
    barrierColor: startManually ? Colors.transparent : kAppDialogBarrierColor,
    builder: (context) => LibraryAddDialog(
      type: request.type,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialIdentifier: request.initialIdentifier,
      startManually: startManually,
    ),
  );
}
