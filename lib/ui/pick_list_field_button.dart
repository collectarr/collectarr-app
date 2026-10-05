import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// List action integrated into the right edge of a form field.
class PickListFieldButton extends StatelessWidget {
  const PickListFieldButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.height = kLibraryFormControlHeight - 2,
  });

  static const double width = 33;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Null lets a positioned button fill a multiple-line chip field.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground =
        palette.isDark ? const Color(0xffcccccc) : palette.textMuted;
    return Tooltip(
        message: tooltip,
        child: Semantics(
            button: true,
            enabled: onPressed != null,
            child: SizedBox(
                width: width,
                height: height,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: palette.isDark
                                    ? const Color(0xff666666)
                                    : palette.divider))),
                    child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: onPressed,
                            mouseCursor: onPressed == null
                                ? SystemMouseCursors.basic
                                : SystemMouseCursors.click,
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(3)),
                            child: Icon(Icons.format_list_bulleted,
                                size: 18,
                                color: onPressed == null
                                    ? foreground.withValues(alpha: .45)
                                    : foreground)))))));
  }
}
