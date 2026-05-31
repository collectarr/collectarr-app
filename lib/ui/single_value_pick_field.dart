import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SingleValuePickField extends StatefulWidget {
  const SingleValuePickField({
    super.key,
    required this.controller,
    required this.options,
    required this.label,
    this.fieldKey,
    this.hint,
    this.validator,
    this.onChanged,
    this.onManage,
    this.manageTooltip,
    this.showPickerListAction = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final List<String> options;
  final String label;
  final Key? fieldKey;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onManage;
  final String? manageTooltip;
  final bool showPickerListAction;
  final bool enabled;

  @override
  State<SingleValuePickField> createState() => _SingleValuePickFieldState();
}

class _SingleValuePickFieldState extends State<SingleValuePickField> {
  late final FocusNode _focusNode;
  final GlobalKey _fieldAnchorKey = GlobalKey();
  static const _suffixButtonExtent = 32.0;
  static const _suffixHorizontalPadding = 8.0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        final palette = appPalette(context);
        final currentValue = _emptyToNull(widget.controller.text);
        return AlertDialog(
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
    if (!widget.enabled || options.isEmpty) {
      return;
    }
    final fieldBox =
        _fieldAnchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (fieldBox == null || overlayBox == null) {
      await _openPickerDialog(options);
      return;
    }
    final fieldOffset = fieldBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final currentValue = _emptyToNull(widget.controller.text);
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        fieldOffset.dx,
        fieldOffset.dy + fieldBox.size.height,
        overlayBox.size.width - fieldOffset.dx - fieldBox.size.width,
        overlayBox.size.height - fieldOffset.dy - fieldBox.size.height,
      ),
      constraints: BoxConstraints(
        minWidth: fieldBox.size.width,
        maxWidth: fieldBox.size.width,
        maxHeight: 280,
      ),
      items: [
        for (final option in options)
          PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Icon(
                  currentValue?.toLowerCase() == option.toLowerCase()
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(option)),
              ],
            ),
          ),
      ],
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
    bool showDivider = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDivider)
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.only(right: 4),
                color: Theme.of(context).dividerColor,
              ),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: SizedBox(
                width: _suffixButtonExtent,
                height: _suffixButtonExtent,
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
    final actionCount = [
      if (normalizedOptions.isNotEmpty) true,
      if (hasBrowseAction) true,
    ].length;
    final suffixWidth =
        actionCount * _suffixButtonExtent + (_suffixHorizontalPadding * 2);
    return KeyedSubtree(
      key: _fieldAnchorKey,
      child: TextFormField(
        key: widget.fieldKey,
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        enabled: widget.enabled,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIconConstraints: BoxConstraints(
            minWidth: actionCount == 0 ? 0 : suffixWidth,
            maxWidth: actionCount == 0 ? 0 : suffixWidth,
            minHeight: 40,
          ),
          suffixIcon: actionCount == 0
              ? null
              : SizedBox(
                  width: suffixWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (normalizedOptions.isNotEmpty)
                        _suffixAction(
                          tooltip: 'Pick ${widget.label}',
                          onPressed: () => _openInlinePicker(normalizedOptions),
                          icon: Icons.arrow_drop_down,
                        ),
                      if (hasBrowseAction)
                        _suffixAction(
                          tooltip:
                              widget.manageTooltip ?? 'Browse ${widget.label}',
                          onPressed: widget.enabled
                              ? (widget.onManage ??
                                  () => _openPickerDialog(normalizedOptions))
                              : null,
                          icon: Icons.view_list_outlined,
                          showDivider: normalizedOptions.isNotEmpty,
                        ),
                    ],
                  ),
                ),
        ),
        onTap: () => setState(() {}),
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