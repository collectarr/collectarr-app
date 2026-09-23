import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
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
  });

  final String label;
  final Set<TValue> value;
  final List<LibraryFieldOption<TValue>> options;
  final ValueChanged<Set<TValue>> onChanged;
  final LibraryMultiValuePickHandler<TValue> onOpenPicker;
  final String? errorText;
  final String? hintText;
  final bool enabled;

  @override
  State<LibraryMultiValuePickField<TValue>> createState() =>
      _LibraryMultiValuePickFieldState<TValue>();
}

class _LibraryMultiValuePickFieldState<TValue>
    extends State<LibraryMultiValuePickField<TValue>> {
  late Set<TValue> _value = {...widget.value};

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
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        enabled: widget.enabled,
        contentPadding: const EdgeInsets.fromLTRB(10, 12, 6, 8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _value.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      widget.hintText ??
                          'Select ${widget.label.toLowerCase()}...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                : Wrap(
                    spacing: 5,
                    runSpacing: 3,
                    children: [
                      for (final selected in _value)
                        InputChip(
                          label: Text(_labelFor(selected)),
                          selected: true,
                          showCheckmark: false,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          selectedColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          onDeleted: widget.enabled
                              ? () {
                                  final next = {..._value}..remove(selected);
                                  setState(() => _value = next);
                                  widget.onChanged(next);
                                }
                              : null,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 2),
                          deleteIcon: const Icon(Icons.close, size: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
          ),
          IconButton(
            tooltip: 'Select ${widget.label.toLowerCase()}',
            onPressed: widget.enabled ? () => _openPicker(context) : null,
            icon: const Icon(Icons.list_alt_outlined),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
