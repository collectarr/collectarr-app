import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/release_selection_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryEditDialog extends ConsumerStatefulWidget {
  const LibraryEditDialog({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
    this.trackingEntry,
    required this.accent,
    this.physicalFormats = const [],
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final List<PhysicalMediaFormat> physicalFormats;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;

  @override
  ConsumerState<LibraryEditDialog> createState() =>
      _LibraryEditDialogState();
}

class _LibraryEditDialogState extends ConsumerState<LibraryEditDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TabController _tabController;

  // Catalog fields
  late final TextEditingController _titleController;
  late final TextEditingController _numberController;
  late final TextEditingController _publisherController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _releaseYearController;
  late final TextEditingController _pageCountController;
  late final TextEditingController _editionTitleController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _variantController;
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _synopsisController;

  // Series-level fields
  late final TextEditingController _imprintController;
  late final TextEditingController _seriesGroupController;

  // Collection fields
  late final TextEditingController _conditionController;
  late final TextEditingController _gradeController;
  late final TextEditingController _purchaseDateController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  late final TextEditingController _ratingController;
  late final TextEditingController _trackingController;
  late final TextEditingController _tagsController;
  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  String? _selectedEditionId;
  String? _selectedVariantId;
  bool _locationChanged = false;

  // Sold fields
  late final TextEditingController _sellPriceController;
  late final TextEditingController _soldToController;
  late DateTime? _soldAt;

  // Reading progress
  DateTime? _startedAt;
  DateTime? _finishedAt;

  // Comics-specific grading fields
  late final TextEditingController _rawOrSlabbedController;
  late final TextEditingController _gradingCompanyController;
  late final TextEditingController _graderNotesController;
  late final TextEditingController _signedByController;
  late final TextEditingController _coverPriceController;
  bool _keyComic = false;
  late final TextEditingController _keyReasonController;

  String? _physicalFormatId;
  Map<String, String?> _customFieldEdits = {};
  List<ItemImageEdit> _itemImageEdits = [];

  static const _ownedTabCount = 8;
  static const _trackedTabCount = 4;
  static const _catalogOnlyTabCount = 3;

  bool get _isOwned => widget.ownedItem != null;

  bool get _hasTrackingContext => _isOwned || widget.trackingEntry != null;

  bool get _isTrackingOnly => !_isOwned && widget.trackingEntry != null;

  bool get _isComicKind {
    final kind = widget.type.workspace.kind;
    return kind == 'comic' || kind == 'manga';
  }

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final owned = widget.ownedItem;
    final tracking = widget.trackingEntry;
    _tabController = TabController(
      length: _isOwned
          ? _ownedTabCount
          : _isTrackingOnly
              ? _trackedTabCount
              : _catalogOnlyTabCount,
      vsync: this,
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _titleController = TextEditingController(text: item.title);
    _numberController = TextEditingController(text: item.itemNumber ?? '');
    _publisherController = TextEditingController(text: item.publisher ?? '');
    _releaseDateController = TextEditingController(
      text: item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    );
    _releaseYearController = TextEditingController(
      text: item.releaseYear?.toString() ?? '',
    );
    _pageCountController = TextEditingController(
      text: item.publishing?.pageCount?.toString() ?? '',
    );
    _editionTitleController =
        TextEditingController(text: item.editionTitle ?? '');
    _barcodeController = TextEditingController(text: item.barcode ?? '');
    _variantController = TextEditingController(text: item.variant ?? '');
    _coverController = TextEditingController(text: item.coverImageUrl ?? '');
    _thumbnailController =
        TextEditingController(text: item.thumbnailImageUrl ?? '');
    _synopsisController = TextEditingController(text: item.synopsis ?? '');

    _imprintController = TextEditingController(
      text: item.publishing?.imprint ?? '',
    );
    _seriesGroupController = TextEditingController(
      text: item.publishing?.seriesGroup ?? '',
    );

    _conditionController = TextEditingController(text: owned?.condition ?? '');
    _gradeController = TextEditingController(text: owned?.grade ?? '');
    _purchaseDateController = TextEditingController(
      text: owned?.purchaseDate == null ? '' : formatDate(owned!.purchaseDate!),
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
    _notesController = TextEditingController(text: owned?.personalNotes ?? '');
    _ratingController =
        TextEditingController(text: (tracking?.rating ?? owned?.rating)?.toString() ?? '');
    _trackingController = TextEditingController(
      text: tracking?.status ?? owned?.readStatus ?? '',
    );
    _tagsController = TextEditingController(text: owned?.tags ?? '');
    _selectedLocationId = owned?.locationId;

    _sellPriceController = TextEditingController(
      text: owned?.sellPriceCents == null
          ? ''
          : (owned!.sellPriceCents! / 100).toStringAsFixed(2),
    );
    _soldToController = TextEditingController(text: owned?.soldTo ?? '');
    _soldAt = owned?.soldAt;
    _startedAt = tracking?.startedAt ?? owned?.startedAt;
    _finishedAt = tracking?.finishedAt ?? owned?.finishedAt;

    _rawOrSlabbedController =
        TextEditingController(text: owned?.rawOrSlabbed ?? '');
    _gradingCompanyController =
        TextEditingController(text: owned?.gradingCompany ?? '');
    _graderNotesController =
        TextEditingController(text: owned?.graderNotes ?? '');
    _signedByController = TextEditingController(text: owned?.signedBy ?? '');
    _coverPriceController = TextEditingController(
      text: owned?.coverPriceCents == null
          ? ''
          : (owned!.coverPriceCents! / 100).toStringAsFixed(2),
    );
    _keyComic = owned?.keyComic ?? false;
    _keyReasonController = TextEditingController(text: owned?.keyReason ?? '');
    final releaseSelection = resolveLibraryReleaseSelection(
      item.editions,
      editionId: owned?.editionId ?? tracking?.editionId,
      editionTitle: item.editionTitle,
      variantId: owned?.variantId ?? tracking?.variantId,
      variantName: item.variant,
    );
    _selectedEditionId = releaseSelection.edition?.id;
    _selectedVariantId = releaseSelection.variant?.id;

    _physicalFormatId = _initialPhysicalFormatId(item);

    _customFieldEdits = {
      for (final v in widget.customFieldValues) v.fieldDefinitionId: v.value,
    };

    if (_isOwned) {
      unawaited(_loadAvailableLocations());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _numberController.dispose();
    _publisherController.dispose();
    _releaseDateController.dispose();
    _releaseYearController.dispose();
    _pageCountController.dispose();
    _editionTitleController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _coverController.dispose();
    _thumbnailController.dispose();
    _synopsisController.dispose();
    _imprintController.dispose();
    _seriesGroupController.dispose();
    _conditionController.dispose();
    _gradeController.dispose();
    _purchaseDateController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _ratingController.dispose();
    _trackingController.dispose();
    _tagsController.dispose();
    _sellPriceController.dispose();
    _soldToController.dispose();
    _rawOrSlabbedController.dispose();
    _gradingCompanyController.dispose();
    _graderNotesController.dispose();
    _signedByController.dispose();
    _coverPriceController.dispose();
    _keyReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: widget.accent,
      icon: widget.type.workspace.icon,
      title: 'Edit ${widget.type.singularLabel.toLowerCase()} — ${widget.item.title}',
      badges: [
        if (_isOwned) const EditMiniBadge('Owned'),
        if (_isTrackingOnly) const EditMiniBadge('Tracked'),
        if (_soldAt != null) const EditMiniBadge('Sold'),
        if (_conditionController.text.trim().isNotEmpty)
          EditMiniBadge(_conditionController.text.trim()),
        if (_selectedLocationLabel != null)
          EditMiniBadge(_selectedLocationLabel!),
      ],
      tabController: _tabController,
      tabs: _tabHeaders(),
      views: _tabViews(),
        footerLabel: _isOwned
          ? 'Catalog + collection'
          : _isTrackingOnly
            ? 'Catalog + tracking'
            : 'Catalog snapshot only',
      footerFields: [
        if (_isOwned)
          FooterTextField(
            label: 'User tags',
            controller: _tagsController,
            width: 150,
          ),
      ],
      onPrevious: _previousTab,
      onNext: _nextTab,
      onCancel: () => Navigator.of(context).pop(),
      onSave: _submit,
    );
  }

  List<Widget> _tabHeaders() {
    return _isOwned
        ? const [
            EditTab(icon: Icons.article, label: 'Main'),
            EditTab(icon: Icons.attach_money, label: 'Value'),
            EditTab(icon: Icons.person, label: 'Personal'),
            EditTab(icon: Icons.sell, label: 'Sold'),
            EditTab(icon: Icons.tune, label: 'Custom'),
            EditTab(icon: Icons.photo_library, label: 'Photos'),
            EditTab(icon: Icons.image, label: 'Cover'),
            EditTab(icon: Icons.notes, label: 'Synopsis'),
          ]
        : _isTrackingOnly
            ? const [
                EditTab(icon: Icons.article, label: 'Main'),
                EditTab(icon: Icons.equalizer, label: 'Tracking'),
                EditTab(icon: Icons.image, label: 'Cover'),
                EditTab(icon: Icons.notes, label: 'Synopsis'),
              ]
            : const [
            EditTab(icon: Icons.article, label: 'Main'),
            EditTab(icon: Icons.image, label: 'Cover'),
            EditTab(icon: Icons.notes, label: 'Synopsis'),
          ];
  }

  List<Widget> _tabViews() {
    return _isOwned
        ? [
            _mainTab(),
            _valueTab(),
            _personalTab(),
            _soldTab(),
            _customFieldsTab(),
            _photosTab(),
            _coverTab(),
            _synopsisTab(),
          ]
        : _isTrackingOnly
            ? [
                _mainTab(),
                _personalTab(),
                _coverTab(),
                _synopsisTab(),
              ]
            : [
            _mainTab(),
            _coverTab(),
            _synopsisTab(),
          ];
  }

  // -------------------------------------------------------------------------
  // Tab: Main (catalog snapshot + condition/grade)
  // -------------------------------------------------------------------------

  Widget _mainTab() {
    final labels = libraryMediaFieldLabels(widget.type);
    return EditTabShell(
      children: [
        EditSection(
          title: 'Catalog snapshot',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(
                  controller: _titleController,
                  label: 'Title',
                  validator: (value) =>
                      emptyToNull(value ?? '') == null ? 'Enter a title' : null,
                ),
                _field(controller: _numberController, label: labels.number),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                    controller: _publisherController, label: labels.publisher),
                _field(
                    controller: _editionTitleController,
                    label: 'Edition title'),
                _field(controller: _variantController, label: labels.variant),
                _field(controller: _barcodeController, label: labels.barcode),
              ]),
              if (widget.physicalFormats.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _physicalFormatId,
                  isExpanded: true,
                  dropdownColor: kEditPanelRaised,
                  borderRadius: kEditMenuBorderRadius,
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
                    final normalized = emptyToNull(value ?? '');
                    final format = _physicalFormatForId(normalized);
                    final previousFormat =
                        _physicalFormatForId(_physicalFormatId);
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
                  validator: optionalDateValidator,
                ),
                _field(
                  controller: _releaseYearController,
                  label: 'Release year',
                  validator: optionalIntValidator,
                ),
                _field(
                  controller: _pageCountController,
                  label: 'Page count',
                  validator: optionalIntValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: _imprintController, label: 'Imprint'),
                _field(
                    controller: _seriesGroupController,
                    label: 'Series group'),
              ]),
            ],
          ),
        ),
        if (_hasTrackingContext)
          EditSection(
            title: _isOwned ? 'Condition & Grade' : 'Tracking release',
            accent: widget.accent,
            child: _responsiveFields([
              if (_isOwned) ...[
                _field(controller: _conditionController, label: 'Condition'),
                _field(controller: _gradeController, label: 'Grade'),
                _field(
                  controller: _quantityController,
                  label: 'Quantity',
                  validator: positiveIntValidator,
                ),
              ] else ...[
                _editionSelectionField(),
                _variantSelectionField(),
              ],
            ]),
          ),
        if (_isOwned && widget.item.editions.isNotEmpty)
          EditSection(
            title: 'Owned release',
            accent: widget.accent,
            child: _responsiveFields([
              _editionSelectionField(),
              _variantSelectionField(),
            ]),
          ),
        if (_isOwned && _isComicKind) ...[
          EditSection(
            title: 'Grading details',
            accent: widget.accent,
            child: Column(
              children: [
                _responsiveFields([
                  _field(
                    controller: _rawOrSlabbedController,
                    label: 'Raw / Slabbed',
                  ),
                  _field(
                    controller: _gradingCompanyController,
                    label: 'Grading company',
                  ),
                ]),
                const SizedBox(height: 10),
                _field(
                  controller: _graderNotesController,
                  label: 'Grader notes',
                ),
                const SizedBox(height: 10),
                _responsiveFields([
                  _field(controller: _signedByController, label: 'Signed by'),
                  _field(
                    controller: _coverPriceController,
                    label: 'Cover price',
                    validator: optionalMoneyValidator,
                  ),
                ]),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: _keyComic,
                  onChanged: (value) => setState(() => _keyComic = value),
                  title: const Text('Key comic'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                if (_keyComic) ...[
                  const SizedBox(height: 6),
                  _field(
                    controller: _keyReasonController,
                    label: 'Key reason (first appearance, etc.)',
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Value
  // -------------------------------------------------------------------------

  Widget _valueTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Purchase',
          accent: widget.accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(
                  controller: _priceController,
                  label: 'Price paid',
                  validator: optionalMoneyValidator,
                ),
                _field(controller: _currencyController, label: 'Currency'),
              ]),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickPurchaseDate,
                icon: const Icon(Icons.event),
                label: Text(
                  _purchaseDateController.text.isEmpty
                      ? 'Set purchase date'
                      : 'Purchase date: ${_purchaseDateController.text}',
                ),
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Value summary',
          accent: widget.accent,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ValueContextChip(
                icon: Icons.payments_outlined,
                label: 'Paid',
                value: _priceController.text.isEmpty
                    ? '—'
                    : '\$${_priceController.text}',
              ),
              ValueContextChip(
                icon: Icons.sell_outlined,
                label: 'Sell',
                value: _sellPriceController.text.isEmpty
                    ? '—'
                    : '\$${_sellPriceController.text}',
              ),
              ValueContextChip(
                icon: Icons.calendar_month_outlined,
                label: 'Purchased',
                value: _purchaseDateController.text.isEmpty
                    ? '—'
                    : _purchaseDateController.text,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Personal
  // -------------------------------------------------------------------------

  Widget _personalTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: _isOwned ? 'Storage & Tracking' : 'Tracking',
          accent: widget.accent,
          child: Column(
            children: [
              if (_isTrackingOnly && widget.item.editions.isNotEmpty) ...[
                _responsiveFields([
                  _editionSelectionField(),
                  _variantSelectionField(),
                ]),
                const SizedBox(height: 10),
              ],
              _responsiveFields([
                if (_isOwned) _locationField(),
                SizedBox(
                  width: 120,
                  child: MediaRatingField(controller: _ratingController),
                ),
                SizedBox(
                  width: 180,
                  child: MediaTrackingStatusField(
                    profile: widget.type.trackingProfile,
                    value: _trackingController.text,
                    label: 'Tracking status',
                    onChanged: (value) {
                      _trackingController.text = value ?? '';
                    },
                  ),
                ),
              ]),
              if (_isOwned) ...[
                const SizedBox(height: 10),
                _field(controller: _tagsController, label: 'Tags'),
                const SizedBox(height: 10),
              ],
              _responsiveFields([
                _datePickerField(
                  label: 'Started',
                  value: _startedAt,
                  onChanged: (v) => setState(() => _startedAt = v),
                ),
                _datePickerField(
                  label: 'Finished',
                  value: _finishedAt,
                  onChanged: (v) => setState(() => _finishedAt = v),
                ),
              ]),
            ],
          ),
        ),
        if (_isOwned)
          EditSection(
            title: 'Notes',
            accent: widget.accent,
            child: TextFormField(
              controller: _notesController,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                alignLabelWithHint: true,
              ),
            ),
          )
        else
          EditSection(
            title: 'Collection fields',
            accent: widget.accent,
            child: const Text(
              'Storage, value, quantity and personal notes are only available once the item has an owned copy. Tracking progress stays editable here.',
              style: TextStyle(color: kEditTextMuted),
            ),
          ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Sold
  // -------------------------------------------------------------------------

  Widget _soldTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Sold Status',
          accent: widget.accent,
          child: Column(
            children: [
              SwitchListTile(
                value: _soldAt != null,
                onChanged: (value) {
                  setState(() {
                    _soldAt = value ? DateTime.now() : null;
                  });
                },
                title: const Text('Mark as sold'),
                subtitle: _soldAt != null
                    ? Text(
                        'Sold on ${formatDate(_soldAt!)}',
                        style: const TextStyle(color: kEditTextMuted),
                      )
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
              if (_soldAt != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickSoldDate,
                  icon: const Icon(Icons.event),
                  label: Text('Sold date: ${formatDate(_soldAt!)}'),
                ),
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(
                    controller: _sellPriceController,
                    label: 'Sell price',
                    validator: optionalMoneyValidator,
                  ),
                  _field(controller: _soldToController, label: 'Sold to'),
                ]),
              ],
            ],
          ),
        ),
        if (_soldAt != null)
          EditSection(
            title: 'Profit / Loss',
            accent: widget.accent,
            child: SoldSummaryPanel(
              pricePaidCents: parseMoneyCents(_priceController.text),
              sellPriceCents: parseMoneyCents(_sellPriceController.text),
              currency: _currencyController.text,
            ),
          ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Custom fields
  // -------------------------------------------------------------------------

  Widget _customFieldsTab() {
    return EditTabShell(
      children: [
        CustomFieldsEditSection(
          definitions: widget.customFieldDefinitions,
          values: _customFieldEdits,
          accent: widget.accent,
          onChanged: (values) => _customFieldEdits = values,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Photos
  // -------------------------------------------------------------------------

  Widget _photosTab() {
    return EditTabShell(
      children: [
        ItemImagesEditSection(
          images: widget.itemImages,
          accent: widget.accent,
          onChanged: (edits) => _itemImageEdits = edits,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Cover
  // -------------------------------------------------------------------------

  Widget _coverTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Cover images',
          accent: widget.accent,
          child: _responsiveFields([
            _field(controller: _coverController, label: 'Cover image URL'),
            _field(
                controller: _thumbnailController,
                label: 'Thumbnail image URL'),
          ]),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Synopsis
  // -------------------------------------------------------------------------

  Widget _synopsisTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Synopsis',
          accent: widget.accent,
          child: TextFormField(
            controller: _synopsisController,
            minLines: 5,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Synopsis',
              alignLabelWithHint: true,
            ),
          ),
        ),
      ],
    );
  }


  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

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


  Widget _locationField() {
    final label = _selectedLocationLabel;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _pickLocation,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Location',
          suffixIcon: Icon(Icons.place),
        ),
        child: Text(
          label ?? 'No location selected',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: label == null ? kEditTextMuted : null,
              ),
        ),
      ),
    );
  }

  String? get _selectedLocationLabel {
    final locationLabel = locationPathForId(_availableLocations, _selectedLocationId);
    if (locationLabel != null) {
      return locationLabel;
    }
    if (_locationChanged) {
      return null;
    }
    final legacyLabel = widget.ownedItem?.storageBox?.trim();
    if (legacyLabel == null || legacyLabel.isEmpty) {
      return null;
    }
    return legacyLabel;
  }

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() => _availableLocations = locations);
  }

  Future<void> _pickLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _selectedLocationId,
    );
    if (result == null) {
      return;
    }
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _locationChanged = true;
      _selectedLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }

  void _previousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  void _nextTab() {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: parseDate(_purchaseDateController.text) ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) {
      setState(() {
        _purchaseDateController.text = formatDate(picked);
      });
    }
  }

  Future<void> _pickSoldDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _soldAt ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) {
      setState(() => _soldAt = picked);
    }
  }

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year + 10),
        );
        if (picked != null && mounted) {
          onChanged(picked);
        }
      },
      onLongPress: value != null ? () => onChanged(null) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          value != null ? formatDate(value) : '',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: parseInt(_pageCountController.text),
      coverPriceCents: widget.item.publishing?.coverPriceCents,
      currency: widget.item.publishing?.currency,
      imprint: emptyToNull(_imprintController.text),
      subtitle: widget.item.publishing?.subtitle,
      seriesGroup: emptyToNull(_seriesGroupController.text),
    );
    final selection = LibraryEditSelection(
      item: widget.item.copyWith(
        title: _titleController.text.trim(),
        itemNumber: emptyToNull(_numberController.text),
        synopsis: emptyToNull(_synopsisController.text),
        coverImageUrl: emptyToNull(_coverController.text),
        thumbnailImageUrl: emptyToNull(_thumbnailController.text),
        editionTitle: emptyToNull(_editionTitleController.text),
        physicalFormat: _physicalFormatId,
        physicalFormatLabel: _physicalFormatForId(_physicalFormatId)?.label,
        publisher: emptyToNull(_publisherController.text),
        releaseDate: parseDate(_releaseDateController.text),
        releaseYear: parseInt(_releaseYearController.text),
        barcode: emptyToNull(_barcodeController.text),
        variant: emptyToNull(_variantController.text),
        publishing: updatedPublishing.hasData ? updatedPublishing : null,
      ),
      personal: widget.ownedItem == null
          ? null
          : LibraryPersonalEditSelection(
            editionId: _selectedEditionId,
            variantId: _selectedVariantId,
              condition: emptyToNull(_conditionController.text),
              grade: emptyToNull(_gradeController.text),
              purchaseDate: parseDate(_purchaseDateController.text),
              pricePaidCents: parseMoneyCents(_priceController.text),
              currency: emptyToNull(_currencyController.text),
              personalNotes: emptyToNull(_notesController.text),
              quantity: parseInt(_quantityController.text) ?? 1,
              locationId: _selectedLocationId,
              locationChanged: _locationChanged,
              tags: emptyToNull(_tagsController.text),
              soldAt: _soldAt,
              sellPriceCents: parseMoneyCents(_sellPriceController.text),
              soldTo: emptyToNull(_soldToController.text),
              rawOrSlabbed: emptyToNull(_rawOrSlabbedController.text),
              gradingCompany: emptyToNull(_gradingCompanyController.text),
              graderNotes: emptyToNull(_graderNotesController.text),
              signedBy: emptyToNull(_signedByController.text),
              keyComic: _keyComic,
              keyReason: emptyToNull(_keyReasonController.text),
              coverPriceCents: parseMoneyCents(_coverPriceController.text),
            ),
        tracking: !_hasTrackingContext
          ? null
          : LibraryTrackingEditSelection(
            editionId: _isOwned ? _selectedEditionId : _selectedEditionId,
            variantId: _isOwned ? _selectedVariantId : _selectedVariantId,
              rating: parseInt(_ratingController.text),
              readStatus: emptyToNull(_trackingController.text),
              startedAt: _startedAt,
              finishedAt: _finishedAt,
            ),
      customFieldEdits: _customFieldEdits,
      itemImageEdits: _itemImageEdits,
    );
    Navigator.of(context).pop(selection);
  }

  String? _initialPhysicalFormatId(LibraryMetadataItem item) {
    final configured = _physicalFormatForId(item.physicalFormat);
    if (configured != null) return configured.id;
    final byLabel = physicalMediaFormatByLabelOrId(
      item.physicalFormatLabel ?? item.variant,
      formats: widget.physicalFormats,
    );
    return byLabel?.id;
  }

  PhysicalMediaFormat? _physicalFormatForId(String? id) {
    final normalized = emptyToNull(id ?? '');
    return normalized == null
        ? null
        : physicalMediaFormatById(
            normalized,
            formats: widget.physicalFormats,
          );
  }

  CatalogEdition? _selectedEdition() {
    final selectedId = _selectedEditionId;
    if (selectedId == null) {
      return null;
    }
    for (final edition in widget.item.editions) {
      if (edition.id == selectedId) {
        return edition;
      }
    }
    return null;
  }

  Widget _editionSelectionField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedEditionId,
      isExpanded: true,
      dropdownColor: kEditPanelRaised,
      borderRadius: kEditMenuBorderRadius,
      decoration: const InputDecoration(labelText: 'Owned edition'),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text('Primary / unspecified edition'),
        ),
        for (final edition in widget.item.editions)
          DropdownMenuItem<String>(
            value: edition.id,
            child: Text(edition.title),
          ),
      ],
      onChanged: (value) {
        final edition = resolveLibraryReleaseSelection(
          widget.item.editions,
          editionId: emptyToNull(value ?? ''),
        ).edition;
        setState(() {
          _selectedEditionId = edition?.id;
          _selectedVariantId = resolveVariantForEdition(edition)?.id;
        });
      },
    );
  }

  Widget _variantSelectionField() {
    final edition = _selectedEdition();
    final variants = edition?.variants ?? const <CatalogVariant>[];
    return DropdownButtonFormField<String>(
      initialValue: _selectedVariantId,
      isExpanded: true,
      dropdownColor: kEditPanelRaised,
      borderRadius: kEditMenuBorderRadius,
      decoration: const InputDecoration(labelText: 'Owned variant'),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text('Primary / unspecified variant'),
        ),
        for (final variant in variants)
          DropdownMenuItem<String>(
            value: variant.id,
            child: Text(variant.name),
          ),
      ],
      onChanged: variants.isEmpty
          ? null
          : (value) {
              setState(() {
                _selectedVariantId = emptyToNull(value ?? '');
              });
            },
    );
  }
}

