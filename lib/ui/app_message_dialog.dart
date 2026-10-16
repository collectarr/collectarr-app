import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact centred message with Cancel and one confirming action, as the
/// reference shows before starting an export.
///
/// Returns whether the action was confirmed.
Future<bool> showAppMessageDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) async =>
    await showAppDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppMessageDialog(
          title: title, message: message, confirmLabel: confirmLabel),
    ) ==
    true;

class AppMessageDialog extends StatelessWidget {
  const AppMessageDialog(
      {super.key,
      required this.title,
      required this.message,
      required this.confirmLabel});
  final String title;
  final String message;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final background =
        palette.isDark ? const Color(0xff383838) : palette.panelRaised;
    final foreground = palette.isDark ? Colors.white : palette.textPrimary;
    return Dialog(
      // Centred on the window, unlike panels, as in the reference.
      alignment: Alignment.center,
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      shape: appDialogShape,
      elevation: 0,
      shadowColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground, fontSize: 15, height: 1.43),
          textAlign: TextAlign.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                child: Column(children: [
                  Icon(AppIcons.circleExclamation, size: 28, color: foreground),
                  const SizedBox(height: 20),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.1)),
                  const SizedBox(height: 10),
                  Text(message),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DialogActionButtons.cancel(
                        onPressed: () => Navigator.pop(context, false)),
                    const SizedBox(width: 5),
                    DialogActionButton(
                        label: confirmLabel,
                        primary: true,
                        onPressed: () => Navigator.pop(context, true)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
