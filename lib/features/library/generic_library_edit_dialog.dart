import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/physical_media_formats.dart';
import 'package:flutter/material.dart';

class GenericLibraryEditDialog extends StatefulWidget {
  const GenericLibraryEditDialog({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
    required this.accent,
    this.physicalFormats = const [],
  });

  final LibraryTypeConfig type;
  final CatalogItem item;
  final OwnedItem? ownedItem;
  final Color accent;
  final List<PhysicalMediaFormat> physicalFormats;

  @override
  State<GenericLibraryEditDialog> createState() =>
      _GenericLibraryEditDialogState();
}

class _GenericLibraryEditDialogState extends State<GenericLibraryEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _numberController;
  late final TextEditingController _publisherController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _releaseYearController;
  late final TextEditingController _editionTitleController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _variantController;
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _conditionController;
  late final TextEditingController _gradeController;
  late final TextEditingController _purchaseDateController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _quantityController;
  late final TextEditingController _storageBoxController;
  late final TextEditingController _notesController;
  late final TextEditingController _ratingController;
  late final TextEditingController _trackingController;
  late final TextEditingController _tagsController;
  String? _physicalFormatId;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final owned = widget.ownedItem;
    _titleController = TextEditingController(text: item.title);
    _numberController = TextEditingController(text: item.itemNumber ?? '');
    _publisherController = TextEditingController(text: item.publisher ?? '');
    _releaseDateController = TextEditingController(
      text: item.releaseDate == null ? '' : _formatDate(item.releaseDate!),
    );
    _releaseYearController = TextEditingController(
      text: item.releaseYear?.toString() ?? '',
    );
    _editionTitleController =
        TextEditingController(text: item.editionTitle ?? '');
    _barcodeController = TextEditingController(text: item.barcode ?? '');
    _variantController = TextEditingController(text: item.variant ?? '');
    _coverController = TextEditingController(text: item.coverImageUrl ?? '');
    _thumbnailController =
        TextEditingController(text: item.thumbnailImageUrl ?? '');
    _synopsisController = TextEditingController(text: item.synopsis ?? '');
    _conditionController = TextEditingController(text: owned?.condition ?? '');
    _gradeController = TextEditingController(text: owned?.grade ?? '');
    _purchaseDateController = TextEditingController(
      text:
          owned?.purchaseDate == null ? '' : _formatDate(owned!.purchaseDate!),
    );
    _priceController = TextEditingController(
      text: owned?.pricePaidCents == null
          ? ''
          : (owned!.pricePaidCents! / 100).toStringAsFixed(2),
    );
    _currencyController = TextEditingController(text: owned?.currency ?? '');
    _quantityController = TextEditingController(
      text: (owned?.quantity ?? 1).toString(),
    );
    _storageBoxController =
        TextEditingController(text: owned?.storageBox ?? '');
    _notesController = TextEditingController(text: owned?.personalNotes ?? '');
    _ratingController =
        TextEditingController(text: owned?.rating?.toString() ?? '');
    _trackingController = TextEditingController(text: owned?.readStatus ?? '');
    _tagsController = TextEditingController(text: owned?.tags ?? '');
    _physicalFormatId = _initialPhysicalFormatId(item);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _publisherController.dispose();
    _releaseDateController.dispose();
    _releaseYearController.dispose();
    _editionTitleController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _coverController.dispose();
    _thumbnailController.dispose();
    _synopsisController.dispose();
    _conditionController.dispose();
    _gradeController.dispose();
    _purchaseDateController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _quantityController.dispose();
    _storageBoxController.dispose();
    _notesController.dispose();
    _ratingController.dispose();
    _trackingController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = libraryMediaFieldLabels(widget.type);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: kClzComicsTheme.copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: widget.accent,
            brightness: Brightness.dark,
            surface: kClzPanel,
          ),
          inputDecorationTheme: kClzComicsTheme.inputDecorationTheme.copyWith(
            labelStyle: const TextStyle(color: kClzTextMuted),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920, maxHeight: 740),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kClzPanel,
              border: Border.all(color: kClzDivider),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _titleBar(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(14),
                      children: [
                        _section(
                          title: 'Catalog snapshot',
                          child: _metadataFields(labels),
                        ),
                        const SizedBox(height: 12),
                        _section(
                          title: 'Cover',
                          child: _coverFields(),
                        ),
                        const SizedBox(height: 12),
                        _section(
                          title: 'Collection',
                          child: widget.ownedItem == null
                              ? _notOwnedNotice()
                              : _collectionFields(),
                        ),
                      ],
                    ),
                  ),
                  _footer(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleBar(BuildContext context) {
    return ColoredBox(
      color: widget.accent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Icon(widget.type.workspace.icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit ${widget.type.singularLabel.toLowerCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metadataFields(LibraryMediaFieldLabels labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _responsiveFields([
          _field(
            controller: _titleController,
            label: 'Title',
            validator: (value) =>
                _emptyToNull(value ?? '') == null ? 'Enter a title' : null,
          ),
          _field(controller: _numberController, label: labels.number),
        ]),
        const SizedBox(height: 10),
        _responsiveFields([
          _field(controller: _publisherController, label: labels.publisher),
          _field(
            controller: _editionTitleController,
            label: 'Edition title',
          ),
          _field(
            controller: _variantController,
            label: labels.variant,
          ),
          _field(controller: _barcodeController, label: labels.barcode),
        ]),
        if (widget.physicalFormats.isNotEmpty) ...[
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _physicalFormatId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Physical format',
            ),
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('No specific format'),
              ),
              for (final format in widget.physicalFormats)
                DropdownMenuItem<String>(
                  value: format.id,
                  child: Text(format.label),
                ),
            ],
            onChanged: (value) {
              final normalized = _emptyToNull(value ?? '');
              final format = _physicalFormatForId(normalized);
              final previousFormat = _physicalFormatForId(_physicalFormatId);
              final variant = _variantController.text.trim();
              final shouldReplaceVariant =
                  variant.isEmpty || previousFormat?.label == variant;
              setState(() {
                _physicalFormatId = format?.id;
                if (format != null && shouldReplaceVariant) {
                  _variantController.text = format.label;
                }
              });
            },
          ),
        ],
        const SizedBox(height: 10),
        _responsiveFields([
          _field(
            controller: _releaseDateController,
            label: 'Release date',
            hint: 'YYYY-MM-DD',
            validator: _optionalDateValidator,
          ),
          _field(
            controller: _releaseYearController,
            label: 'Release year',
            validator: _optionalIntValidator,
          ),
        ]),
        const SizedBox(height: 10),
        TextFormField(
          controller: _synopsisController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Synopsis'),
        ),
      ],
    );
  }

  Widget _coverFields() {
    return _responsiveFields([
      _field(controller: _coverController, label: 'Cover image URL'),
      _field(controller: _thumbnailController, label: 'Thumbnail image URL'),
    ]);
  }

  Widget _collectionFields() {
    return Column(
      children: [
        _responsiveFields([
          _field(controller: _conditionController, label: 'Condition'),
          _field(controller: _gradeController, label: 'Grade'),
          _field(
            controller: _quantityController,
            label: 'Quantity',
            validator: _positiveIntValidator,
          ),
        ]),
        const SizedBox(height: 10),
        _responsiveFields([
          _field(
            controller: _purchaseDateController,
            label: 'Purchase date',
            hint: 'YYYY-MM-DD',
            validator: _optionalDateValidator,
          ),
          _field(
            controller: _priceController,
            label: 'Price paid',
            validator: _optionalMoneyValidator,
          ),
          _field(controller: _currencyController, label: 'Currency'),
        ]),
        const SizedBox(height: 10),
        _responsiveFields([
          _field(controller: _storageBoxController, label: 'Storage'),
          _field(
            controller: _ratingController,
            label: 'Rating',
            validator: _optionalIntValidator,
          ),
          _field(controller: _trackingController, label: 'Tracking status'),
        ]),
        const SizedBox(height: 10),
        _field(controller: _tagsController, label: 'Tags'),
        const SizedBox(height: 10),
        TextFormField(
          controller: _notesController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Personal notes'),
        ),
      ],
    );
  }

  Widget _notOwnedNotice() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border.all(color: widget.accent.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: widget.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This item is not in your collection yet. Saving will update the local catalog snapshot; collection fields appear after you add it.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kClzTextMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        border: Border.all(color: kClzDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.accent,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _responsiveFields(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 620;
        if (!twoColumns) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                children[index],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 10),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _footer(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzToolbar,
        border: Border(top: BorderSide(color: kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text(
              widget.ownedItem == null
                  ? 'Catalog snapshot only'
                  : 'Catalog + collection fields',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: kClzTextMuted,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final selection = GenericLibraryEditSelection(
      catalogItem: CatalogItem(
        id: widget.item.id,
        kind: widget.item.kind,
        title: _titleController.text.trim(),
        itemNumber: _emptyToNull(_numberController.text),
        synopsis: _emptyToNull(_synopsisController.text),
        coverImageUrl: _emptyToNull(_coverController.text),
        thumbnailImageUrl: _emptyToNull(_thumbnailController.text),
        editionTitle: _emptyToNull(_editionTitleController.text),
        physicalFormat: _physicalFormatId,
        physicalFormatLabel: _physicalFormatForId(_physicalFormatId)?.label,
        publisher: _emptyToNull(_publisherController.text),
        releaseDate: _parseDate(_releaseDateController.text),
        releaseYear: _parseInt(_releaseYearController.text),
        barcode: _emptyToNull(_barcodeController.text),
        variant: _emptyToNull(_variantController.text),
      ),
      personal: widget.ownedItem == null
          ? null
          : GenericLibraryPersonalEditSelection(
              condition: _emptyToNull(_conditionController.text),
              grade: _emptyToNull(_gradeController.text),
              purchaseDate: _parseDate(_purchaseDateController.text),
              pricePaidCents: _parseMoneyCents(_priceController.text),
              currency: _emptyToNull(_currencyController.text),
              personalNotes: _emptyToNull(_notesController.text),
              quantity: _parseInt(_quantityController.text) ?? 1,
              storageBox: _emptyToNull(_storageBoxController.text),
              rating: _parseInt(_ratingController.text),
              readStatus: _emptyToNull(_trackingController.text),
              tags: _emptyToNull(_tagsController.text),
            ),
    );
    Navigator.of(context).pop(selection);
  }

  String? _initialPhysicalFormatId(CatalogItem item) {
    final configured = _physicalFormatForId(item.physicalFormat);
    if (configured != null) {
      return configured.id;
    }
    final byLabel = physicalMediaFormatByLabelOrId(
      item.physicalFormatLabel ?? item.variant,
      formats: widget.physicalFormats,
    );
    return byLabel?.id;
  }

  PhysicalMediaFormat? _physicalFormatForId(String? id) {
    final normalized = _emptyToNull(id ?? '');
    return normalized == null
        ? null
        : physicalMediaFormatById(
            normalized,
            formats: widget.physicalFormats,
          );
  }
}

class GenericLibraryEditSelection {
  const GenericLibraryEditSelection({
    required this.catalogItem,
    required this.personal,
  });

  final CatalogItem catalogItem;
  final GenericLibraryPersonalEditSelection? personal;
}

class GenericLibraryPersonalEditSelection {
  const GenericLibraryPersonalEditSelection({
    required this.condition,
    required this.grade,
    required this.purchaseDate,
    required this.pricePaidCents,
    required this.currency,
    required this.personalNotes,
    required this.quantity,
    required this.storageBox,
    required this.rating,
    required this.readStatus,
    required this.tags,
  });

  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? storageBox;
  final int? rating;
  final String? readStatus;
  final String? tags;
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? _parseDate(String value) {
  final normalized = _emptyToNull(value);
  return normalized == null ? null : DateTime.tryParse(normalized);
}

int? _parseInt(String value) {
  final normalized = _emptyToNull(value);
  return normalized == null ? null : int.tryParse(normalized);
}

int? _parseMoneyCents(String value) {
  final normalized = _emptyToNull(value)?.replaceAll(',', '.');
  if (normalized == null) {
    return null;
  }
  final parsed = double.tryParse(normalized);
  return parsed == null ? null : (parsed * 100).round();
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String? _optionalDateValidator(String? value) {
  final normalized = _emptyToNull(value ?? '');
  if (normalized == null) {
    return null;
  }
  return DateTime.tryParse(normalized) == null ? 'Use YYYY-MM-DD' : null;
}

String? _optionalIntValidator(String? value) {
  final normalized = _emptyToNull(value ?? '');
  if (normalized == null) {
    return null;
  }
  return int.tryParse(normalized) == null ? 'Enter a whole number' : null;
}

String? _positiveIntValidator(String? value) {
  final normalized = _emptyToNull(value ?? '');
  if (normalized == null) {
    return 'Enter a quantity';
  }
  final parsed = int.tryParse(normalized);
  return parsed == null || parsed < 1 ? 'Enter a quantity above 0' : null;
}

String? _optionalMoneyValidator(String? value) {
  final normalized = _emptyToNull(value ?? '')?.replaceAll(',', '.');
  if (normalized == null) {
    return null;
  }
  return double.tryParse(normalized) == null ? 'Enter an amount' : null;
}
