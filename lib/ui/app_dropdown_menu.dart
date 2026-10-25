import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The reference's editor dropdown menus: a #444 menu with a #666 rim, where
/// the hovered and the current row share the #666 shade (white, #DDD in the
/// light theme).
final class AppDropdownMenuStyle {
  const AppDropdownMenuStyle._(
      {required this.background, required this.border, required this.shade});

  factory AppDropdownMenuStyle.of(BuildContext context) {
    final palette = appPalette(context);
    return palette.isDark
        ? const AppDropdownMenuStyle._(
            background: Color(0xff444444),
            border: Color(0xff666666),
            shade: Color(0xff666666))
        : AppDropdownMenuStyle._(
            background: palette.panelRaised,
            border: palette.divider,
            shade: palette.divider);
  }

  final Color background;
  final Color border;

  /// Fills the hovered row and the current one.
  final Color shade;

  /// Rows are 32 px with 7 px side padding.
  static const double rowHeight = 32;

  /// The reference's 6 px 12 px shadow.
  static const double elevation = 6;

  ShapeBorder get shape => RoundedRectangleBorder(
      borderRadius: kAppMenuBorderRadius, side: BorderSide(color: border));

  /// Wraps [entry] so hovering it paints [shade].
  PopupMenuEntry<T> shaded<T>(PopupMenuEntry<T> entry) =>
      _ShadedMenuEntry(entry: entry, shade: shade);

  /// A plain 32 px row; [current] marks the value the field holds.
  PopupMenuEntry<T> row<T>(
          {required T value, required Widget child, bool current = false}) =>
      shaded(PopupMenuItem<T>(
          value: value,
          height: rowHeight,
          padding: EdgeInsets.zero,
          child: Container(
              height: rowHeight,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              color: current ? shade : null,
              child: child)));
}

class _ShadedMenuEntry<T> extends PopupMenuEntry<T> {
  const _ShadedMenuEntry({required this.entry, required this.shade});
  final PopupMenuEntry<T> entry;
  final Color shade;

  @override
  double get height => entry.height;

  @override
  bool represents(T? value) => entry.represents(value);

  @override
  State<_ShadedMenuEntry<T>> createState() => _ShadedMenuEntryState<T>();
}

class _ShadedMenuEntryState<T> extends State<_ShadedMenuEntry<T>> {
  @override
  Widget build(BuildContext context) => Theme(
      data: Theme.of(context).copyWith(
          hoverColor: widget.shade,
          highlightColor: Colors.transparent,
          focusColor: widget.shade),
      child: widget.entry);
}
