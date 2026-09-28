part of 'catalog_item_v1_workspace_page.dart';

final class _CatalogItemCommonEditor extends StatefulWidget {
  const _CatalogItemCommonEditor({
    required this.title,
    required this.accent,
    required this.kind,
    required this.initialDetails,
  });

  final String title;
  final Color accent;
  final CatalogMediaKind kind;
  final Map<String, dynamic> initialDetails;

  @override
  State<_CatalogItemCommonEditor> createState() =>
      _CatalogItemCommonEditorState();
}

final class _CatalogItemCommonEditorState
    extends State<_CatalogItemCommonEditor> {
  late final TextEditingController _title = TextEditingController(
      text: widget.initialDetails['title'] as String? ?? '');
  late final TextEditingController _sortTitle = TextEditingController(
      text: widget.initialDetails['sort_title'] as String? ?? '');
  late final TextEditingController _subtitle = TextEditingController(
      text: widget.initialDetails['subtitle'] as String? ?? '');
  late final TextEditingController _releaseYear = TextEditingController(
    text: _partialDateComponent(widget.initialDetails['release_date'], 'year'),
  );
  late final TextEditingController _releaseMonth = TextEditingController(
    text: _partialDateComponent(widget.initialDetails['release_date'], 'month'),
  );
  late final TextEditingController _releaseDay = TextEditingController(
    text: _partialDateComponent(widget.initialDetails['release_date'], 'day'),
  );
  late Map<String, dynamic> _kindValues =
      _kindDetailValues(widget.kind, widget.initialDetails);
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _sortTitle.dispose();
    _subtitle.dispose();
    _releaseYear.dispose();
    _releaseMonth.dispose();
    _releaseDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          width: 480,
          height: 560,
          child: Column(
            children: [
              _CatalogItemCommonFields(
                titleController: _title,
                sortTitleController: _sortTitle,
                subtitleController: _subtitle,
                releaseYearController: _releaseYear,
                releaseMonthController: _releaseMonth,
                releaseDayController: _releaseDay,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: _CatalogItemV1KindFields(
                    kind: widget.kind,
                    values: _kindValues,
                    onChanged: (values) => setState(() {
                      _kindValues = values;
                    }),
                  ),
                ),
              ),
              if (_error != null)
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      );

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    final details = _sanitizeKindWriteDetails(
      widget.kind,
      widget.initialDetails,
    )
      ..['title'] = title
      ..['sort_title'] = _nullableText(_sortTitle.text)
      ..['subtitle'] = _nullableText(_subtitle.text)
      ..addAll(_kindValues);
    try {
      details['release_date'] = _parseCatalogPartialDate(
        _releaseYear.text,
        _releaseMonth.text,
        _releaseDay.text,
      )?.toJson();
      final typedDetails = catalogItemWriteDetailsFromJson(details);
      Navigator.pop(context, CatalogItemWriteV1Dto(details: typedDetails));
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }
}

final class _OwnedCopyEditor extends StatefulWidget {
  const _OwnedCopyEditor({
    required this.copy,
    required this.title,
    required this.accent,
  });

  final OwnedCopyV1 copy;
  final String title;
  final Color accent;

  @override
  State<_OwnedCopyEditor> createState() => _OwnedCopyEditorState();
}

final class _OwnedCopyAddDialog extends StatefulWidget {
  const _OwnedCopyAddDialog({
    required this.title,
    required this.kind,
    required this.accent,
  });

  final String title;
  final CatalogMediaKind kind;
  final Color accent;

  @override
  State<_OwnedCopyAddDialog> createState() => _OwnedCopyAddDialogState();
}

final class _OwnedCopyAddDialogState extends State<_OwnedCopyAddDialog> {
  late OwnedCopyV1FormDraft _draft = OwnedCopyV1FormDraft.empty(widget.kind);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Add copy of ${widget.title}'),
        content: SizedBox(
          width: 620,
          height: 560,
          child: SingleChildScrollView(
            child: OwnedCopyV1Form(
              key: const ValueKey('quick-owned-copy-form'),
              initial: _draft,
              showQuantity: true,
              showAdvanced: true,
              onChanged: (draft) => setState(() => _draft = draft),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            onPressed: _draft.validationError == null
                ? () => Navigator.pop(context, _draft)
                : null,
            child: Text('Add ${_draft.quantity} copies'),
          ),
        ],
      );
}

final class _OwnedCopyEditorState extends State<_OwnedCopyEditor> {
  late OwnedCopyV1FormDraft _draft = OwnedCopyV1FormDraft.fromCopy(widget.copy);
  String? _error;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Edit ${widget.title} copy'),
        content: SizedBox(
          width: 620,
          height: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OwnedCopyV1Form(
                  key: const ValueKey('edit-owned-copy-form'),
                  initial: _draft,
                  showAdvanced: true,
                  onChanged: (draft) => setState(() => _draft = draft),
                ),
                if (_error != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      );

  void _save() {
    final validationError = _draft.validationError;
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    try {
      Navigator.pop(context, _draft.buildCopy(widget.copy));
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }
}

String? _nullableText(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}

String _partialDateComponent(Object? value, String component) {
  if (value is! Map) return '';
  final date = PartialDate.tryParse(value);
  return switch (component) {
    'year' => date?.year?.toString() ?? '',
    'month' => date?.month?.toString() ?? '',
    'day' => date?.day?.toString() ?? '',
    _ => '',
  };
}

PartialDate? _parseCatalogPartialDate(
  String rawYear,
  String rawMonth,
  String rawDay,
) {
  final yearText = rawYear.trim();
  final monthText = rawMonth.trim();
  final dayText = rawDay.trim();
  if (yearText.isEmpty && monthText.isEmpty && dayText.isEmpty) return null;
  final year = yearText.isEmpty ? null : int.tryParse(yearText);
  final month = monthText.isEmpty ? null : int.tryParse(monthText);
  final day = dayText.isEmpty ? null : int.tryParse(dayText);
  if ((yearText.isNotEmpty && year == null) ||
      (monthText.isNotEmpty && month == null) ||
      (dayText.isNotEmpty && day == null)) {
    throw const FormatException(
      'Release date components must be whole numbers.',
    );
  }
  if (year != null && (year < 1 || year > 9999) ||
      month != null && (month < 1 || month > 12) ||
      day != null && (day < 1 || day > 31)) {
    throw const FormatException(
      'Release date components are outside their valid ranges.',
    );
  }
  final date = PartialDate(year: year, month: month, day: day);
  if (date.isFullDate && date.asDateTime == null) {
    throw const FormatException('Release date is not a valid calendar date.');
  }
  return date;
}

String _catalogWriteError(Object error) {
  final value = error.toString();
  if (value.contains('403') || value.contains('catalog_editor_required')) {
    return 'Creating or editing shared Catalog Items requires an editor or admin account.';
  }
  return value;
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(content: Text(message)),
  );
}
