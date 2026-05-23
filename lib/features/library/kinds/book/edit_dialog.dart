import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/release_selection_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildBookLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return BookLibraryEditDialog(request: request);
}

class BookLibraryEditDialog extends ConsumerStatefulWidget {
  const BookLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  ConsumerState<BookLibraryEditDialog> createState() =>
      _BookLibraryEditDialogState();
}

class _BookLibraryEditDialogState extends ConsumerState<BookLibraryEditDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TabController _tabController;

  late final TextEditingController _titleController;
  late final TextEditingController _sortKeyController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _numberController;
  late final TextEditingController _publisherController;
  late final TextEditingController _editionTitleController;
  late final TextEditingController _countryController;
  late final TextEditingController _languageController;
  late final TextEditingController _imprintController;
  late final TextEditingController _seriesGroupController;
  late final TextEditingController _seriesTitleController;
  late final TextEditingController _volumeNameController;
  late final TextEditingController _volumeNumberController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _releaseYearController;
  late final TextEditingController _pageCountController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _variantController;
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _seriesTagsController;
  late final TextEditingController _creatorsController;
  late final TextEditingController _charactersController;
  late final TextEditingController _storyArcsController;
  late final TextEditingController _genresController;

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
  late final TextEditingController _sellPriceController;
  late final TextEditingController _soldToController;

  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  String? _selectedEditionId;
  String? _selectedVariantId;
  bool _locationChanged = false;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  DateTime? _soldAt;
  Map<String, String?> _customFieldEdits = {};
  List<ItemImageEdit> _itemImageEdits = [];

  bool get _isOwned => widget.request.ownedItem != null;

  bool get _hasTrackingContext => _isOwned || widget.request.trackingEntry != null;

  int get _tabCount => _isOwned ? 8 : _hasTrackingContext ? 7 : 6;

  LibraryTypeConfig get _type => widget.request.type;

  Color get _accent => widget.request.accent;

  String get _bookTitleLabel => _titleController.text.trim().isEmpty
      ? widget.request.item.title
      : _titleController.text.trim();

  @override
  void initState() {
    super.initState();
    final item = widget.request.item;
    final owned = widget.request.ownedItem;
    final tracking = widget.request.trackingEntry;
    _tabController = TabController(length: _tabCount, vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _titleController = TextEditingController(text: item.title);
    _sortKeyController = TextEditingController(text: item.sortKey ?? '');
    _subtitleController =
        TextEditingController(text: item.publishing?.subtitle ?? '');
    _numberController = TextEditingController(text: item.itemNumber ?? '');
    _publisherController = TextEditingController(text: item.publisher ?? '');
    _editionTitleController =
        TextEditingController(text: item.editionTitle ?? '');
    _countryController = TextEditingController(text: item.country ?? '');
    _languageController = TextEditingController(text: item.language ?? '');
    _imprintController =
        TextEditingController(text: item.publishing?.imprint ?? '');
    _seriesGroupController =
        TextEditingController(text: item.publishing?.seriesGroup ?? '');
    _seriesTitleController =
        TextEditingController(text: item.series?.seriesTitle ?? '');
    _volumeNameController =
        TextEditingController(text: item.series?.volumeName ?? '');
    _volumeNumberController =
        TextEditingController(text: item.series?.volumeNumber?.toString() ?? '');
    _releaseDateController = TextEditingController(
      text: item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    );
    _releaseYearController =
        TextEditingController(text: item.releaseYear?.toString() ?? '');
    _pageCountController =
        TextEditingController(text: item.publishing?.pageCount?.toString() ?? '');
    _barcodeController = TextEditingController(text: item.barcode ?? '');
    _variantController = TextEditingController(text: item.variant ?? '');
    _coverController = TextEditingController(text: item.coverImageUrl ?? '');
    _thumbnailController =
        TextEditingController(text: item.thumbnailImageUrl ?? '');
    _synopsisController = TextEditingController(text: item.synopsis ?? '');
    _seriesTagsController =
        TextEditingController(text: (item.series?.tags ?? const []).join(', '));
    _creatorsController = TextEditingController(
      text: _creatorNames(item.creators).join(', '),
    );
    _charactersController =
        TextEditingController(text: (item.characters ?? const []).join(', '));
    _storyArcsController =
        TextEditingController(text: (item.storyArcs ?? const []).join(', '));
    _genresController =
        TextEditingController(text: (item.genres ?? const []).join(', '));

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
    _quantityController =
        TextEditingController(text: (owned?.quantity ?? 1).toString());
    _notesController = TextEditingController(text: owned?.personalNotes ?? '');
    _ratingController =
      TextEditingController(text: (tracking?.rating ?? owned?.rating)?.toString() ?? '');
    _trackingController =
      TextEditingController(text: tracking?.status ?? owned?.readStatus ?? '');
    _tagsController = TextEditingController(text: owned?.tags ?? '');
    _sellPriceController = TextEditingController(
      text: owned?.sellPriceCents == null
          ? ''
          : (owned!.sellPriceCents! / 100).toStringAsFixed(2),
    );
    _soldToController = TextEditingController(text: owned?.soldTo ?? '');
    _selectedLocationId = owned?.locationId;
    _startedAt = tracking?.startedAt ?? owned?.startedAt;
    _finishedAt = tracking?.finishedAt ?? owned?.finishedAt;
    _soldAt = owned?.soldAt;
    final releaseSelection = resolveLibraryReleaseSelection(
      item.editions,
      editionId: owned?.editionId ?? tracking?.editionId,
      editionTitle: item.editionTitle,
      variantId: owned?.variantId ?? tracking?.variantId,
      variantName: item.variant,
    );
    _selectedEditionId = releaseSelection.edition?.id;
    _selectedVariantId = releaseSelection.variant?.id;
    _customFieldEdits = {
      for (final value in widget.request.customFieldValues)
        value.fieldDefinitionId: value.value,
    };

    for (final controller in [
      _titleController,
      _seriesTitleController,
      _volumeNumberController,
      _pageCountController,
      _languageController,
      _releaseDateController,
      _releaseYearController,
      _seriesTagsController,
    ]) {
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }

    if (_isOwned) {
      unawaited(_loadAvailableLocations());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _sortKeyController.dispose();
    _subtitleController.dispose();
    _numberController.dispose();
    _publisherController.dispose();
    _editionTitleController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _imprintController.dispose();
    _seriesGroupController.dispose();
    _seriesTitleController.dispose();
    _volumeNameController.dispose();
    _volumeNumberController.dispose();
    _releaseDateController.dispose();
    _releaseYearController.dispose();
    _pageCountController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _coverController.dispose();
    _thumbnailController.dispose();
    _synopsisController.dispose();
    _seriesTagsController.dispose();
    _creatorsController.dispose();
    _charactersController.dispose();
    _storyArcsController.dispose();
    _genresController.dispose();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: _accent,
      icon: _type.workspace.icon,
      title: 'Edit ${_type.singularLabel.toLowerCase()} — ${widget.request.item.title}',
      badges: [
        const EditMiniBadge('Books'),
        if (_isOwned) const EditMiniBadge('Owned'),
        if (!_isOwned && widget.request.trackingEntry != null)
          const EditMiniBadge('Tracked'),
        if (_seriesTitleController.text.trim().isNotEmpty)
          EditMiniBadge(_seriesTitleController.text.trim()),
        if (_selectedLocationLabel != null) EditMiniBadge(_selectedLocationLabel!),
      ],
      tabController: _tabController,
      tabs: _tabHeaders(),
      views: [
        _detailsTab(),
        _creditsTab(),
        _contentsTab(),
        _plotNotesTab(),
        _coversTab(),
        _linksTab(),
        if (_hasTrackingContext) _personalTab(),
        if (_isOwned) _photosTab(),
      ],
      footerLabel: null,
      footerFields: [
        FooterReadonlyField(
          label: 'Book',
          value: _bookTitleLabel,
          width: 180,
        ),
        FooterReadonlyField(
          label: 'Volume',
          value: _volumeNumberController.text,
          width: 74,
        ),
        FooterTextField(
          label: 'Title sort',
          controller: _sortKeyController,
          width: 160,
        ),
        FooterTextField(
          label: 'Series tags',
          controller: _seriesTagsController,
          width: 170,
        ),
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
    return [
      const EditTab(icon: Icons.menu_book, label: 'Details'),
      const EditTab(icon: Icons.groups_2, label: 'Credits & Characters'),
      const EditTab(icon: Icons.format_list_numbered, label: 'Contents'),
      const EditTab(icon: Icons.notes, label: 'Plot & Notes'),
      const EditTab(icon: Icons.image, label: 'Covers'),
      const EditTab(icon: Icons.link, label: 'Links'),
      if (_hasTrackingContext)
        const EditTab(icon: Icons.person, label: 'Personal'),
      if (_isOwned) const EditTab(icon: Icons.photo_library, label: 'Photos'),
    ];
  }

  Widget _detailsTab() {
    return EditTabShell(
      cover: _coverPreview(),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            EditSummaryPill(
              label: 'Series',
              value: _seriesTitleController.text,
              icon: Icons.collections_bookmark_outlined,
              width: 190,
            ),
            EditSummaryPill(
              label: 'Volume',
              value: _volumeNumberController.text,
              icon: Icons.filter_1_outlined,
              width: 96,
            ),
            EditSummaryPill(
              label: 'Pages',
              value: _pageCountController.text,
              icon: Icons.auto_stories_outlined,
              width: 96,
            ),
            EditSummaryPill(
              label: 'Language',
              value: _languageController.text,
              icon: Icons.language_outlined,
              width: 120,
            ),
          ],
        ),
        const SizedBox(height: 12),
        EditSection(
          title: 'Book details',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(
                  controller: _titleController,
                  label: 'Title',
                  validator: (value) =>
                      emptyToNull(value ?? '') == null ? 'Enter a title' : null,
                ),
                _field(controller: _sortKeyController, label: 'Title sort'),
                _field(controller: _subtitleController, label: 'Subtitle'),
                _field(controller: _numberController, label: 'Book number'),
                _field(controller: _publisherController, label: 'Publisher'),
                _field(controller: _editionTitleController, label: 'Edition'),
                _field(controller: _countryController, label: 'Country'),
                _field(controller: _languageController, label: 'Language'),
                _field(controller: _imprintController, label: 'Imprint'),
                _field(controller: _seriesGroupController, label: 'Series group'),
              ], wideColumns: 2, ultraWideColumns: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _creditsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Credits & discovery',
          accent: _accent,
          child: Column(
            children: [
              EditTokenListField(
                controller: _creatorsController,
                label: 'Creators',
                hint: 'Author, Illustrator',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _charactersController,
                label: 'Characters',
                hint: 'Add character',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _storyArcsController,
                label: 'Story arcs',
                hint: 'Add story arc',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _genresController,
                label: 'Genres',
                hint: 'Add genre',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _seriesTagsController,
                label: 'Series tags',
                hint: 'Add tag',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contentsTab() {
    return EditTabShell(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            EditSummaryPill(
              label: 'Book no.',
              value: _numberController.text,
              icon: Icons.bookmark_outline,
              width: 96,
            ),
            EditSummaryPill(
              label: 'Release',
              value: _releaseDateController.text.isEmpty
                  ? _releaseYearController.text
                  : _releaseDateController.text,
              icon: Icons.event_note_outlined,
              width: 132,
            ),
            EditSummaryPill(
              label: 'Series tags',
              value: _seriesTagsController.text,
              icon: Icons.sell_outlined,
              width: 220,
            ),
          ],
        ),
        const SizedBox(height: 12),
        EditSection(
          title: 'Series & contents',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(controller: _seriesTitleController, label: 'Series'),
                _field(controller: _volumeNameController, label: 'Volume'),
                _field(
                  controller: _volumeNumberController,
                  label: 'Volume number',
                  validator: optionalIntValidator,
                ),
                _field(
                  controller: _pageCountController,
                  label: 'Page count',
                  validator: optionalIntValidator,
                ),
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
              ], wideColumns: 2, ultraWideColumns: 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _plotNotesTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Plot',
          accent: _accent,
          child: TextFormField(
            controller: _synopsisController,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Plot / synopsis',
              alignLabelWithHint: true,
            ),
          ),
        ),
        if (_isOwned)
          EditSection(
            title: 'Notes',
            accent: _accent,
            child: TextFormField(
              controller: _notesController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                alignLabelWithHint: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _coversTab() {
    return EditTabShell(
      cover: _coverPreview(),
      children: [
        EditSection(
          title: 'Cover sources',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catalog cover links stay here. Local front/back cover scans are stored separately and drive the preview when available.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kEditTextMuted,
                    ),
              ),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: _coverController, label: 'Cover image URL'),
                _field(
                  controller: _thumbnailController,
                  label: 'Thumbnail image URL',
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linksTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Identifiers & links',
          accent: _accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(controller: _barcodeController, label: 'Barcode'),
                _field(controller: _variantController, label: 'Format / variant'),
              ]),
            ],
          ),
        ),
        if (widget.request.customFieldDefinitions.isNotEmpty)
          CustomFieldsEditSection(
            definitions: widget.request.customFieldDefinitions,
            values: _customFieldEdits,
            accent: _accent,
            onChanged: (values) => _customFieldEdits = values,
          ),
      ],
    );
  }

  Widget _personalTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: _isOwned ? 'Storage & Tracking' : 'Tracking',
          accent: _accent,
          child: Column(
            children: [
              if (widget.request.item.editions.isNotEmpty) ...[
                _responsiveFields([
                  _editionSelectionField(),
                  _variantSelectionField(),
                ]),
                const SizedBox(height: 10),
              ],
              _responsiveFields([
                  if (_isOwned) _locationField(),
                SizedBox(width: 120, child: MediaRatingField(controller: _ratingController)),
                SizedBox(
                  width: 180,
                  child: MediaTrackingStatusField(
                    profile: _type.trackingProfile,
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
                _responsiveFields([
                  _field(
                    controller: _priceController,
                    label: 'Price paid',
                    validator: optionalMoneyValidator,
                  ),
                  _field(controller: _currencyController, label: 'Currency'),
                ]),
                const SizedBox(height: 10),
                _responsiveFields([
                  _field(
                    controller: _sellPriceController,
                    label: 'Sell price',
                    validator: optionalMoneyValidator,
                  ),
                  _field(controller: _soldToController, label: 'Sold to'),
                ]),
              ],
              const SizedBox(height: 10),
              _responsiveFields([
                _datePickerField(
                  label: 'Started',
                  value: _startedAt,
                  onChanged: (value) => setState(() => _startedAt = value),
                ),
                _datePickerField(
                  label: 'Finished',
                  value: _finishedAt,
                  onChanged: (value) => setState(() => _finishedAt = value),
                ),
              ]),
            ],
          ),
        ),
        if (_isOwned)
          EditSection(
            title: 'Collection notes',
            accent: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _responsiveFields([
                  _field(controller: _conditionController, label: 'Condition'),
                  _field(controller: _gradeController, label: 'Grade'),
                  _field(
                    controller: _quantityController,
                    label: 'Quantity',
                    validator: positiveIntValidator,
                  ),
                ]),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickPurchaseDate,
                  icon: const Icon(Icons.event),
                  label: Text(
                    _purchaseDateController.text.isEmpty
                        ? 'Set purchase date'
                        : 'Purchase date: ${_purchaseDateController.text}',
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: _soldAt != null,
                  onChanged: (value) {
                    setState(() {
                      _soldAt = value ? DateTime.now() : null;
                    });
                  },
                  title: const Text('Mark as sold'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                if (_soldAt != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickSoldDate,
                    icon: const Icon(Icons.event),
                    label: Text('Sold date: ${formatDate(_soldAt!)}'),
                  ),
                  const SizedBox(height: 12),
                  SoldSummaryPanel(
                    pricePaidCents: parseMoneyCents(_priceController.text),
                    sellPriceCents: parseMoneyCents(_sellPriceController.text),
                    currency: _currencyController.text,
                  ),
                ],
              ],
            ),
          )
        else
          EditSection(
            title: 'Collection fields',
            accent: _accent,
            child: const Text(
              'Storage, quantity, value and personal ownership notes stay unavailable until you add a physical copy. Tracking progress is editable here.',
              style: TextStyle(color: kEditTextMuted),
            ),
          ),
      ],
    );
  }

  Widget _photosTab() {
    return EditTabShell(
      children: [
        ItemImagesEditSection(
          images: widget.request.itemImages,
          accent: _accent,
          onChanged: (edits) => _itemImageEdits = edits,
        ),
      ],
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

  Widget _denseFields(
    List<Widget> children, {
    int wideColumns = 2,
    int ultraWideColumns = 3,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 780
            ? ultraWideColumns
            : constraints.maxWidth >= 560
                ? wideColumns
                : 1;
        final fieldWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (10 * (columns - 1))) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final child in children)
              SizedBox(width: fieldWidth, child: child),
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

  Widget _readonlyInfoRow(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: SelectableText(value),
    );
  }

  Widget _coverPreview() {
    return LibraryInteractiveCover(
      title: _bookTitleLabel,
      itemNumber: emptyToNull(_numberController.text),
      imageUrl: emptyToNull(_thumbnailController.text) ??
          emptyToNull(_coverController.text) ??
          widget.request.item.displayCoverUrl,
      localBase64: _localImageData('front_cover'),
      secondaryLocalBase64: _localImageData('back_cover'),
      accentColor: _accent,
      borderRadius: 8,
    );
  }

  String? _localImageData(String imageType) {
    final matching = widget.request.itemImages
        .where((image) => image.imageType == imageType)
        .toList(growable: false);
    if (matching.isEmpty) {
      return null;
    }
    matching.sort((left, right) {
      final byOrder = left.sortOrder.compareTo(right.sortOrder);
      if (byOrder != 0) {
        return byOrder;
      }
      return left.createdAt.compareTo(right.createdAt);
    });
    return matching.first.imageData;
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
    final legacyLabel = widget.request.ownedItem?.storageBox?.trim();
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

  List<String> _creatorNames(List<Map<String, dynamic>>? creators) {
    return creators
            ?.map((entry) => entry['name']?.toString() ?? '')
            .where((value) => value.trim().isNotEmpty)
            .map((value) => value.trim())
            .toList(growable: false) ??
        const <String>[];
  }

  List<String>? _splitList(String value) {
    final normalized = value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    return normalized.isEmpty ? null : normalized;
  }

  List<Map<String, dynamic>>? _creatorList(String value) {
    final names = _splitList(value);
    if (names == null) {
      return null;
    }
    return [for (final name in names) {'name': name}];
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final updatedSeries = CatalogSeriesDetails(
      seriesId: widget.request.item.series?.seriesId,
      seriesTitle: emptyToNull(_seriesTitleController.text),
      volumeName: emptyToNull(_volumeNameController.text),
      volumeNumber: parseInt(_volumeNumberController.text),
      volumeStartYear: widget.request.item.series?.volumeStartYear,
      seasonNumber: widget.request.item.series?.seasonNumber,
      episodeNumber: widget.request.item.series?.episodeNumber,
      tags: _splitList(_seriesTagsController.text) ?? const <String>[],
    );
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: parseInt(_pageCountController.text),
      coverPriceCents: widget.request.item.publishing?.coverPriceCents,
      currency: widget.request.item.publishing?.currency,
      imprint: emptyToNull(_imprintController.text),
      subtitle: emptyToNull(_subtitleController.text),
      seriesGroup: emptyToNull(_seriesGroupController.text),
    );

    Navigator.of(context).pop(
      LibraryEditSelection(
        item: widget.request.item.copyWith(
          title: _titleController.text.trim(),
          sortKey: emptyToNull(_sortKeyController.text),
          itemNumber: emptyToNull(_numberController.text),
          synopsis: emptyToNull(_synopsisController.text),
          coverImageUrl: emptyToNull(_coverController.text),
          thumbnailImageUrl: emptyToNull(_thumbnailController.text),
          editionTitle: emptyToNull(_editionTitleController.text),
          publisher: emptyToNull(_publisherController.text),
          releaseDate: parseDate(_releaseDateController.text),
          releaseYear: parseInt(_releaseYearController.text),
          barcode: emptyToNull(_barcodeController.text),
          variant: emptyToNull(_variantController.text),
          series: updatedSeries.hasData ? updatedSeries : null,
          publishing: updatedPublishing.hasData ? updatedPublishing : null,
          creators: _creatorList(_creatorsController.text),
          characters: _splitList(_charactersController.text),
          storyArcs: _splitList(_storyArcsController.text),
          genres: _splitList(_genresController.text),
          country: emptyToNull(_countryController.text),
          language: emptyToNull(_languageController.text),
        ),
        personal: !_isOwned
            ? null
            : LibraryPersonalEditSelection(
            anchorType: (_selectedEditionId != null || _selectedVariantId != null)
              ? 'variant'
              : 'item',
            editionId: _selectedEditionId,
            variantId: _selectedVariantId,
            bundleReleaseId: null,
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
                rawOrSlabbed: null,
                gradingCompany: null,
                graderNotes: null,
                signedBy: null,
                keyComic: null,
                keyReason: null,
                coverPriceCents: null,
              ),
        tracking: !_hasTrackingContext
            ? null
            : LibraryTrackingEditSelection(
          editionId: _selectedEditionId,
          variantId: _selectedVariantId,
                rating: parseInt(_ratingController.text),
                readStatus: emptyToNull(_trackingController.text),
                startedAt: _startedAt,
                finishedAt: _finishedAt,
              ),
        customFieldEdits: _customFieldEdits,
        itemImageEdits: _itemImageEdits,
      ),
    );
  }

  CatalogEdition? _selectedEdition() {
    final selectedId = _selectedEditionId;
    if (selectedId == null) {
      return null;
    }
    for (final edition in widget.request.item.editions) {
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
        for (final edition in widget.request.item.editions)
          DropdownMenuItem<String>(
            value: edition.id,
            child: Text(edition.title),
          ),
      ],
      onChanged: (value) {
        final edition = resolveLibraryReleaseSelection(
          widget.request.item.editions,
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