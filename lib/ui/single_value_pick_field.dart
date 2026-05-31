import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SingleValuePickField extends StatefulWidget {
  const SingleValuePickField({
    super.key,
    required this.controller,
    required this.options,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.onManage,
    this.manageTooltip,
    this.enabled = true,
  });

  final TextEditingController controller;
  final List<String> options;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onManage;
  final String? manageTooltip;
  final bool enabled;

  @override
  State<SingleValuePickField> createState() => _SingleValuePickFieldState();
}

class _SingleValuePickFieldState extends State<SingleValuePickField> {
  late final FocusNode _focusNode;
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

  Widget _suffixAction({
    required String tooltip,
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedOptions = _normalizedOptions(
      widget.options,
      selectedValue: widget.controller.text,
    );
    final actionCount = [
      if (normalizedOptions.isNotEmpty) true,
      if (widget.controller.text.trim().isNotEmpty) true,
      if (widget.onManage != null) true,
    ].length;
    final suffixWidth =
        actionCount * _suffixButtonExtent + (_suffixHorizontalPadding * 2);
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        if (!widget.enabled) {
          return const Iterable<String>.empty();
        }
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return normalizedOptions;
        }
        return normalizedOptions.where(
          (option) => option.toLowerCase().contains(query),
        );
      },
      onSelected: (selection) {
        _applySelection(selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
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
                            onPressed: () => _openPickerDialog(normalizedOptions),
                            icon: Icons.arrow_drop_down_circle_outlined,
                          ),
                        if (controller.text.trim().isNotEmpty)
                          _suffixAction(
                            tooltip: 'Clear ${widget.label}',
                            onPressed: () {
                              controller.clear();
                              widget.onChanged?.call(null);
                              setState(() {});
                            },
                            icon: Icons.close,
                          ),
                        if (widget.onManage != null)
                          _suffixAction(
                            tooltip:
                                widget.manageTooltip ?? 'Manage ${widget.label}',
                            onPressed: widget.enabled ? widget.onManage : null,
                            icon: Icons.tune,
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
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, displayedOptions) {
        final options = displayedOptions.toList(growable: false);
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }
        final palette = appPalette(context);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: palette.panelRaised,
            elevation: 4,
            borderRadius: kAppMenuBorderRadius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, maxWidth: 420),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      dense: true,
                      title: Text(option),
                      onTap: () => onSelected(option),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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