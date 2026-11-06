import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/ui/app_dropdown_menu.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The reference's custom select: the value in a 34 px field beside a 34 px
/// caret button, opening its menu under the field at the field's width.
class LibraryMenuSelectField<T> extends StatefulWidget {
  const LibraryMenuSelectField({
    super.key,
    required this.label,
    required this.tooltip,
    required this.display,
    required this.itemBuilder,
    required this.onSelected,
    this.background,
    this.hasValue = true,
  });

  final String label;
  final String tooltip;

  /// The current value as shown in the field.
  final Widget display;
  final PopupMenuItemBuilder<T> itemBuilder;
  final ValueChanged<T> onSelected;

  /// Paints the whole field, caret included, such as a slab label's colours;
  /// the caret button then turns transparent.
  final Gradient? background;
  final bool hasValue;

  @override
  State<LibraryMenuSelectField<T>> createState() =>
      _LibraryMenuSelectFieldState<T>();
}

class _LibraryMenuSelectFieldState<T> extends State<LibraryMenuSelectField<T>> {
  bool _open = false;
  bool _caretHovered = false;

  void _setOpen(bool open) => setState(() => _open = open);

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final menu = AppDropdownMenuStyle.of(context);
    final background = widget.background;
    final display = widget.display;
    final native =
        LibraryMobileEditFormScope.active(context) && background == null;
    // While its menu is open the field reads as focused, like the reference:
    // a blue frame, with the caret button flat and set off by a blue rule.
    final highlighted = _open && background == null;
    final fieldFill =
        Theme.of(context).inputDecorationTheme.fillColor ?? palette.surface;
    final control = LayoutBuilder(
      builder: (context, constraints) => PopupMenuButton<T>(
        popUpAnimationStyle: AnimationStyle.noAnimation,
        tooltip: widget.tooltip,
        position: PopupMenuPosition.under,
        color: menu.background,
        shape: menu.shape,
        elevation: AppDropdownMenuStyle.elevation,
        surfaceTintColor: Colors.transparent,
        menuPadding: const EdgeInsets.only(top: 5),
        constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            maxHeight: 300),
        itemBuilder: widget.itemBuilder,
        onOpened: () => _setOpen(true),
        onCanceled: () => _setOpen(false),
        onSelected: (value) {
          _setOpen(false);
          widget.onSelected(value);
        },
        child: native
            ? InputDecorator(
                isEmpty: !widget.hasValue,
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: const TextStyle(fontSize: 16),
                  floatingLabelStyle: const TextStyle(fontSize: 12),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: false,
                  fillColor: Colors.transparent,
                  border:
                      const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: palette.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: palette.utilityAction, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  constraints: const BoxConstraints(minHeight: 56),
                ),
                child: SizedBox(
                  height: 40,
                  child: Row(children: [
                    Expanded(child: display),
                    Icon(AppIcons.caretDown,
                        size: 14, color: palette.textMuted),
                  ]),
                ),
              )
            : MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  height: LibraryMetrics.defaultFieldHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: background != null ? null : fieldFill,
                        gradient: background,
                        border: Border.all(
                            color: background != null
                                ? Colors.transparent
                                : highlighted
                                    ? palette.utilityAction
                                    : palette.divider),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: display,
                        )),
                        // Hovered, the caret button sinks to the field's fill,
                        // as in the reference.
                        MouseRegion(
                            onEnter: (_) =>
                                setState(() => _caretHovered = true),
                            onExit: (_) =>
                                setState(() => _caretHovered = false),
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: background != null || highlighted
                                        ? Colors.transparent
                                        : _caretHovered
                                            ? fieldFill
                                            : palette.divider,
                                    border: highlighted
                                        ? Border(
                                            left: BorderSide(
                                                color: palette.utilityAction))
                                        : null),
                                child: SizedBox(
                                    width: 34,
                                    height: 34,
                                    child: Center(
                                        child: Icon(AppIcons.caretDown,
                                            size: 12,
                                            color: background != null
                                                ? _onSlab
                                                : palette.textMuted))))),
                      ]),
                    ),
                  ),
                ),
              ),
      ),
    );
    return native
        ? control
        : LibraryFormField(label: widget.label, child: control);
  }
}

/// The reference's text on a coloured slab label.
const Color _onSlab = Color(0xb3000000);

/// One fixed value of a [LibraryFixedSelectField] with the text it shows and,
/// for slab labels, the colours it is painted in.
typedef LibraryFixedSelectOption = ({String value, Gradient? background});

/// A built-in list the user picks from but does not edit, as the reference's
/// Grade, Label Type and Page Quality: "None" dimmed first, then the values.
/// A stored value outside the list still shows in the field.
class LibraryFixedSelectField extends StatelessWidget {
  const LibraryFixedSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<LibraryFixedSelectOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final menu = AppDropdownMenuStyle.of(context);
    final current = value?.trim().isEmpty ?? true ? null : value!.trim();
    final background = options
        .where((option) => option.value == current)
        .firstOrNull
        ?.background;
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    return LibraryMenuSelectField<String>(
      label: label,
      hasValue: current != null,
      tooltip: 'Choose ${label.toLowerCase()}',
      background: background,
      display: Text(current ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: background != null ? _onSlab : null)),
      // An empty string stands for None, as a menu value cannot be null.
      onSelected: (selected) => onChanged(selected.isEmpty ? null : selected),
      itemBuilder: (context) => [
        menu.row(
            value: '',
            child: Text('None',
                style: style.copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.25)))),
        for (final option in options)
          option.background == null
              ? menu.row(
                  value: option.value,
                  child: Text(option.value,
                      style: style.copyWith(color: palette.textPrimary)))
              : PopupMenuItem<String>(
                  value: option.value,
                  height: AppDropdownMenuStyle.rowHeight,
                  padding: EdgeInsets.zero,
                  child: Container(
                      height: AppDropdownMenuStyle.rowHeight,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(gradient: option.background),
                      child: Text(option.value,
                          style: style.copyWith(color: _onSlab)))),
      ],
    );
  }
}
