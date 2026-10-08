import 'dart:math' as math;
import 'library_chip_input_layout.dart';

import 'package:collectarr_app/ui/pick_list_field_button.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_value_chip.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef LibraryMultiValuePickHandler<TValue> = Future<Set<TValue>?> Function({
  required String label,
  required Set<TValue> selectedValues,
  required List<LibraryFieldOption<TValue>> options,
  String? searchHint,
  String? customValueHint,
});

/// Wrapping tags, inline autocomplete and a separate multi-selection picker.
/// Callers own vocabulary definitions and persistence; edits stay in the draft.
class LibraryMultiValuePickField<TValue> extends StatefulWidget {
  const LibraryMultiValuePickField(
      {super.key,
      required this.label,
      required this.value,
      required this.options,
      required this.onChanged,
      required this.onOpenPicker,
      this.errorText,
      this.hintText,
      this.enabled = true,
      this.allowCustomValueEntry = false,
      this.pickerSearchHint,
      this.customValueHint = 'Add value'});
  final String label;
  final Set<TValue> value;
  final List<LibraryFieldOption<TValue>> options;
  final ValueChanged<Set<TValue>> onChanged;
  final LibraryMultiValuePickHandler<TValue> onOpenPicker;
  final String? errorText;
  final String? hintText;
  final bool enabled;
  final bool allowCustomValueEntry;
  final String? pickerSearchHint;
  final String customValueHint;
  @override
  State<LibraryMultiValuePickField<TValue>> createState() =>
      _LibraryMultiValuePickFieldState<TValue>();
}

