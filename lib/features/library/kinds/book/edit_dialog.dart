import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildBookLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return BookLibraryEditDialog(
    request: request,
    draft: LibraryEditDraft.fromRequest(request),
  );
}

class BookLibraryEditDialog extends ConsumerStatefulWidget {
  const BookLibraryEditDialog({
    super.key,
    required this.request,
    this.draft,
  });

  final LibraryEditDialogRequest request;
  final LibraryEditDraft? draft;

  @override
  ConsumerState<BookLibraryEditDialog> createState() =>
      _BookLibraryEditDialogState();
}

class _BookLibraryEditDialogState extends ConsumerState<BookLibraryEditDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final LibraryEditDraft _draft;

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
  late final TextEditingController _wishlistPriceController;
  late final TextEditingController _wishlistCurrencyController;
  late final TextEditingController _wishlistNotesController;

  List<String> _tagOptions = const [];
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

  bool get _isTrackingOnly => !_isOwned && widget.request.trackingEntry != null;

  bool get _hasWishlistContext => widget.request.wishlistItem != null;

  LibraryTypeConfig get _type => widget.request.type;

  Color get _accent => widget.request.accent;

  LibraryEditPresentationContext get _tabPresentationContext {
    return LibraryEditPresentationContext(
      isOwned: _isOwned,
      isTrackingOnly: _isTrackingOnly,
      hasTrackingContext: _hasTrackingContext,
      hasWishlistContext: _hasWishlistContext,
      isDigitalFormat: false,
      hasPhysicalFormats: false,
      hasEditionAnchors: widget.request.item.editions.isNotEmpty,
      hasBundleReleaseAnchors: false,
      hasCustomFields: widget.request.customFieldDefinitions.isNotEmpty,
    );
  }

  List<LibraryEditTabSpec> get _tabSpecs {
    return _type.editPresentation.builder.buildTabs(
      context: _tabPresentationContext,
    );
  }

  String get _bookTitleLabel => _titleController.text.trim().isEmpty
      ? widget.request.item.title
      : _titleController.text.trim();

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? LibraryEditDraft.fromRequest(widget.request);
    final item = widget.request.item;
    final owned = widget.request.ownedItem;
    final tracking = widget.request.trackingEntry;
    _tabController = TabController(length: _tabSpecs.length, vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _titleController = _draft.titleController;
    _sortKeyController = _draft.sortKeyController;
    _subtitleController =
        TextEditingController(text: item.publishing?.subtitle ?? '');
    _numberController = _draft.numberController;
    _publisherController = _draft.publisherController;
    _editionTitleController = _draft.editionTitleController;
    _countryController = _draft.countryController;
    _languageController = _draft.languageController;
    _imprintController = _draft.imprintController;
    _seriesGroupController = _draft.seriesGroupController;
    _seriesTitleController =
        TextEditingController(text: item.series?.seriesTitle ?? '');
    _volumeNameController =
        TextEditingController(text: item.series?.volumeName ?? '');
    _volumeNumberController =
        TextEditingController(text: item.series?.volumeNumber?.toString() ?? '');
    _releaseDateController = _draft.releaseDateController;
    _releaseYearController = _draft.releaseYearController;
    _pageCountController = _draft.pageCountController;
    _barcodeController = _draft.barcodeController;
    _variantController = _draft.variantController;
    _coverController = _draft.coverController;
    _thumbnailController = _draft.thumbnailController;
    _synopsisController = _draft.synopsisController;
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

    _conditionController = _draft.conditionController;
    _gradeController = _draft.gradeController;
    _purchaseDateController = _draft.purchaseDateController;
    _priceController = _draft.priceController;
    _currencyController = _draft.currencyController;
    _quantityController = _draft.quantityController;
    _notesController = _draft.notesController;
    _ratingController = _draft.ratingController;
    _trackingController = _draft.trackingController;
    _tagsController = _draft.tagsController;
    _tagOptions = List<String>.from(_draft.tagOptions);
    _sellPriceController = _draft.sellPriceController;
    _soldToController = _draft.soldToController;
    _wishlistPriceController = _draft.wishlistPriceController;
    _wishlistCurrencyController = _draft.wishlistCurrencyController;
    _wishlistNotesController = _draft.wishlistNotesController;
    _selectedLocationId = _draft.selectedLocationId;
    _startedAt = _draft.startedAt;
    _finishedAt = _draft.finishedAt;
    _soldAt = _draft.soldAt;
    final editionSelection = resolveLibraryEditionSelection(
      item.editions,
      editionId: owned?.editionId ?? tracking?.editionId,
      editionTitle: item.editionTitle,
      variantId: owned?.variantId ?? tracking?.variantId,
      variantName: item.variant,
    );
    _selectedEditionId = editionSelection.edition?.id;
    _selectedVariantId = editionSelection.variant?.id;
    _customFieldEdits = Map<String, String?>.from(_draft.customFieldEdits);
    _itemImageEdits = List<ItemImageEdit>.from(_draft.itemImageEdits);

    unawaited(_loadTagOptions());

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
    _subtitleController.dispose();
    _seriesTitleController.dispose();
    _volumeNameController.dispose();
    _volumeNumberController.dispose();
    _seriesTagsController.dispose();
    _creatorsController.dispose();
    _charactersController.dispose();
    _storyArcsController.dispose();
    _genresController.dispose();
    _draft.dispose();
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
      tabs: [for (final tab in _tabSpecs) EditTab(icon: tab.icon, label: tab.label)],
      views: _tabViews(),
      onClose: () => Navigator.of(context).pop(),
      onSave: _submit,
      tabOrderKey: 'edit_tab_order_${_type.workspace.kind.apiValue}',
      ebaySearchQuery: widget.request.item.itemNumber != null
          ? '${widget.request.item.title} #${widget.request.item.itemNumber}'
          : widget.request.item.title,
    );
  }

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  List<String> _tabSectionIds(String tabId) {
    return _type.editPresentation.builder.buildTabSectionIds(
      context: _tabPresentationContext,
      tabId: tabId,
    );
  }

  Widget _tabViewFor(String id) {
    switch (id) {
      case 'details':
        return _detailsTab();
      case 'credits':
        return _creditsTab();
      case 'contents':
        return _contentsTab();
      case 'plot_notes':
        return _plotNotesTab();
      case 'covers':
        return _coversTab();
      case 'links':
        return _linksTab();
      case 'personal':
        return _personalTab();
      case 'photos':
        return _photosTab();
      default:
        throw StateError('Unsupported book edit tab: $id');
    }
  }

  Widget _detailsTab() {
    final sections = _tabSectionIds('details');
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
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _creditsTab() {
    final sections = _tabSectionIds('credits');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _contentsTab() {
    final sections = _tabSectionIds('contents');
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
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _plotNotesTab() {
    final sections = _tabSectionIds('plot_notes');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _coversTab() {
    final sections = _tabSectionIds('covers');
    return EditTabShell(
      cover: _coverPreview(),
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _linksTab() {
    final sections = _tabSectionIds('links');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _personalTab() {
    final sections = _tabSectionIds('personal');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _photosTab() {
    final sections = _tabSectionIds('photos');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _sectionFor(String id) {
    switch (id) {
      case 'book_details':
        return EditSection(
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
                _field(controller: _numberController, label: _type.mediaFields.numberLabel),
                _field(controller: _publisherController, label: _type.mediaFields.publisherLabel),
                _field(controller: _editionTitleController, label: _type.releaseFields.editionTitleLabel),
                _field(controller: _countryController, label: 'Country'),
                _field(controller: _languageController, label: 'Language'),
                _field(controller: _imprintController, label: 'Imprint'),
                _field(controller: _seriesGroupController, label: 'Series group'),
              ], wideColumns: 2, ultraWideColumns: 4),
            ],
          ),
        );
      case 'book_credits':
        return EditSection(
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
        );
      case 'book_contents':
        return EditSection(
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
        );
      case 'book_plot':
        return EditSection(
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
        );
      case 'book_notes':
        return EditSection(
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
        );
      case 'book_cover_sources':
        return EditSection(
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
        );
      case 'book_identifiers_links':
        return EditSection(
          title: 'Identifiers & links',
          accent: _accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(controller: _barcodeController, label: _type.releaseFields.barcodeLabel),
                _field(controller: _variantController, label: _type.releaseFields.variantLabel),
              ]),
            ],
          ),
        );
      case 'book_custom_fields':
        return CustomFieldsEditSection(
          definitions: widget.request.customFieldDefinitions,
          values: _customFieldEdits,
          accent: _accent,
          onChanged: (values) => _customFieldEdits = values,
        );
      case 'book_personal_tracking':
        return EditSection(
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
                TagPickListField(
                  controller: _tagsController,
                  options: _tagOptions,
                  label: 'Tags',
                  hint: 'Comma-separated tags',
                ),
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
        );
      case 'book_collection_notes':
        return EditSection(
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
        );
      case 'book_collection_fields_info':
        return EditSection(
          title: 'Collection fields',
          accent: _accent,
          child: const Text(
            'Storage, quantity, value and personal ownership notes stay unavailable until you add a physical copy. Tracking progress is editable here.',
            style: TextStyle(color: kEditTextMuted),
          ),
        );
      case 'book_wishlist_reference':
        return EditSection(
          title: 'Wishlist',
          accent: _accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(
                  controller: _wishlistPriceController,
                  label: 'Target price',
                  validator: optionalMoneyValidator,
                ),
                _field(
                  controller: _wishlistCurrencyController,
                  label: 'Currency',
                ),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: _wishlistNotesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Wishlist notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        );
      case 'book_photos':
        return ItemImagesEditSection(
          images: widget.request.itemImages,
          accent: _accent,
          onChanged: (edits) => _itemImageEdits = edits,
        );
      default:
        throw StateError('Unsupported book section: $id');
    }
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
            : constraints.maxWidth >= kAppStackedBreakpoint
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
    return null;
  }

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() => _availableLocations = locations);
  }

  Future<void> _loadTagOptions() async {
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.request.type.workspace.kind.apiValue,
      selectedTags: splitPickListValues(_tagsController.text),
    );
    if (!mounted) {
      return;
    }
    setState(() => _tagOptions = tagOptions);
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
                  tooltip: 'Clear date',
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
    _draft.tagOptions = List<String>.from(_tagOptions);
    _draft.availableLocations = List<StorageLocation>.from(_availableLocations);
    _draft.selectedLocationId = _selectedLocationId;
    _draft.selectedEditionId = _selectedEditionId;
    _draft.selectedVariantId = _selectedVariantId;
    _draft.locationChanged = _locationChanged;
    _draft.startedAt = _startedAt;
    _draft.finishedAt = _finishedAt;
    _draft.soldAt = _soldAt;
    _draft.customFieldEdits = Map<String, String?>.from(_customFieldEdits);
    _draft.itemImageEdits = List<ItemImageEdit>.from(_itemImageEdits);
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
                progressCurrent: widget.request.trackingEntry?.progressCurrent,
                progressTotal: widget.request.trackingEntry?.progressTotal,
                timesCompleted: widget.request.trackingEntry?.timesCompleted,
                notes: widget.request.trackingEntry?.notes,
                seasonNumber: widget.request.trackingEntry?.seasonNumber ?? widget.request.item.series?.seasonNumber,
                episodeNumber: widget.request.trackingEntry?.episodeNumber ?? widget.request.item.series?.episodeNumber,
              ),
        customFieldEdits: _customFieldEdits,
        itemImageEdits: _itemImageEdits,
        wishlist: !_hasWishlistContext
            ? null
            : LibraryWishlistEditSelection(
                anchorType: (_selectedEditionId != null || _selectedVariantId != null)
                    ? 'variant'
                    : 'item',
                editionId: _selectedEditionId,
                variantId: _selectedVariantId,
                bundleReleaseId: null,
                targetPriceCents:
                    parseMoneyCents(_wishlistPriceController.text),
                currency: emptyToNull(_wishlistCurrencyController.text),
                notes: emptyToNull(_wishlistNotesController.text),
              ),
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
        final edition = resolveLibraryEditionSelection(
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