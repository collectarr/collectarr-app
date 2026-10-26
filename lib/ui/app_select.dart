import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A select that opens like the reference's: the field stays in place and a
/// #444 list with a #666 outline and 25 px rows drops directly below it,
/// scrolling after 20 rows.
class AppSelect<T> extends StatefulWidget {
  const AppSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.decoration,
    this.hint,
    this.style,
    this.arrow,
    this.leadingOf,
    this.isOptionEnabled,
  });

  final T? value;

  /// Option values with the text shown for each.
  final List<(T, String)> options;
  final ValueChanged<T?>? onChanged;
  final InputDecoration decoration;
  final Widget? hint;
  final TextStyle? style;

  /// Replaces the default muted chevron, given whether the select is enabled.
  final Widget Function(bool enabled)? arrow;

  /// A widget before an option's text, in the list and in the field, such as
  /// a language's flag.
  final Widget? Function(T option)? leadingOf;

  /// Whether an option can be chosen; others are listed dimmed.
  final bool Function(T option)? isOptionEnabled;

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  static const double _rowHeight = 25;
  static const int _visibleRows = 20;

  final _controller = MenuController();
  bool _open = false;

  Widget _optionContent(T option, String label, {TextStyle? style}) {
    final text =
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    final leading = widget.leadingOf?.call(option);
    if (leading == null) return text;
    return Row(children: [
      leading,
      const SizedBox(width: 3),
      Flexible(child: text),
    ]);
  }

  String? get _selectedLabel {
    for (final (option, label) in widget.options) {
      if (option == widget.value) return label;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textStyle = widget.style ??
        TextStyle(
            color: palette.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14);
    final enabled = widget.onChanged != null;
    final menuColor =
        palette.isDark ? const Color(0xFF444444) : palette.surface;
    final outline = palette.isDark ? const Color(0xFF666666) : palette.divider;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return MenuAnchor(
        controller: _controller,
        onOpen: () => setState(() => _open = true),
        onClose: () => setState(() => _open = false),
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(menuColor),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(2),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
              side: BorderSide(color: outline))),
          minimumSize: WidgetStatePropertyAll(Size(width, 0)),
          maximumSize: WidgetStatePropertyAll(
              Size(width, _rowHeight * _visibleRows + 2)),
        ),
        menuChildren: [
          for (final (option, label) in widget.options)
            MenuItemButton(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(width, _rowHeight)),
                maximumSize: WidgetStatePropertyAll(Size(width, _rowHeight)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 7)),
                shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
                foregroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.disabled)
                        ? palette.textMuted
                        : palette.textPrimary),
                backgroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.focused)
                        ? palette.utilityAction
                        : null),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                textStyle: WidgetStatePropertyAll(textStyle),
              ),
              onPressed: widget.isOptionEnabled?.call(option) ?? true
                  ? () => widget.onChanged?.call(option)
                  : null,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: _optionContent(option, label)),
            ),
        ],
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: !enabled
                ? null
                : () => _open ? _controller.close() : _controller.open(),
            child: InputDecorator(
              decoration: widget.decoration,
              isFocused: _open,
              isEmpty: _selectedLabel == null && widget.hint == null,
              child: Row(children: [
                Expanded(
                    child: _selectedLabel != null
                        ? _optionContent(widget.value as T, _selectedLabel!,
                            style: textStyle)
                        : (widget.hint ?? const SizedBox.shrink())),
                widget.arrow?.call(enabled) ??
                    Icon(Icons.expand_more,
                        size: 16,
                        color: enabled
                            ? const Color(0xFF999999)
                            : const Color(0xFF666666)),
              ]),
            ),
          ),
        ),
      );
    });
  }
}
