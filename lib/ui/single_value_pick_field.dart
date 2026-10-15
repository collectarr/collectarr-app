import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/ui/anchored_popup_geometry.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';

import 'package:collectarr_app/ui/pick_list_field_button.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

class SingleValuePickField extends StatefulWidget {
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
    final geometry = AnchoredPopupGeometry.measure(context, _fieldAnchorKey);
    if (geometry == null || geometry.bounds.height <= 0) {
      await _openPickerDialog(options);
      return;
    }
    final currentValue = _emptyToNull(widget.controller.text);
    final matchingOptions = options;
    final popupItems = matchingOptions.isEmpty
        ? const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
              child: Text('No matching values'),
            ),
          ]
        : <PopupMenuEntry<String>>[
            for (final option in matchingOptions)
              PopupMenuItem<String>(
                value: option,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Row(
                  children: [
                    Icon(
                      currentValue?.toLowerCase() == option.toLowerCase()
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(option,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400))),
                  ],
                ),
              ),
          ];
    final selected = await showMenu<String>(
      context: context,
      position: geometry.menuPosition,
      constraints: BoxConstraints(
        minWidth: geometry.bounds.width,
        maxWidth: geometry.bounds.width,
        maxHeight: geometry.bounds.height,
      ),
      color: appPalette(context).panelRaised,
      shape: RoundedRectangleBorder(
        borderRadius: appPalette(context).menuBorderRadius,
        side: BorderSide(color: appPalette(context).divider),
      ),
      surfaceTintColor: Colors.transparent,
      menuPadding: EdgeInsets.zero,
      items: popupItems,
      popUpAnimationStyle: AnimationStyle.noAnimation,
    );
    if (!mounted || selected == null) {
      return;
    }
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
                child: Icon(
                  icon,
                  size: 18,
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
    final normalizedOptions = _normalizedOptions(
      widget.options,
      selectedValue: widget.controller.text,
    );
    final hasBrowseAction =
        widget.onManage != null || widget.showPickerListAction;
    final fieldHeight = LibraryDensityScope.of(context).metrics.fieldHeight;
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
        style: context.libraryTextTheme.controlText,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          labelText: widget.showInlineLabel ? widget.label : null,
          hintText: widget.hint,
          helperText: widget.helperText,
          errorText: widget.errorText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 7),
          constraints: BoxConstraints(
            minHeight: fieldHeight,
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: suffixWidth,
            maxWidth: suffixWidth,
            minHeight: fieldHeight - 2,
          ),
          suffixIcon: SizedBox(
            width: suffixWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                _suffixAction(
                  tooltip: 'Pick ${widget.label}',
                  onPressed: () => _openInlinePicker(normalizedOptions),
                  icon: Icons.arrow_drop_down,
                ),
                if (hasBrowseAction)
                  PickListFieldButton(
                    tooltip: widget.manageTooltip ?? 'Browse ${widget.label}',
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