// ---------------------------------------------------------------------------
// Selection data classes
// ---------------------------------------------------------------------------

class LibraryEditSelection {
  const LibraryEditSelection({
    required this.item,
    required this.personal,
    this.tracking,
    this.customFieldEdits = const {},
    this.itemImageEdits = const [],
  });

  final LibraryMetadataItem item;
  final LibraryPersonalEditSelection? personal;
  final LibraryTrackingEditSelection? tracking;
  final Map<String, String?> customFieldEdits;
  final List<ItemImageEdit> itemImageEdits;
}

class LibraryPersonalEditSelection {
  const LibraryPersonalEditSelection({
    required this.editionId,
    required this.variantId,
    required this.condition,
    required this.grade,
    required this.purchaseDate,
    required this.pricePaidCents,
    required this.currency,
    required this.personalNotes,
    required this.quantity,
    required this.locationId,
    required this.locationChanged,
    required this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.keyComic,
    this.keyReason,
    this.coverPriceCents,
  });

  final String? editionId;
  final String? variantId;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? locationId;
  final bool locationChanged;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final bool? keyComic;
  final String? keyReason;
  final int? coverPriceCents;
}

class LibraryTrackingEditSelection {
  const LibraryTrackingEditSelection({
    required this.editionId,
    required this.variantId,
    required this.rating,
    required this.readStatus,
    this.startedAt,
    this.finishedAt,
  });

  final String? editionId;
  final String? variantId;
  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
}
