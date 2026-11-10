import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/features/library/edit/session/commit_scope.dart';
import 'package:collectarr_app/ui/app_progress_dialog.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

/// A draft stays mounted until its owner explicitly permits leaving it.
Future<bool> confirmLeaveLibraryEdit(
  BuildContext context, {
  required bool hasUnsavedChanges,
}) async {
  if (!hasUnsavedChanges) return true;
  return await showAppDialog<bool>(
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

/// Next and Previous: saves an item with changes and shows the neighbouring
/// one in the same dialog. As in the reference, the item disappears behind
/// its "Saving" window, which stays up until the next item is shown.
/// Validation errors bring the item back.
Future<void> saveAndShowLibraryEditNeighbour(
  BuildContext context, {
  required bool hasUnsavedChanges,
  required Future<void> Function() save,
  required Future<void> Function() show,
}) async {
  final commits = LibraryEditCommitScope.maybeOf(context);
  if (commits == null) {
    if (await confirmLeaveLibraryEdit(context,
            hasUnsavedChanges: hasUnsavedChanges) &&
        context.mounted) {
      await show();
    }
    return;
  }
  commits.hidden.value = true;
  try {
    await runWithBusyDialog<void>(
      context: context,
      title: 'Saving ${commits.itemLabel}',
      // The hidden dialog's barrier already dims the page.
      barrierColor: Colors.transparent,
      task: () async {
        if (hasUnsavedChanges && !await commits.saveKeepingOpen(save)) {
          return;
        }
        commits.pendingSwitch = null;
        await show();
        await commits.pendingSwitch;
      },
    );
  } finally {
    commits.hidden.value = false;
  }
}
