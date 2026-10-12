import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
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
  });

  static const double width = 33;
  final bool embeddedInField;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final height = embeddedInField
        ? LibraryDensityScope.of(context).metrics.fieldHeight - 2
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
                            ? Border(left: BorderSide(color: palette.divider))
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
                                child: SvgPicture.asset(
                                    AppIcons.pickListManageSvg,
                                    width: embeddedInField ? 14 : 16,
                                    height: embeddedInField ? 14 : 16,
                                    colorFilter: ColorFilter.mode(
                                        onPressed == null
                                            ? foreground.withValues(alpha: .45)
                                            : foreground,
                                        BlendMode.srcIn)))))))));
  }
}
