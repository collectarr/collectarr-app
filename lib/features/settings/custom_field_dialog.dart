import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

AppThemePalette customFieldPalette(BuildContext context) {
  final palette = appPalette(context);
  return palette.isDark
      ? palette.copyWith(
          surface: const Color(0xff262626),
          field: const Color(0xff444444),
          panelRaised: const Color(0xff444444),
          divider: const Color(0xff666666))
      : palette;
}

/// Shared measured geometry for the custom-field chooser and definition editor.
class CustomFieldDialog extends StatelessWidget {
  const CustomFieldDialog(
      {super.key,
      required this.title,
      required this.child,
      required this.actions});
  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final palette = customFieldPalette(context);
    final theme = Theme.of(context);
    return Theme(
        data: theme.copyWith(
            visualDensity: VisualDensity.standard,
            extensions: [
              ...theme.extensions.values
                  .where((extension) => extension is! AppThemePalette),
              palette
            ],
            inputDecorationTheme:
                theme.inputDecorationTheme.copyWith(fillColor: palette.field),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    backgroundColor: palette.divider.withValues(alpha: .55),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    visualDensity: VisualDensity.standard,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700))),
            filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    visualDensity: VisualDensity.standard,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)))),
        child: Dialog(
          alignment: Alignment.topCenter,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          backgroundColor: palette.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.sizeOf(context).height -
                    60 -
                    MediaQuery.viewInsetsOf(context).bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  height: 38,
                  child: AccentDialogHeader(
                      title: title,
                      minHeight: 38,
                      titleStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                      onClose: () => Navigator.of(context).pop())),
              Flexible(child: SingleChildScrollView(child: child)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: appManagementPanelColor(context),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    SizedBox(width: 100, height: 32, child: actions[i]),
                  ],
                ]),
              ),
            ]),
          ),
        ));
  }
}
