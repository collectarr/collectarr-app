import 'package:collectarr_app/core/utils/title_case.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:flutter/material.dart';

/// Edits the words Autocap keeps lowercase inside a title. Returns the new
/// list, or null when cancelled.
Future<List<String>?> showTitleCaseExceptionsDialog(
  BuildContext context, {
  required List<String> exceptions,
}) {
  final controller = TextEditingController(text: exceptions.join('\n'));
  return showAppDialog<List<String>>(
    context: context,
    builder: (context) => AccentAlertDialog(
      headerIcon: AppIcons.edit,
      title: const Text('Manage Exceptions'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('One word per line. These stay lowercase unless they '
                'start or end a title.'),
            const SizedBox(height: 10),
            TextField(
              key: const Key('title-case-exceptions'),
              controller: controller,
              minLines: 8,
              maxLines: 14,
            ),
          ],
        ),
      ),
      actions: [
        DialogActionButton(
          label: 'Reset',
          onPressed: () =>
              controller.text = defaultTitleCaseExceptions.join('\n'),
        ),
        DialogActionButton(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButton(
          label: 'Save',
          primary: true,
          onPressed: () => Navigator.pop(context, [
            for (final line in controller.text.split(RegExp(r'[\n,]')))
              if (line.trim().isNotEmpty) line.trim().toLowerCase(),
          ]),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
