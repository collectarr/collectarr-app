import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

Color pickListSurface(BuildContext context) => appPalette(context).isDark
    ? const Color(0xff262626)
    : appPalette(context).panel;
Color pickListToolbar(BuildContext context) => appPalette(context).isDark
    ? const Color(0xff464950)
    : appPalette(context).panelRaised;
Color pickListRow(BuildContext context, int index) => appPalette(context).isDark
    ? index.isEven
        ? const Color(0xff262626)
        : const Color(0xff2b2b2b)
    : index.isEven
        ? appPalette(context).tableEvenRow
        : appPalette(context).tableOddRow;

InputDecoration pickListInputDecoration(BuildContext context,
    {String? hintText, Widget? suffixIcon}) {
  final palette = appPalette(context);
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(
          color: palette.isDark ? const Color(0xff666666) : palette.divider));
  return InputDecoration(
      hintText: hintText,
      isDense: true,
      filled: true,
      fillColor: palette.isDark ? const Color(0xff444444) : palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
          borderSide: BorderSide(color: palette.accent, width: 2)),
      suffixIconConstraints:
          const BoxConstraints.tightFor(width: 30, height: 30),
      suffixIcon: suffixIcon);
}
