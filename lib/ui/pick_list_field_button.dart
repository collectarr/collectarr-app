import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/features/library/ui/density_scope.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// List action integrated into the right edge of a form field.
class PickListFieldButton extends StatelessWidget {
  const PickListFieldButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.embeddedInField = true,
    this.bottomBorder = false,
    this.highlighted = false,
    this.icon = AppIcons.viewHorizontalCards,
  });

  static const double width = 33;
  final bool embeddedInField;

  /// Closes the button off below, for fields that grow past one row while
  /// the button stays on the first, as in the reference.
  final bool bottomBorder;

  /// Sets the button off with a blue rule while the field's menu is open.
  final bool highlighted;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final height = embeddedInField
        ? LibraryDensityScope.of(context).metrics.fieldHeight -
            (bottomBorder ? 1 : 2)
        : 30.0;
    final foreground =
        embeddedInField ? palette.textMuted : palette.textPrimary;
    return Tooltip(
        message: tooltip,
        child: Semantics(
            button: true,
            enabled: onPressed != null,
            child: SizedBox(
                width: embeddedInField ? width : 30,
                height: height,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        border: embeddedInField
                            ? Border(
                                left: BorderSide(
                                    color: highlighted
                                        ? palette.utilityAction
                                        : palette.divider),
                                bottom: bottomBorder
                                    ? BorderSide(color: palette.divider)
                                    : BorderSide.none)
                            : null),
                    child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: onPressed,
                            mouseCursor: onPressed == null
                                ? SystemMouseCursors.basic
                                : SystemMouseCursors.click,
                            borderRadius: embeddedInField
                                ? const BorderRadius.horizontal(
                                    right: Radius.circular(3))
                                : BorderRadius.circular(3),
                            child: Center(
                                child: Icon(icon,
                                    size: 16,
                                    color: onPressed == null
                                        ? foreground.withValues(alpha: .45)
                                        : foreground))))))));
  }
}
