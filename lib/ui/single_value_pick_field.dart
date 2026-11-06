import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/ui/anchored_popup_geometry.dart';
import 'package:collectarr_app/features/library/ui/density_scope.dart';

import 'package:collectarr_app/ui/pick_list_field_button.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_dropdown_menu.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

class SingleValuePickField extends StatefulWidget
    implements LibraryMobileInlineLabelControl {
  const SingleValuePickField({
    super.key,
    required this.controller,
    required this.options,
    required this.label,
    this.fieldKey,
    this.hint,
    this.helperText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onManage,
    this.manageTooltip,
    this.showPickerListAction = false,
    this.showInlineLabel = true,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final List<String> options;
  final String label;
  final Key? fieldKey;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onManage;
  final String? manageTooltip;
  final bool showPickerListAction;
  final bool showInlineLabel;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  State<SingleValuePickField> createState() => _SingleValuePickFieldState();
}

class _SingleValuePickFieldState extends State<SingleValuePickField> {
  bool _menuOpen = false;
  late final FocusNode _ownedFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode;
  final GlobalKey _fieldAnchorKey = GlobalKey();
  static const _suffixButtonExtent = 32.0;

  @override
  void initState() {
    super.initState();
    _ownedFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _ownedFocusNode.dispose();
    super.dispose();
  }

  void _applySelection(String selection) {
    widget.controller.value = TextEditingValue(
      text: selection,
      selection: TextSelection.collapsed(offset: selection.length),
    );
    widget.onChanged?.call(selection);
    setState(() {});
  }

  Future<void> _openPickerDialog(List<String> options) async {
    if (!widget.enabled || options.isEmpty) {
      return;
    }
    final selected = await showAppDialog<String>(
      context: context,
      builder: (context) {
        final palette = appPalette(context);
        final currentValue = _emptyToNull(widget.controller.text);
        return AccentAlertDialog(
          headerIcon: AppIcons.pickLists,
          backgroundColor: palette.panel,
          title: Text('Pick ${widget.label}'),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 420,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: palette.divider,
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final selected =
                      currentValue?.toLowerCase() == option.toLowerCase();
                  return ListTile(
                    dense: true,
                    selected: selected,
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(option),
                    onTap: () => Navigator.of(context).pop(option),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (!mounted || selected == null) {
      return;
    }
    _applySelection(selected);
    _focusNode.requestFocus();
  }

  Future<void> _openInlinePicker(List<String> options) async {
    if (!widget.enabled) {
      return;
    }
    // The reference's menu overlaps the field's bottom border.
    final geometry =
        AnchoredPopupGeometry.measure(context, _fieldAnchorKey, gap: -1);
    if (geometry == null || geometry.bounds.height <= 0) {
      await _openPickerDialog(options);
      return;
    }
    final currentValue = _emptyToNull(widget.controller.text)?.toLowerCase();
    final menu = AppDropdownMenuStyle.of(context);
    // An empty list opens as the reference's empty menu.
    final popupItems = options.isEmpty
        ? const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
                enabled: false,
                height: 0,
                padding: EdgeInsets.zero,
                child: SizedBox.shrink()),
          ]
        : <PopupMenuEntry<String>>[
            for (final option in options)
              menu.row(
                  value: option,
                  current: currentValue == option.toLowerCase(),
                  child: Text(option,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w400))),
          ];
    setState(() => _menuOpen = true);
    final selected = await showMenu<String>(
      context: context,
      position: geometry.menuPosition,
      constraints: BoxConstraints(
        minWidth: geometry.bounds.width,
        maxWidth: geometry.bounds.width,
        maxHeight: geometry.bounds.height,
      ),
      color: menu.background,
      shape: menu.shape,
      elevation: AppDropdownMenuStyle.elevation,
      surfaceTintColor: Colors.transparent,
      menuPadding: AppDropdownMenuStyle.padding,
      items: popupItems,
      popUpAnimationStyle: AnimationStyle.noAnimation,
    );
    if (!mounted) return;
    setState(() => _menuOpen = false);
    if (selected == null) return;
    _applySelection(selected);
    _focusNode.requestFocus();
  }

  Widget _suffixAction({
    required String tooltip,
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              mouseCursor: WidgetStateMouseCursor.clickable,
              borderRadius: BorderRadius.circular(3),
              onTap: onPressed,
              child: SizedBox(
                width: _suffixButtonExtent,
                height: LibraryDensityScope.of(context).metrics.fieldHeight - 2,
                // A small Font Awesome caret, as the reference select arrow.
                child: Icon(
                  icon,
                  size: 12,
                  color: appPalette(context).textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nativeEditor = LibraryMobileEditFormScope.active(context);
    final normalizedOptions = _normalizedOptions(
      widget.options,
      selectedValue: widget.controller.text,
    );
    final hasBrowseAction =
        widget.onManage != null || widget.showPickerListAction;
    final fieldHeight = nativeEditor
        ? 56.0
        : LibraryDensityScope.of(context).metrics.fieldHeight;
    final suffixWidth =
        _suffixButtonExtent + (hasBrowseAction ? PickListFieldButton.width : 0);
    return KeyedSubtree(
      key: _fieldAnchorKey,
      child: TextFormField(
        key: widget.fieldKey,
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        style: nativeEditor
            ? context.libraryTextTheme.controlText.copyWith(fontSize: 16)
            : context.libraryTextTheme.controlText,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          labelText:
              (widget.showInlineLabel || nativeEditor) ? widget.label : null,
          labelStyle: nativeEditor ? const TextStyle(fontSize: 16) : null,
          floatingLabelStyle:
              nativeEditor ? const TextStyle(fontSize: 12) : null,
          floatingLabelBehavior:
              nativeEditor ? FloatingLabelBehavior.always : null,
          filled: !nativeEditor,
          fillColor: nativeEditor ? Colors.transparent : null,
          border: nativeEditor
              ? const OutlineInputBorder(borderRadius: BorderRadius.zero)
              : null,
          // While its menu is open the field reads as focused, like the
          // reference: a blue frame around the field and its list button.
          enabledBorder: _menuOpen
              ? nativeEditor
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                          color: appPalette(context).utilityAction, width: 2),
                    )
                  : Theme.of(context).inputDecorationTheme.focusedBorder
              : nativeEditor
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide:
                          BorderSide(color: appPalette(context).divider),
                    )
                  : null,
          focusedBorder: nativeEditor
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(
                      color: appPalette(context).utilityAction, width: 2),
                )
              : null,
          hintText: widget.hint,
          helperText: widget.helperText,
          errorText: widget.errorText,
          contentPadding: EdgeInsets.symmetric(
            horizontal: nativeEditor ? 12 : 7,
            vertical: (fieldHeight - 20) / 2,
          ),
          constraints: BoxConstraints(
            minHeight: fieldHeight,
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: nativeEditor ? 44.0 : suffixWidth,
            maxWidth: nativeEditor ? 44.0 : suffixWidth,
            minHeight: fieldHeight - 2,
          ),
          suffixIcon: SizedBox(
            width: nativeEditor ? 44.0 : suffixWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                _suffixAction(
                  tooltip: 'Pick ${widget.label}',
                  onPressed: () => _openInlinePicker(normalizedOptions),
                  icon: AppIcons.caretDown,
                ),
                if (hasBrowseAction && !nativeEditor)
                  PickListFieldButton(
                    tooltip: widget.manageTooltip ?? 'Browse ${widget.label}',
                    highlighted: _menuOpen,
                    onPressed: widget.enabled
                        ? (widget.onManage ??
                            () => _openPickerDialog(normalizedOptions))
                        : null,
                  ),
              ],
            ),
          ),
        ),
        onTap: widget.readOnly
            ? () => _openInlinePicker(normalizedOptions)
            : () => setState(() {}),
        onChanged: (value) {
          widget.onChanged?.call(_emptyToNull(value));
          setState(() {});
        },
      ),
    );
  }

  static List<String> _normalizedOptions(
    List<String> options, {
    String? selectedValue,
  }) {
    final values = <String>[];
    final seen = <String>{};

    void addValue(String? value) {
      final trimmed = _emptyToNull(value);
      if (trimmed == null) {
        return;
      }
      if (seen.add(trimmed.toLowerCase())) {
        values.add(trimmed);
      }
    }

    for (final option in options) {
      addValue(option);
    }
    addValue(selectedValue);
    return values;
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
