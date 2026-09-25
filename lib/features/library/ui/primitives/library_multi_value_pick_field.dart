import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef LibraryMultiValuePickHandler<TValue> = Future<Set<TValue>?> Function({
  required String label,
  required Set<TValue> selectedValues,
  required List<LibraryFieldOption<TValue>> options,
});

/// Chip-based multi-value field with a separate action for opening its picker.
///
/// The field owns only presentation. Callers choose whether the picker is a
/// local option dialog or a persistent pick list with create/manage actions.
class LibraryMultiValuePickField<TValue> extends StatefulWidget {
  const LibraryMultiValuePickField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.onOpenPicker,
    this.errorText,
    this.hintText,
    this.enabled = true,
    this.allowCustomValueEntry = false,
  });

  final String label;
  final Set<TValue> value;
  final List<LibraryFieldOption<TValue>> options;
  final ValueChanged<Set<TValue>> onChanged;
  final LibraryMultiValuePickHandler<TValue> onOpenPicker;
  final String? errorText;
  final String? hintText;
  final bool enabled;
  final bool allowCustomValueEntry;

  @override
  State<LibraryMultiValuePickField<TValue>> createState() =>
      _LibraryMultiValuePickFieldState<TValue>();
}

class _LibraryMultiValuePickFieldState<TValue>
    extends State<LibraryMultiValuePickField<TValue>> {
  late Set<TValue> _value = {...widget.value};
  final TextEditingController _entryController = TextEditingController();
  final FocusNode _entryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _entryFocusNode.addListener(_commitEntryWhenUnfocused);
  }

  @override
  void didUpdateWidget(covariant LibraryMultiValuePickField<TValue> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(oldWidget.value, widget.value)) {
      _value = {...widget.value};
    }
  }

  String _labelFor(TValue value) {
    for (final option in widget.options) {
      if (option.value == value) return option.label;
    }
    return value.toString();
  }

  void _addTypedValue(String rawValue) {
    if (!mounted || TValue != String || !widget.allowCustomValueEntry) return;
    final value = rawValue.trim();
    if (value.isEmpty) return;
    final alreadySelected = _value.any(
      (selected) =>
          selected.toString().trim().toLowerCase() == value.toLowerCase(),
    );
    _entryController.clear();
    if (alreadySelected) return;
    final next = {..._value, value as TValue};
    setState(() => _value = next);
    widget.onChanged(next);
  }

  void _commitEntryWhenUnfocused() {
    if (!_entryFocusNode.hasFocus && _entryController.text.trim().isNotEmpty) {
      _addTypedValue(_entryController.text);
    }
  }

  @override
  void dispose() {
    _entryFocusNode
      ..removeListener(_commitEntryWhenUnfocused)
      ..dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _openPicker(BuildContext context) async {
    if (!widget.enabled) return;
    final next = await widget.onOpenPicker(
      label: widget.label,
      selectedValues: Set<TValue>.unmodifiable(_value),
      options: widget.options,
    );
    if (next == null || !mounted) return;
    setState(() => _value = {...next});
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        enabled: widget.enabled,
        constraints: const BoxConstraints(
          minHeight: kLibraryFormControlHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: SizedBox(
        height: kLibraryFormControlHeight - 2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final selected in _value)
                      InputChip(
                        label: Text(_labelFor(selected)),
                        selected: true,
                        showCheckmark: false,
                        backgroundColor: colorScheme.primaryContainer,
                        selectedColor: colorScheme.primaryContainer,
                        side: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        ),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: colorScheme.onPrimaryContainer),
                        onDeleted: widget.enabled
                            ? () {
                                final next = {..._value}..remove(selected);
                                setState(() => _value = next);
                                widget.onChanged(next);
                              }
                            : null,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                        deleteIcon: Icon(
                          Icons.close,
                          size: 15,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    if (widget.allowCustomValueEntry && TValue == String)
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _entryController,
                          focusNode: _entryFocusNode,
                          enabled: widget.enabled,
                          decoration: InputDecoration.collapsed(
                            hintText: widget.hintText ??
                                'Add ${widget.label.toLowerCase()}...',
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: _addTypedValue,
                        ),
                      )
                    else if (_value.isEmpty)
                      Text(
                        widget.hintText ??
                            'Select ${widget.label.toLowerCase()}...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.only(right: 4),
              color: Theme.of(context).dividerColor,
            ),
            IconButton(
              tooltip: 'Select ${widget.label.toLowerCase()}',
              onPressed: widget.enabled ? () => _openPicker(context) : null,
              icon: const Icon(Icons.list_alt_outlined),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(
                width: 34,
                height: kLibraryFormControlHeight - 2,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
