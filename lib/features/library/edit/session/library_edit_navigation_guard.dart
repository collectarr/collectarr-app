import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

/// A draft stays mounted until its owner explicitly permits leaving it.
Future<bool> confirmLeaveLibraryEdit(
  BuildContext context, {
  required bool hasUnsavedChanges,
}) async {
  if (!hasUnsavedChanges) return true;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AccentAlertDialog(
          title: const Text('Unsaved changes'),
          content: const Text(
            'This item has unsaved changes. Keep editing or discard them before leaving.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard changes'),
            ),
          ],
        ),
      ) ==
      true;
}
