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

  @override
  Widget build(BuildContext context) {
    final normalizedOptions = _normalizedOptions(
      widget.options,
      selectedValue: widget.controller.text,
    );
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
        widget.controller.value = TextEditingValue(
          text: selection,
          selection: TextSelection.collapsed(offset: selection.length),
        );
        widget.onChanged?.call(selection);
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
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.trim().isNotEmpty)
                  IconButton(
                    tooltip: 'Clear ${widget.label}',
                    onPressed: () {
                      controller.clear();
                      widget.onChanged?.call(null);
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  ),
                if (widget.onManage != null)
                  IconButton(
                    tooltip: widget.manageTooltip ?? 'Manage ${widget.label}',
                    onPressed: widget.enabled ? widget.onManage : null,
                    icon: const Icon(Icons.tune),
                  ),
              ],
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