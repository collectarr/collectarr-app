import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<Set<TValue>?> showLibraryMultiValueOptionsDialog<TValue>({
  required BuildContext context,
  required String label,
  required List<LibraryFieldOption<TValue>> options,
  required Set<TValue> selectedValues,
  bool allowCustomValues = true,
  String? searchHint,
  String customValueHint = 'Add value',
}) {
  return showAppDialog<Set<TValue>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _LibraryMultiValueOptionsDialog<TValue>(
      label: label,
      options: options,
      selectedValues: selectedValues,
      allowCustomValues: allowCustomValues,
      searchHint: searchHint,
      customValueHint: customValueHint,
    ),
  );
}

class _LibraryMultiValueOptionsDialog<TValue> extends StatefulWidget {
  const _LibraryMultiValueOptionsDialog({
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.allowCustomValues,
    required this.searchHint,
    required this.customValueHint,
  });

  final String label;
  final List<LibraryFieldOption<TValue>> options;
  final Set<TValue> selectedValues;
  final bool allowCustomValues;
  final String? searchHint;
  final String customValueHint;

  @override
  State<_LibraryMultiValueOptionsDialog<TValue>> createState() =>
      _LibraryMultiValueOptionsDialogState<TValue>();
}

class _LibraryMultiValueOptionsDialogState<TValue>
    extends State<_LibraryMultiValueOptionsDialog<TValue>> {
  late final Set<TValue> _selected = {...widget.selectedValues};
  final _customController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addCustomValue() {
    final text = _customController.text.trim();
    if (text.isEmpty || TValue != String) return;
    setState(() {
      _selected.add(text as TValue);
      _customController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final windowClass = AppWindowClass.of(context);
    final visibleOptions = <LibraryFieldOption<TValue>>[
      ...widget.options,
      for (final value in _selected)
        if (!widget.options.any((option) => option.value == value))
          LibraryFieldOption<TValue>(value: value, label: value.toString()),
    ];
    final query = _searchController.text.trim().toLowerCase();
    final filteredOptions = visibleOptions
        .where((option) => option.label.toLowerCase().contains(query))
        .toList(growable: false);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      insetPadding: EdgeInsets.symmetric(
        horizontal: windowClass.isMedium ? 16 : 32,
        vertical: 24,
      ),
      title: AccentDialogHeader(
        title: 'Select ${widget.label}',
        icon: Icons.list_alt_outlined,
        onClose: () => Navigator.of(context).pop(),
      ),
      content: SizedBox(
        width: 480,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 480),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LibraryTextFormControl(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.searchHint ??
                        'Search ${widget.label.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                for (final option in filteredOptions)
                  CheckboxListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(option.label),
                    value: _selected.contains(option.value),
                    onChanged: option.enabled
                        ? (checked) => setState(() {
                              if (checked ?? false) {
                                _selected.add(option.value);
                              } else {
                                _selected.remove(option.value);
                              }
                            })
                        : null,
                  ),
                if (filteredOptions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No ${widget.label.toLowerCase()} found.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (widget.allowCustomValues && TValue == String) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LibraryTextFormControl(
                          controller: _customController,
                          decoration: InputDecoration(
                            labelText: widget.customValueHint,
                            isDense: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _addCustomValue(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Add value',
                        onPressed: _addCustomValue,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(<TValue>{}),
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(Set.unmodifiable(_selected)),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