class _LibraryMultiValuePickFieldState<TValue>
    extends State<LibraryMultiValuePickField<TValue>> {
  late Set<TValue> _value = {...widget.value};
  final _entryController = TextEditingController();
  final _entryFocusNode = FocusNode();
  bool _pickerOpen = false;
  bool _choosingSuggestion = false;

  @override
  void initState() {
    super.initState();
    _entryFocusNode.addListener(_focusChanged);
    _entryController.addListener(_entryChanged);
  }

  @override
  void didUpdateWidget(covariant LibraryMultiValuePickField<TValue> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.value.toList(), widget.value.toList())) {
      _value = {...widget.value};
    }
  }

  void _entryChanged() {
    if (mounted) setState(() {});
  }

  void _focusChanged() {
    if (!_entryFocusNode.hasFocus && !_pickerOpen && !_choosingSuggestion) {
      _commitEntry();
    }
    if (mounted) setState(() {});
  }

  String _labelFor(TValue value) =>
      widget.options
          .where((option) => option.value == value)
          .firstOrNull
          ?.label ??
      value.toString();

  bool _contains(TValue value) => _value.any((selected) => TValue == String
      ? selected.toString().trim().toLowerCase() ==
          value.toString().trim().toLowerCase()
      : selected == value);

  void _addValue(TValue value) {
    if (!widget.enabled || !mounted) return;
    _entryController.clear();
    if (_contains(value)) return;
    final next = {..._value, value};
    setState(() => _value = next);
    widget.onChanged(next);
  }

  void _commitEntry() {
    if (TValue != String || !widget.enabled) return;
    final raw = _entryController.text.trim();
    if (raw.isEmpty) return;
    final option = widget.options
        .where((option) =>
            option.enabled &&
            option.label.trim().toLowerCase() == raw.toLowerCase())
        .firstOrNull;
    if (option != null) {
      _addValue(option.value);
    } else if (widget.allowCustomValueEntry) {
      _addValue(raw as TValue);
    }
  }

  void _remove(TValue value) {
    if (!widget.enabled) return;
    final next = {..._value}..remove(value);
    setState(() => _value = next);
    widget.onChanged(next);
  }

  @override
  void dispose() {
    _entryFocusNode
      ..removeListener(_focusChanged)
      ..dispose();
    _entryController
      ..removeListener(_entryChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    if (!widget.enabled || _pickerOpen) return;
    setState(() => _pickerOpen = true);
    try {
      final next = await widget.onOpenPicker(
          label: widget.label,
          selectedValues: Set<TValue>.unmodifiable(_value),
          options: widget.options,
          searchHint: widget.pickerSearchHint,
          customValueHint: widget.customValueHint);
      if (!mounted || next == null) return;
      // Checkbox order must not rearrange values already selected in the item.
      final ordered = <TValue>{
        for (final value in _value)
          if (next.contains(value)) value,
        ...next,
      };
      setState(() => _value = ordered);
      widget.onChanged(ordered);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
            content: Text('Could not open saved choices. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _pickerOpen = false);
    }
  }

  Widget _entry(double availableWidth) {
    final textStyle =
        TextStyle(fontSize: 14, color: appPalette(context).textPrimary);
    return SizedBox(
        height: 28,
        child: RawAutocomplete<LibraryFieldOption<TValue>>(
          textEditingController: _entryController,
          focusNode: _entryFocusNode,
          displayStringForOption: (option) => option.label,
          optionsBuilder: (text) {
            final query = text.text.trim().toLowerCase();
            if (!widget.enabled || query.isEmpty) return const Iterable.empty();
            return widget.options.where((option) =>
                option.enabled &&
                !_contains(option.value) &&
                option.label.toLowerCase().contains(query));
          },
          onSelected: (option) => _addValue(option.value),
          fieldViewBuilder: (context, controller, focusNode, submit) => Focus(
            canRequestFocus: false,
            onKeyEvent: (node, event) {
              if (widget.enabled &&
                  event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  controller.text.isEmpty &&
                  _value.isNotEmpty) {
                _remove(_value.last);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: widget.enabled,
                style: textStyle,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    hintText: widget.hintText,
                    isCollapsed: true,
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none),
                onSubmitted: (_) {
                  submit();
                  _commitEntry();
                }),
          ),
          optionsViewBuilder: (context, select, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                  elevation: 4,
                  color: appPalette(context).field,
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                      width: math.min(320, availableWidth),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 210),
                          child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                final highlighted =
                                    AutocompleteHighlightedOption.of(context) ==
                                        index;
                                return InkWell(
                                    onTapDown: (_) =>
                                        _choosingSuggestion = true,
                                    onTapCancel: () =>
                                        _choosingSuggestion = false,
                                    onTap: () {
                                      select(option);
                                      _choosingSuggestion = false;
                                    },
                                    child: ColoredBox(
                                        color: highlighted
                                            ? appPalette(context).selection
                                            : Colors.transparent,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 7),
                                            child: Text(option.label,
                                                style: textStyle))));
                              }))))),
        ));
  }

  double _minimumEditorWidth(double availableWidth) {
    // An empty editor must not create an otherwise empty second chip row.
    if (_entryController.text.isEmpty) return 0;
    final measured = TextPainter(
        text: TextSpan(
            text: _entryController.text,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context))
      ..layout();
    final width = math.min(availableWidth, math.max(16.0, measured.width + 14));
    measured.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) => LibraryFormField(
      label: widget.label,
      child: InputDecorator(
          isFocused: _entryFocusNode.hasFocus || _pickerOpen,
          decoration: InputDecoration(
              errorText: widget.errorText,
              enabled: widget.enabled,
              constraints:
                  const BoxConstraints(minHeight: kLibraryFormControlHeight),
              contentPadding: EdgeInsets.zero,
              suffixIconConstraints: const BoxConstraints.tightFor(
                  width: PickListFieldButton.width,
                  height: kLibraryFormControlHeight - 2),
              suffixIcon: PickListFieldButton(
                  tooltip: 'Select ${widget.label.toLowerCase()}',
                  onPressed:
                      widget.enabled && !_pickerOpen ? _openPicker : null)),
          child: Padding(
              padding: const EdgeInsets.all(3),
              child: LayoutBuilder(
                  builder: (context, constraints) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap:
                          widget.enabled ? _entryFocusNode.requestFocus : null,
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 26),
                          child: LibraryChipInputLayout(
                              hasEditor: TValue == String,
                              minimumEditorWidth:
                                  _minimumEditorWidth(constraints.maxWidth),
                              children: [
                                for (final value in _value)
                                  LibraryValueChip(
                                      label: _labelFor(value),
                                      onDeleted: widget.enabled
                                          ? () => _remove(value)
                                          : null),
                                if (TValue == String)
                                  _entry(constraints.maxWidth),
                              ])))))));
}
