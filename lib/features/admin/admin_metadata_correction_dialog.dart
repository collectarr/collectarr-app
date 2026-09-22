part of 'admin_page.dart';

final class _MetadataCorrectionResult {
  const _MetadataCorrectionResult({
    required this.values,
    required this.changedFields,
  });

  final LibraryMetadataCorrectionValues values;
  final List<LibraryAdminCorrectionField> changedFields;
}

class _MetadataCorrectionDialog extends StatefulWidget {
  const _MetadataCorrectionDialog({
    required this.item,
    required this.fields,
    required this.physicalFormats,
  });

  final AdminMetadataItem item;
  final List<LibraryAdminCorrectionField> fields;
  final List<PhysicalMediaFormat> physicalFormats;

  @override
  State<_MetadataCorrectionDialog> createState() =>
      _MetadataCorrectionDialogState();
}

class _MetadataCorrectionDialogState extends State<_MetadataCorrectionDialog> {
  late final Map<String, TextEditingController> _controllers;
  String? _error;

  List<LibraryAdminCorrectionField> get _fields => widget.fields
      .where(
        (field) =>
            !field.usesPhysicalFormatPicker ||
            widget.physicalFormats.isNotEmpty,
      )
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in _fields)
        field.key: TextEditingController(
          text: _initialValue(field, field.read(widget.item)),
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _initialValue(LibraryAdminCorrectionField field, Object? value) {
    final text = field.displayValue(value);
    if (!field.usesPhysicalFormatPicker || text.isEmpty) return text;
    return physicalMediaFormatById(text, formats: widget.physicalFormats)?.id ??
        text;
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];
    for (final tab in SharedMetadataEditTab.values) {
      final fields = _fields
          .where((field) => field.presentation.tab == tab)
          .toList(growable: false);
      if (fields.isEmpty) continue;
      sections.add(_sectionLabel(tab.label));
      sections.addAll(fields.map(_buildField));
    }
    return AccentAlertDialog(
      shape: _kAdminDialogShape,
      title: Text('Edit metadata: ${widget.item.displayTitle}'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                _MessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              ...sections,
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Review correction'),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: MetadataCorrectionSectionLabel(label: label),
      );

  Widget _buildField(LibraryAdminCorrectionField field) {
    final controller = _controllers[field.key]!;
    if (field.usesPhysicalFormatPicker) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: widget.physicalFormats.any(
            (format) => format.id == controller.text,
          )
              ? controller.text
              : '',
          dropdownColor: appPalette(context).panelRaised,
          borderRadius: kAppMenuBorderRadius,
          decoration: InputDecoration(
            labelText: field.presentation.label,
            border: const OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
                value: '', child: Text('No format selected')),
            for (final format in widget.physicalFormats)
              DropdownMenuItem(value: format.id, child: Text(format.label)),
          ],
          onChanged: (value) => controller.text = value ?? '',
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MetadataCorrectionTextField(
        controller: controller,
        label: field.presentation.label,
        keyboardType: sharedFieldKeyboardType(field.presentation),
        hintText: field.presentation.hintText,
        minLines: field.presentation.minLines,
        maxLines: field.presentation.maxLines,
      ),
    );
  }

  Future<void> _submit() async {
    final serialized = <String, Object?>{};
    final changed = <LibraryAdminCorrectionField>[];
    try {
      for (final field in _fields) {
        final raw = _controllers[field.key]!.text.trim();
        final parsed = _parseValue(field, raw);
        if (field.required &&
            (parsed == null || (parsed is String && parsed.trim().isEmpty))) {
          throw FormatException('${field.presentation.label} is required.');
        }
        final before = _currentValue(field);
        serialized[field.key] = parsed;
        if (!field.valuesEqual(before, parsed)) changed.add(field);
      }
    } on FormatException catch (error) {
      setState(() => _error = error.message);
      return;
    }

    if (changed.isEmpty) {
      setState(
          () => _error = 'Change at least one metadata field before saving.');
      return;
    }

    final changes = [
      for (final field in changed)
        _MetadataCorrectionPreviewEntry(
          label: field.presentation.label,
          before: _previewText(field.displayValue(_currentValue(field))),
          after: _previewText(field.displayValue(serialized[field.key])),
        ),
    ];
    final confirmed = await _confirmCorrectionPreview(changes);
    if (!mounted || !confirmed) return;
    Navigator.of(context).pop(
      _MetadataCorrectionResult(
        values: LibraryMetadataCorrectionValues.fromSerialized(serialized),
        changedFields: List.unmodifiable(changed),
      ),
    );
  }

  Object? _currentValue(LibraryAdminCorrectionField field) {
    final value = field.read(widget.item);
    if (!field.usesPhysicalFormatPicker || value == null) return value;
    final text = field.displayValue(value);
    return physicalMediaFormatById(text, formats: widget.physicalFormats)?.id ??
        text;
  }

  Object? _parseValue(LibraryAdminCorrectionField field, String raw) {
    if (field.usesPhysicalFormatPicker) return raw.isEmpty ? null : raw;
    final customParser = field.parse;
    if (customParser != null) return customParser(raw);
    return switch (field.presentation.valueType) {
      SharedMetadataFieldValueType.text => raw.isEmpty ? null : raw,
      SharedMetadataFieldValueType.number => raw.isEmpty
          ? null
          : num.tryParse(raw) ??
              (throw FormatException(
                  '${field.presentation.label} must be a number.')),
      SharedMetadataFieldValueType.integer => raw.isEmpty
          ? null
          : int.tryParse(raw) ??
              (throw FormatException(
                  '${field.presentation.label} must be a number.')),
      SharedMetadataFieldValueType.boolean => switch (raw.toLowerCase()) {
          '' => null,
          'true' => true,
          'false' => false,
          _ => throw FormatException(
              '${field.presentation.label} must be true or false.',
            ),
        },
      SharedMetadataFieldValueType.partialDate => raw.isEmpty
          ? null
          : PartialDate.tryParse(raw) ??
              (throw FormatException(
                '${field.presentation.label} must use YYYY, YYYY-MM, YYYY-MM-DD, or a JSON object of components.',
              )),
      SharedMetadataFieldValueType.stringList => _normalizedAdminTags(raw),
      SharedMetadataFieldValueType.json => raw.isEmpty ? null : jsonDecode(raw),
    };
  }

  String _previewText(String value) => value.trim().isEmpty ? '(empty)' : value;

  Future<bool> _confirmCorrectionPreview(
    List<_MetadataCorrectionPreviewEntry> changes,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AccentAlertDialog(
            shape: _kAdminDialogShape,
            title: const Text('Preview metadata correction'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _DestructiveWarning(
                      icon: Icons.fact_check_outlined,
                      message:
                          'This edits canonical catalog metadata and affects every user who sees this item. Review the diff before saving.',
                    ),
                    const SizedBox(height: 12),
                    for (final change in changes)
                      _MetadataCorrectionPreviewRow(change: change),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Back to edit'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save correction'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

List<String> _normalizedAdminTags(dynamic values) {
  if (values == null) return const [];
  final entries = values is String
      ? values.split(RegExp(r'[,;\n]'))
      : values is List
          ? values
          : const <Object?>[];
  return entries
      .map((entry) => entry.toString().trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

class _MetadataCorrectionPreviewEntry {
  const _MetadataCorrectionPreviewEntry({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final String before;
  final String after;
}

class _MetadataCorrectionPreviewRow extends StatelessWidget {
  const _MetadataCorrectionPreviewRow({required this.change});

  final _MetadataCorrectionPreviewEntry change;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(change.label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Text('Before: ${change.before}'),
              Text('After: ${change.after}'),
            ],
          ),
        ),
      ),
    );
  }
}
