part of 'admin_page.dart';

class _MetadataCorrectionDialog extends StatefulWidget {
  const _MetadataCorrectionDialog({
    required this.item,
    required this.physicalFormats,
  });

  final AdminMetadataItem item;
  final List<PhysicalMediaFormat> physicalFormats;

  @override
  State<_MetadataCorrectionDialog> createState() =>
      _MetadataCorrectionDialogState();
}

class _MetadataCorrectionDialogState extends State<_MetadataCorrectionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _itemNumberController;
  late final TextEditingController _publisherController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _variantController;
  late final TextEditingController _pageCountController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _synopsisController;
  late String _physicalFormatId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final variant = widget.item.primaryVariant;
    _titleController = TextEditingController(text: widget.item.title);
    _itemNumberController =
        TextEditingController(text: widget.item.itemNumber ?? '');
    _publisherController =
        TextEditingController(text: widget.item.publisher ?? '');
    _barcodeController = TextEditingController(
      text: widget.item.barcode ?? variant?.barcode ?? '',
    );
    _variantController = TextEditingController(text: variant?.name ?? '');
    _pageCountController = TextEditingController(
      text: widget.item.publishing?.pageCount?.toString() ?? '',
    );
    _releaseDateController = TextEditingController(
      text: widget.item.coverDate == null ? '' : _formatDate(widget.item.coverDate!),
    );
    _coverController = TextEditingController(text: variant?.coverImageUrl ?? '');
    _thumbnailController = TextEditingController(
      text: variant?.thumbnailImageUrl ?? '',
    );
    _synopsisController = TextEditingController(text: widget.item.synopsis ?? '');
    final edition = widget.item.primaryEdition;
    _physicalFormatId = edition?.physicalFormat ??
        physicalMediaFormatById(
              edition?.physicalFormatLabel ?? '',
              formats: widget.physicalFormats,
            )?.id ??
        '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemNumberController.dispose();
    _publisherController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _pageCountController.dispose();
    _releaseDateController.dispose();
    _coverController.dispose();
    _thumbnailController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: _kAdminDialogShape,
      title: Text('Edit metadata: ${widget.item.displayTitle}'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                _MessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              _correctionField(_titleController, 'Title'),
              _correctionField(_itemNumberController, 'Item number'),
              _correctionField(_publisherController, 'Publisher'),
              _correctionField(_barcodeController, 'Barcode'),
              _correctionField(_variantController, 'Primary variant'),
              _correctionField(
                _pageCountController,
                'Page count',
                keyboardType: TextInputType.number,
              ),
              _correctionField(_releaseDateController, 'Release date'),
              if (widget.physicalFormats.isNotEmpty) _physicalFormatField(),
              _correctionField(_coverController, 'Cover URL'),
              _correctionField(_thumbnailController, 'Thumbnail URL'),
              _correctionField(
                _synopsisController,
                'Synopsis',
                minLines: 3,
                maxLines: 5,
              ),
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
          child: const Text('Save correction'),
        ),
      ],
    );
  }

  Widget _correctionField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _physicalFormatField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _physicalFormatId,
        dropdownColor: _kAdminDropdownColor,
        borderRadius: kAppMenuBorderRadius,
        decoration: const InputDecoration(
          labelText: 'Physical format',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text('No format selected')),
          for (final format in widget.physicalFormats)
            DropdownMenuItem(value: format.id, child: Text(format.label)),
        ],
        onChanged: (value) {
          setState(() {
            _physicalFormatId = value ?? '';
          });
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _error = 'Title is required.';
      });
      return;
    }
    final currentVariantName = widget.item.primaryVariant?.name.trim();
    if (currentVariantName != null &&
        currentVariantName.isNotEmpty &&
        _variantController.text.trim().isEmpty) {
      setState(() {
        _error = 'Primary variant cannot be cleared yet.';
      });
      return;
    }
    final pageCountText = _pageCountController.text.trim();
    final pageCount = pageCountText.isEmpty ? null : int.tryParse(pageCountText);
    if (pageCountText.isNotEmpty && pageCount == null) {
      setState(() {
        _error = 'Page count must be a number.';
      });
      return;
    }
    final releaseDateText = _releaseDateController.text.trim();
    final releaseDate =
        releaseDateText.isEmpty ? null : DateTime.tryParse(releaseDateText);
    if (releaseDateText.isNotEmpty && releaseDate == null) {
      setState(() {
        _error = 'Release date must use YYYY-MM-DD.';
      });
      return;
    }
    final correction = _CatalogCorrection(
      title: _emptyToNull(_titleController.text),
      itemNumber: _emptyToNull(_itemNumberController.text),
      publisher: _emptyToNull(_publisherController.text),
      barcode: _emptyToNull(_barcodeController.text),
      physicalFormat: widget.physicalFormats.isNotEmpty
          ? _emptyToNull(_physicalFormatId)
          : null,
      variantName: _emptyToNull(_variantController.text),
      pageCount: pageCount,
      releaseDate: releaseDate,
      coverImageUrl: _emptyToNull(_coverController.text),
      thumbnailImageUrl: _emptyToNull(_thumbnailController.text),
      synopsis: _emptyToNull(_synopsisController.text),
    );
    final changes = _correctionPreview(correction);
    if (changes.isEmpty) {
      setState(() {
        _error = 'Change at least one metadata field before saving.';
      });
      return;
    }
    final confirmed = await _confirmCorrectionPreview(changes);
    if (!mounted || !confirmed) {
      return;
    }
    Navigator.of(context).pop(correction);
  }

  Future<bool> _confirmCorrectionPreview(
    List<_CorrectionPreviewEntry> changes,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
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
                      _CorrectionPreviewRow(change: change),
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

  List<_CorrectionPreviewEntry> _correctionPreview(
    _CatalogCorrection correction,
  ) {
    final item = widget.item;
    final variant = item.primaryVariant;
    final edition = item.primaryEdition;
    final changes = <_CorrectionPreviewEntry>[];
    void add(String label, Object? before, Object? after) {
      final beforeText = _previewValue(before);
      final afterText = _previewValue(after);
      if (beforeText == afterText) {
        return;
      }
      changes.add(
        _CorrectionPreviewEntry(
          label: label,
          before: beforeText,
          after: afterText,
        ),
      );
    }

    add('Title', item.title, correction.title);
    add('Item number', item.itemNumber, correction.itemNumber);
    add('Publisher', item.publisher, correction.publisher);
    add('Barcode', item.barcode ?? variant?.barcode, correction.barcode);
    add('Primary variant', variant?.name, correction.variantName);
    add('Page count', item.publishing?.pageCount, correction.pageCount);
    add('Release date', item.coverDate, correction.releaseDate);
    if (widget.physicalFormats.isNotEmpty) {
      add('Physical format', edition?.physicalFormat, correction.physicalFormat);
    }
    add('Cover URL', variant?.coverImageUrl, correction.coverImageUrl);
    add(
      'Thumbnail URL',
      variant?.thumbnailImageUrl,
      correction.thumbnailImageUrl,
    );
    add('Synopsis', item.synopsis, correction.synopsis);
    return changes;
  }

  String _previewValue(Object? value) {
    if (value == null) {
      return '(empty)';
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    final text = value.toString().trim();
    return text.isEmpty ? '(empty)' : text;
  }
}