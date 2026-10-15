import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

ButtonStyle dialogActionButtonStyle(BuildContext context,
    {bool primary = false, double width = 100, Color? color}) {
  final palette = appPalette(context);
  final background = primary
      ? color ?? palette.utilityAction
      : palette.isDark
          ? const Color(0xff494949)
          : palette.panelRaised;
  final hover = HSLColor.fromColor(background);
  final hoverBackground =
      hover.withLightness((hover.lightness - .07).clamp(0.0, 1.0)).toColor();
  return FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor:
              primary || palette.isDark ? Colors.white : palette.textPrimary,
          disabledBackgroundColor:
              Color.alphaBlend(Colors.black.withValues(alpha: .45), background),
          disabledForegroundColor: Colors.white54,
          minimumSize: Size(width, 32),
          maximumSize: const Size(double.infinity, 32),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))),
          textStyle: TextStyle(
              fontFamily: appFontFamily,
              fontFamilyFallback: kAppFontFamilyFallback,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14))
      .copyWith(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return Color.alphaBlend(
            Colors.black.withValues(alpha: .45), background);
      }
      return states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.focused)
          ? hoverBackground
          : background;
    }),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
  );
}

/// Shared Cancel, OK, Close and Save geometry for panel footers.
class DialogActionButton extends StatelessWidget {
  const DialogActionButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.primary = false,
      this.icon,
      this.width = 100,
      this.color});
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = dialogActionButtonStyle(context,
        primary: primary, width: width, color: color);
    return SizedBox(
        width: width,
        height: 32,
        child: icon == null
            ? FilledButton(
                style: style, onPressed: onPressed, child: Text(label))
            : FilledButton.icon(
                style: style,
                onPressed: onPressed,
                icon: Icon(icon, size: 16),
                label: Text(label)));
  }
}

class DialogActionFooter extends StatelessWidget {
  const DialogActionFooter({super.key, required this.actions, this.leading});
  final List<Widget> actions;
  final Widget? leading;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 11, 10, 10),
        color: palette.isDark ? const Color(0xff383838) : palette.panelRaised,
        child: Row(children: [
          if (leading != null) Expanded(child: leading!) else const Spacer(),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            actions[i]
          ]
        ]));
  }
}

class DialogActionButtons {
  const DialogActionButtons._();
  static Widget cancel(
          {Key? key,
          required VoidCallback? onPressed,
          String label = 'Cancel',
          double width = 100}) =>
      DialogActionButton(
          key: key, label: label, onPressed: onPressed, width: width);
  static Widget save(
          {Key? key,
          required VoidCallback? onPressed,
          String label = 'Save',
          double width = 100,
          Color? accent}) =>
      DialogActionButton(
          key: key,
          label: label,
          onPressed: onPressed,
          width: width,
          primary: true,
          icon: Icons.save_outlined,
          color: accent);
}
