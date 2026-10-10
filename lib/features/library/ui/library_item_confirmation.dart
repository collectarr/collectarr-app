import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> confirmLibraryDuplication(BuildContext context, int count) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: const Text('Duplicate items'),
        content: Text('Create a copy of $count item${count == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Duplicate')),
        ],
      ),
    ) ??
    false;
