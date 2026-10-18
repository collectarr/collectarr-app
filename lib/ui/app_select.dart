import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A select that opens a compact list like the reference: #444 menu with a
/// #666 outline, square corners and 25 px rows, scrolling after 20 rows.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.decoration,
    this.hint,
    this.style,
  });

  final T? value;

  /// Option values with the text shown for each.
  final List<(T, String)> options;
  final ValueChanged<T?>? onChanged;
  final InputDecoration decoration;
  final Widget? hint;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textStyle = style ??
        TextStyle(
            color: palette.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14);
    return Theme(
      data: Theme.of(context).copyWith(
          highlightColor: Colors.transparent,
          hoverColor:
              palette.isDark ? const Color(0xFF555555) : palette.surfaceBright),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        initialValue: value,
        hint: hint,
        decoration: decoration,
        style: textStyle,
        icon: const Icon(Icons.expand_more, size: 16),
        dropdownColor:
            palette.isDark ? const Color(0xFF444444) : palette.surface,
        borderRadius: BorderRadius.circular(2),
        itemHeight: null,
        menuMaxHeight: 25.0 * 20,
        items: [
          for (final (option, label) in options)
            DropdownMenuItem<T>(
                value: option,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Text(label, overflow: TextOverflow.ellipsis))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
