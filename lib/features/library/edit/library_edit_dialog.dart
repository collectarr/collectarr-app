import 'dart:async';

import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/tracking/tracking_editor_widgets.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/settings/pick_list_options.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'library_edit_dialog_anchor_widgets.dart';

class LibraryEditDialog extends ConsumerStatefulWidget {
  const LibraryEditDialog({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
    this.wishlistItem,
    this.trackingEntry,
    required this.accent,
    this.availableBundleReleases = const [],
    this.physicalFormats = const [],
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final OwnedItem? ownedItem;
  final WishlistItem? wishlistItem;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final List<BundleReleaseSummary> availableBundleReleases;
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
  late final TextEditingController _wishlistPriceController;
  late final TextEditingController _wishlistCurrencyController;
  late final TextEditingController _wishlistNotesController;
  late final TextEditingController _ratingController;
  late final TextEditingController _trackingController;
  late final TextEditingController _progressCurrentController;
  late final TextEditingController _progressTotalController;
  late final TextEditingController _timesCompletedController;
  late final TextEditingController _seasonNumberController;
  late final TextEditingController _episodeNumberController;
  late final TextEditingController _trackingNotesController;
  late final TextEditingController _tagsController;
  List<String> _tagOptions = const [];
  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  String _selectedOwnedAnchorType = PersonalItemAnchorType.item.apiValue;
  String? _selectedEditionId;
  String? _selectedVariantId;
  String? _selectedBundleReleaseId;
  String? _selectedTrackingEditionId;
  String? _selectedTrackingVariantId;
  String _selectedWishlistAnchorType = PersonalItemAnchorType.item.apiValue;
  String? _selectedWishlistEditionId;
  String? _selectedWishlistVariantId;
  String? _selectedWishlistBundleReleaseId;
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

  bool get _isOwned => widget.ownedItem != null;

  bool get _hasTrackingContext => _isOwned || widget.trackingEntry != null;

  bool get _isTrackingOnly => !_isOwned && widget.trackingEntry != null;

  bool get _hasWishlistContext => widget.wishlistItem != null;

  LibraryEditPresentationContext get _editPresentationContext {
    return LibraryEditPresentationContext(
      isOwned: _isOwned,
      isTrackingOnly: _isTrackingOnly,
      hasTrackingContext: _hasTrackingContext,
      hasWishlistContext: _hasWishlistContext,
      isDigitalFormat: _isDigitalFormat,
      hasPhysicalFormats: widget.physicalFormats.isNotEmpty,
      hasEditionAnchors: widget.item.editions.isNotEmpty,
      hasBundleReleaseAnchors: widget.availableBundleReleases.isNotEmpty,
      hasCustomFields: widget.customFieldDefinitions.isNotEmpty,
    );
  }

  LibraryEditPresentationContext get _initialEditPresentationContext {
    return LibraryEditPresentationContext(
      isOwned: _isOwned,
      isTrackingOnly: _isTrackingOnly,
      hasTrackingContext: _hasTrackingContext,
      hasWishlistContext: _hasWishlistContext,
      isDigitalFormat: false,
      hasPhysicalFormats: widget.physicalFormats.isNotEmpty,
      hasEditionAnchors: widget.item.editions.isNotEmpty,
      hasBundleReleaseAnchors: widget.availableBundleReleases.isNotEmpty,
      hasCustomFields: widget.customFieldDefinitions.isNotEmpty,
    );
  }

  List<LibraryEditTabSpec> get _tabSpecs {
    return widget.type.editPresentation.builder.buildTabs(
      context: _editPresentationContext,
    );
  }

  LibraryEditFooterSpec get _footerSpec {
    return widget.type.editPresentation.builder.buildFooter(
      context: _editPresentationContext,
    );
  }

  LibraryEditPresentationState get _editPresentation {
    return widget.type.editPresentation.builder.build(
      context: _editPresentationContext,
    );
  }

  bool get _isDigitalFormat {
    return isDigitalPhysicalMediaFormat(
      _physicalFormatId,
      label: _physicalFormatForId(_physicalFormatId)?.label ??
          widget.item.physicalFormatLabel ??
          _variantController.text,
      formats: widget.physicalFormats.isEmpty
          ? allKnownPhysicalMediaFormats
          : widget.physicalFormats,
    );
  }

  bool get _showPhysicalOwnedFields => _isOwned && !_isDigitalFormat;

  bool get _showsEpisodeTrackingFields {
    final series = widget.item.series;
    return widget.type.trackingProfile.name == videoTrackingProfile.name ||
        series?.seasonNumber != null ||
        series?.episodeNumber != null ||
        _seasonNumberController.text.trim().isNotEmpty ||
        _episodeNumberController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final owned = widget.ownedItem;
    final wishlist = widget.wishlistItem;
    final tracking = widget.trackingEntry;
    _tabController = TabController(
      length: widget.type.editPresentation.builder
          .buildTabs(context: _initialEditPresentationContext)
          .length,
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
    _wishlistPriceController = TextEditingController(
      text: wishlist?.targetPriceCents == null
          ? ''
          : (wishlist!.targetPriceCents! / 100).toStringAsFixed(2),
    );
    _wishlistCurrencyController =
        TextEditingController(text: wishlist?.currency ?? '');
    _wishlistNotesController = TextEditingController(text: wishlist?.notes ?? '');
    _ratingController =
        TextEditingController(text: (tracking?.rating ?? owned?.rating)?.toString() ?? '');
    _trackingController = TextEditingController(
      text: tracking?.statusStorageValue ?? owned?.readStatus ?? '',
    );
    _progressCurrentController = TextEditingController(
      text: tracking?.progressCurrent?.toString() ?? '',
    );
    _progressTotalController = TextEditingController(
      text: tracking?.progressTotal?.toString() ?? '',
    );
    _timesCompletedController = TextEditingController(
      text: tracking?.timesCompleted?.toString() ?? '',
    );
    _seasonNumberController = TextEditingController(
      text: (tracking?.seasonNumber ?? item.series?.seasonNumber)?.toString() ?? '',
    );
    _episodeNumberController = TextEditingController(
      text: (tracking?.episodeNumber ?? item.series?.episodeNumber)?.toString() ?? '',
    );
    _trackingNotesController = TextEditingController(text: tracking?.notes ?? '');
    _tagsController = TextEditingController(text: owned?.tags ?? '');
    _tagOptions = splitPickListValues(owned?.tags);
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
    final editionSelection = resolveLibraryEditionSelection(
      item.editions,
      editionId: owned?.editionId ?? tracking?.editionId,
      editionTitle: item.editionTitle,
      variantId: owned?.variantId ?? tracking?.variantId,
      variantName: item.variant,
    );
    final wishlistEditionSelection = resolveLibraryEditionSelection(
      item.editions,
      editionId: wishlist?.editionId,
      editionTitle: item.editionTitle,
      variantId: wishlist?.variantId,
      variantName: item.variant,
    );
    _selectedOwnedAnchorType =
        owned?.personalAnchor?.apiValue ?? PersonalItemAnchorType.item.apiValue;
    _selectedEditionId = editionSelection.edition?.id;
    _selectedVariantId = editionSelection.variant?.id;
    _selectedBundleReleaseId = _normalizedId(owned?.bundleReleaseId);
    _selectedTrackingEditionId = tracking?.editionId ?? _selectedEditionId;
    _selectedTrackingVariantId = tracking?.variantId ?? _selectedVariantId;
    _selectedWishlistAnchorType =
        wishlist?.personalAnchor?.apiValue ?? PersonalItemAnchorType.item.apiValue;
    _selectedWishlistEditionId = wishlistEditionSelection.edition?.id;
    _selectedWishlistVariantId = wishlistEditionSelection.variant?.id;
    _selectedWishlistBundleReleaseId = _normalizedId(wishlist?.bundleReleaseId);

    _physicalFormatId = _initialPhysicalFormatId(item);

    _customFieldEdits = {
      for (final v in widget.customFieldValues) v.fieldDefinitionId: v.value,
    };

    if (_isOwned) {
      unawaited(_loadAvailableLocations());
      unawaited(_loadTagOptions());
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
    _wishlistPriceController.dispose();
    _wishlistCurrencyController.dispose();
    _wishlistNotesController.dispose();
    _ratingController.dispose();
    _trackingController.dispose();
    _progressCurrentController.dispose();
    _progressTotalController.dispose();
    _timesCompletedController.dispose();
    _seasonNumberController.dispose();
    _episodeNumberController.dispose();
    _trackingNotesController.dispose();
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
      tabs: [for (final tab in _tabSpecs) EditTab(icon: tab.icon, label: tab.label)],
      views: _tabViews(),
      footerLabel: _footerSpec.label,
      footerFields: [for (final fieldId in _footerSpec.fieldIds) _footerFieldFor(fieldId)],
      onPrevious: _previousTab,
      onNext: _nextTab,
      onCancel: () => Navigator.of(context).pop(),
      onSave: _submit,
    );
  }

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  Widget _tabViewFor(String id) {
    switch (id) {
      case 'main':
        return _mainTab();
      case 'value':
        return _valueTab();
      case 'personal':
        return _personalTab();
      case 'sold':
        return _soldTab();
      case 'custom':
        return _customFieldsTab();
      case 'photos':
        return _photosTab();
      case 'cover':
        return _coverTab();
      case 'synopsis':
        return _synopsisTab();
      default:
        throw StateError('Unsupported generic edit tab: $id');
    }
  }

  Widget _footerFieldFor(String id) {
    switch (id) {
      case 'user_tags':
        return FooterTextField(
          label: 'User tags',
          controller: _tagsController,
          width: 150,
        );
      default:
        throw StateError('Unsupported generic footer field: $id');
    }
  }

  // -------------------------------------------------------------------------
  // Tab: Main (catalog snapshot + condition/grade)
  // -------------------------------------------------------------------------

  Widget _mainTab() {
    final labels = libraryMediaFieldLabels(widget.type);
    final editPresentation = _editPresentation;
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
              if (editPresentation.showsPhysicalFormatSelector) ...[
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
            title: editPresentation.trackingSectionTitle,
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (editPresentation.trackingSectionHint != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      editPresentation.trackingSectionHint!,
                      style: const TextStyle(color: kEditTextMuted),
                    ),
                  ),
                _responsiveFields([
                  if (_showPhysicalOwnedFields) ...[
                    _field(controller: _conditionController, label: 'Condition'),
                    _field(controller: _gradeController, label: 'Grade'),
                  ],
                  if (_isOwned)
                    _field(
                      controller: _quantityController,
                      label: 'Quantity',
                      validator: positiveIntValidator,
                    )
                  else ...[
                    _trackingEditionSelectionField(),
                    _trackingVariantSelectionField(),
                  ],
                ]),
              ],
            ),
          ),
        if (editPresentation.showsOwnershipReferenceSection)
          EditSection(
            title: editPresentation.ownershipReferenceTitle,
            accent: widget.accent,
            child: Column(
              children: [
                _ownershipAnchorSelectionField(),
                if (_selectedOwnedAnchorType ==
                        PersonalItemAnchorType.edition.apiValue ||
                    _selectedOwnedAnchorType ==
                        PersonalItemAnchorType.variant.apiValue) ...[
                  const SizedBox(height: 10),
                  _responsiveFields([
                    _editionSelectionField(),
                    if (_selectedOwnedAnchorType ==
                        PersonalItemAnchorType.variant.apiValue)
                      _variantSelectionField(),
                  ]),
                ],
                if (_selectedOwnedAnchorType ==
                    PersonalItemAnchorType.bundleRelease.apiValue) ...[
                  const SizedBox(height: 10),
                  _bundleReleaseSelectionField(
                    fieldKey: const Key('library-edit-owned-bundle-field'),
                    label: editPresentation.ownedBundleLabel,
                    selectedBundleReleaseId: _selectedBundleReleaseId,
                    onChanged: (value) {
                      setState(() {
                        _selectedBundleReleaseId = _normalizedId(value);
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        if (editPresentation.showsOwnedGradingSection) ...[
          EditSection(
            title: editPresentation.ownedGradingSectionTitle,
            accent: widget.accent,
            child: Column(
              children: [
                if (!_isDigitalFormat) ...[
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
                ] else if (editPresentation.ownedGradingSectionHint != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      editPresentation.ownedGradingSectionHint!,
                      style: const TextStyle(color: kEditTextMuted),
                    ),
                  ),
                SwitchListTile(
                  value: _keyComic,
                  onChanged: (value) => setState(() => _keyComic = value),
                  title: Text(editPresentation.keyToggleLabel),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                if (_keyComic) ...[
                  const SizedBox(height: 6),
                  _field(
                    controller: _keyReasonController,
                    label: editPresentation.keyReasonLabel,
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
          title: _isOwned
              ? 'Storage & Tracking'
              : _hasWishlistContext
                  ? 'Personal'
                  : 'Tracking',
          accent: widget.accent,
          child: Column(
            children: [
              if (_isTrackingOnly && widget.item.editions.isNotEmpty) ...[
                _responsiveFields([
                  _trackingEditionSelectionField(),
                  _trackingVariantSelectionField(),
                ]),
                const SizedBox(height: 10),
              ],
              _responsiveFields([
                if (_showPhysicalOwnedFields) _locationField(),
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
              const SizedBox(height: 10),
              _responsiveFields(
                buildTrackingProgressFieldWidgets(
                  progressCurrentController: _progressCurrentController,
                  progressTotalController: _progressTotalController,
                  timesCompletedController: _timesCompletedController,
                  buildField: (controller, label) => _field(
                    controller: controller,
                    label: label,
                    validator: optionalIntValidator,
                  ),
                ),
              ),
              if (_showsEpisodeTrackingFields) ...[
                const SizedBox(height: 10),
                _responsiveFields(
                  buildTrackingEpisodeFieldWidgets(
                    seasonNumberController: _seasonNumberController,
                    episodeNumberController: _episodeNumberController,
                    buildField: (controller, label) => _field(
                      controller: controller,
                      label: label,
                      validator: optionalIntValidator,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: _trackingNotesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Tracking notes',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_isOwned && _isDigitalFormat) ...[
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Wishlist-only and digital copies do not expose storage location fields.',
                    style: TextStyle(color: kEditTextMuted),
                  ),
                ),
              ],
              if (_isOwned) ...[
                const SizedBox(height: 10),
                TagPickListField(
                  controller: _tagsController,
                  options: _tagOptions,
                  label: 'Tags',
                  hint: 'Comma-separated tags',
                ),
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
        if (_hasWishlistContext)
          EditSection(
            title: 'Wishlist reference',
            accent: widget.accent,
            child: Column(
              children: [
                _wishlistAnchorSelectionField(),
                if (_selectedWishlistAnchorType ==
                        PersonalItemAnchorType.edition.apiValue ||
                    _selectedWishlistAnchorType ==
                        PersonalItemAnchorType.variant.apiValue) ...[
                  const SizedBox(height: 10),
                  _responsiveFields([
                    _wishlistEditionSelectionField(),
                    if (_selectedWishlistAnchorType ==
                        PersonalItemAnchorType.variant.apiValue)
                      _wishlistVariantSelectionField(),
                  ]),
                ],
                if (_selectedWishlistAnchorType ==
                    PersonalItemAnchorType.bundleRelease.apiValue) ...[
                  const SizedBox(height: 10),
                  _bundleReleaseSelectionField(
                    fieldKey: const Key('library-edit-wishlist-bundle-field'),
                    label: 'Wishlist bundle',
                    selectedBundleReleaseId: _selectedWishlistBundleReleaseId,
                    onChanged: (value) {
                      setState(() {
                        _selectedWishlistBundleReleaseId = _normalizedId(value);
                      });
                    },
                  ),
                ],
                const SizedBox(height: 10),
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
        else if (!_hasWishlistContext)
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

  Future<void> _loadTagOptions() async {
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
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
              anchorType: _selectedOwnedAnchorType,
                editionId: _selectedOwnedAnchorType ==
                      PersonalItemAnchorType.edition.apiValue ||
                    _selectedOwnedAnchorType ==
                      PersonalItemAnchorType.variant.apiValue
                  ? _selectedEditionId
                  : null,
              variantId: _selectedOwnedAnchorType ==
                      PersonalItemAnchorType.variant.apiValue
                  ? _selectedVariantId
                  : null,
              bundleReleaseId: _selectedOwnedAnchorType ==
                      PersonalItemAnchorType.bundleRelease.apiValue
                  ? _selectedBundleReleaseId
                  : null,
                condition:
                  _showPhysicalOwnedFields ? emptyToNull(_conditionController.text) : null,
                grade: _showPhysicalOwnedFields ? emptyToNull(_gradeController.text) : null,
              purchaseDate: parseDate(_purchaseDateController.text),
              pricePaidCents: parseMoneyCents(_priceController.text),
              currency: emptyToNull(_currencyController.text),
              personalNotes: emptyToNull(_notesController.text),
              quantity: parseInt(_quantityController.text) ?? 1,
                locationId: _showPhysicalOwnedFields ? _selectedLocationId : null,
                locationChanged: _showPhysicalOwnedFields ? _locationChanged : false,
              tags: emptyToNull(_tagsController.text),
              soldAt: _soldAt,
              sellPriceCents: parseMoneyCents(_sellPriceController.text),
              soldTo: emptyToNull(_soldToController.text),
                rawOrSlabbed:
                  _isDigitalFormat ? null : emptyToNull(_rawOrSlabbedController.text),
                gradingCompany:
                  _isDigitalFormat ? null : emptyToNull(_gradingCompanyController.text),
                graderNotes:
                  _isDigitalFormat ? null : emptyToNull(_graderNotesController.text),
                signedBy:
                  _isDigitalFormat ? null : emptyToNull(_signedByController.text),
              keyComic: _keyComic,
              keyReason: emptyToNull(_keyReasonController.text),
                coverPriceCents:
                  _isDigitalFormat ? null : parseMoneyCents(_coverPriceController.text),
            ),
      wishlist: widget.wishlistItem == null
          ? null
          : LibraryWishlistEditSelection(
              anchorType: _selectedWishlistAnchorType,
                editionId: _selectedWishlistAnchorType ==
                      PersonalItemAnchorType.edition.apiValue ||
                    _selectedWishlistAnchorType ==
                      PersonalItemAnchorType.variant.apiValue
                  ? _selectedWishlistEditionId
                  : null,
              variantId: _selectedWishlistAnchorType ==
                      PersonalItemAnchorType.variant.apiValue
                  ? _selectedWishlistVariantId
                  : null,
              bundleReleaseId: _selectedWishlistAnchorType ==
                      PersonalItemAnchorType.bundleRelease.apiValue
                  ? _selectedWishlistBundleReleaseId
                  : null,
              targetPriceCents: parseMoneyCents(_wishlistPriceController.text),
              currency: emptyToNull(_wishlistCurrencyController.text),
              notes: emptyToNull(_wishlistNotesController.text),
            ),
      tracking: !_hasTrackingContext
          ? null
          : LibraryTrackingEditSelection(
              editionId: _selectedTrackingEditionId,
              variantId: _selectedTrackingVariantId,
              rating: parseInt(_ratingController.text),
              readStatus: emptyToNull(_trackingController.text),
              startedAt: _startedAt,
              finishedAt: _finishedAt,
              progressCurrent: parseInt(_progressCurrentController.text),
              progressTotal: parseInt(_progressTotalController.text),
              timesCompleted: parseInt(_timesCompletedController.text),
              notes: emptyToNull(_trackingNotesController.text),
              seasonNumber: parseInt(_seasonNumberController.text),
              episodeNumber: parseInt(_episodeNumberController.text),
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

  CatalogEdition? _selectedEditionById(String? selectedId) {
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

  Widget _ownershipAnchorSelectionField() {
    return _anchorSelectionField(
      fieldKey: const Key('library-edit-owned-anchor-field'),
      label: 'Ownership anchor',
      value: _selectedOwnedAnchorType,
      onChanged: _setOwnedAnchorType,
    );
  }

  Widget _wishlistAnchorSelectionField() {
    return _anchorSelectionField(
      fieldKey: const Key('library-edit-wishlist-anchor-field'),
      label: 'Wishlist anchor',
      value: _selectedWishlistAnchorType,
      onChanged: _setWishlistAnchorType,
    );
  }

  Widget _anchorSelectionField({
    required Key fieldKey,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return _LibraryEditAnchorSelector(
      fieldKey: fieldKey,
      label: label,
      value: value,
      editionAvailable: widget.item.editions.isNotEmpty,
      bundleAvailable: widget.availableBundleReleases.isNotEmpty,
      onChanged: onChanged,
    );
  }

  Widget _editionSelectionField() {
    return _editionSelectionFieldFor(
      label: 'Owned edition',
      selectedEditionId: _selectedEditionId,
      onChanged: (editionId) {
        final edition = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: editionId,
        ).edition;
        setState(() {
          _selectedEditionId = edition?.id;
          _selectedVariantId = null;
          _selectedTrackingEditionId = _selectedEditionId;
          _selectedTrackingVariantId = null;
        });
      },
    );
  }

  Widget _trackingEditionSelectionField() {
    return _editionSelectionFieldFor(
      label: 'Tracking edition',
      selectedEditionId: _selectedTrackingEditionId,
      onChanged: (editionId) {
        final edition = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: editionId,
        ).edition;
        setState(() {
          _selectedTrackingEditionId = edition?.id;
          _selectedTrackingVariantId = null;
        });
      },
    );
  }

  Widget _wishlistEditionSelectionField() {
    return _editionSelectionFieldFor(
      label: 'Wishlist edition',
      selectedEditionId: _selectedWishlistEditionId,
      onChanged: (editionId) {
        final edition = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: editionId,
        ).edition;
        setState(() {
          _selectedWishlistEditionId = edition?.id;
          _selectedWishlistVariantId = null;
        });
      },
    );
  }

  Widget _editionSelectionFieldFor({
    required String label,
    required String? selectedEditionId,
    required ValueChanged<String?> onChanged,
  }) {
    return _LibraryEditEditionSelector(
      label: label,
      selectedEditionId: selectedEditionId,
      editions: widget.item.editions,
      onChanged: (value) => onChanged(_normalizedId(value)),
    );
  }

  Widget _variantSelectionField() {
    return _variantSelectionFieldFor(
      label: 'Owned variant',
      selectedEditionId: _selectedEditionId,
      selectedVariantId: _selectedVariantId,
      onChanged: (value) {
        setState(() {
          _selectedVariantId = value;
          _selectedTrackingEditionId = _selectedEditionId;
          _selectedTrackingVariantId = value;
        });
      },
    );
  }

  Widget _trackingVariantSelectionField() {
    return _variantSelectionFieldFor(
      label: 'Tracking variant',
      selectedEditionId: _selectedTrackingEditionId,
      selectedVariantId: _selectedTrackingVariantId,
      onChanged: (value) {
        setState(() {
          _selectedTrackingVariantId = value;
        });
      },
    );
  }

  Widget _wishlistVariantSelectionField() {
    return _variantSelectionFieldFor(
      label: 'Wishlist variant',
      selectedEditionId: _selectedWishlistEditionId,
      selectedVariantId: _selectedWishlistVariantId,
      onChanged: (value) {
        setState(() {
          _selectedWishlistVariantId = value;
        });
      },
    );
  }

  Widget _variantSelectionFieldFor({
    required String label,
    required String? selectedEditionId,
    required String? selectedVariantId,
    required ValueChanged<String?> onChanged,
  }) {
    final edition = _selectedEditionById(selectedEditionId);
    final variants = edition?.variants ?? const <CatalogVariant>[];
    return _LibraryEditVariantSelector(
      label: label,
      selectedVariantId: selectedVariantId,
      variants: variants,
      onChanged: variants.isEmpty ? (_) {} : (value) => onChanged(_normalizedId(value)),
    );
  }

  Widget _bundleReleaseSelectionField({
    Key? fieldKey,
    required String label,
    required String? selectedBundleReleaseId,
    required ValueChanged<String?> onChanged,
  }) {
    return _LibraryEditBundleReleaseSelector(
      fieldKey: fieldKey,
      label: label,
      selectedBundleReleaseId: selectedBundleReleaseId,
      bundleReleases: widget.availableBundleReleases,
      onChanged: (value) => onChanged(_normalizedId(value)),
    );
  }

  void _setOwnedAnchorType(String value) {
    setState(() {
      _selectedOwnedAnchorType = value;
      if (value == PersonalItemAnchorType.variant.apiValue) {
        final editionSelection = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: _selectedEditionId,
          variantId: _selectedVariantId,
          editionTitle: widget.item.editionTitle,
          variantName: widget.item.variant,
        );
        _selectedEditionId = editionSelection.edition?.id;
        _selectedVariantId = editionSelection.variant?.id;
        _selectedBundleReleaseId = null;
        _selectedTrackingEditionId = _selectedEditionId;
        _selectedTrackingVariantId = _selectedVariantId;
      } else if (value == PersonalItemAnchorType.edition.apiValue) {
        final editionSelection = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: _selectedEditionId,
          variantId: _selectedVariantId,
          editionTitle: widget.item.editionTitle,
          variantName: widget.item.variant,
        );
        _selectedEditionId = editionSelection.edition?.id;
        _selectedVariantId = null;
        _selectedBundleReleaseId = null;
        _selectedTrackingEditionId = _selectedEditionId;
        _selectedTrackingVariantId = null;
      } else if (value == PersonalItemAnchorType.bundleRelease.apiValue) {
        _selectedBundleReleaseId ??=
            widget.availableBundleReleases.isEmpty ? null : widget.availableBundleReleases.first.id;
        _selectedEditionId = null;
        _selectedVariantId = null;
        _selectedTrackingEditionId = null;
        _selectedTrackingVariantId = null;
      } else {
        _selectedEditionId = null;
        _selectedVariantId = null;
        _selectedBundleReleaseId = null;
        _selectedTrackingEditionId = null;
        _selectedTrackingVariantId = null;
      }
    });
  }

  void _setWishlistAnchorType(String value) {
    setState(() {
      _selectedWishlistAnchorType = value;
      if (value == PersonalItemAnchorType.variant.apiValue) {
        final editionSelection = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: _selectedWishlistEditionId,
          variantId: _selectedWishlistVariantId,
          editionTitle: widget.item.editionTitle,
          variantName: widget.item.variant,
        );
        _selectedWishlistEditionId = editionSelection.edition?.id;
        _selectedWishlistVariantId = editionSelection.variant?.id;
        _selectedWishlistBundleReleaseId = null;
      } else if (value == PersonalItemAnchorType.edition.apiValue) {
        final editionSelection = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: _selectedWishlistEditionId,
          variantId: _selectedWishlistVariantId,
          editionTitle: widget.item.editionTitle,
          variantName: widget.item.variant,
        );
        _selectedWishlistEditionId = editionSelection.edition?.id;
        _selectedWishlistVariantId = null;
        _selectedWishlistBundleReleaseId = null;
      } else if (value == PersonalItemAnchorType.bundleRelease.apiValue) {
        _selectedWishlistBundleReleaseId ??=
            widget.availableBundleReleases.isEmpty ? null : widget.availableBundleReleases.first.id;
        _selectedWishlistEditionId = null;
        _selectedWishlistVariantId = null;
      } else {
        _selectedWishlistEditionId = null;
        _selectedWishlistVariantId = null;
        _selectedWishlistBundleReleaseId = null;
      }
    });
  }

  String? _normalizedId(String? value) {
    return emptyToNull(value ?? '');
  }
}

// ---------------------------------------------------------------------------
// Selection data classes
// ---------------------------------------------------------------------------

class LibraryEditSelection {
  const LibraryEditSelection({
    required this.item,
    required this.personal,
    this.wishlist,
    this.tracking,
    this.customFieldEdits = const {},
    this.itemImageEdits = const [],
  });

  final LibraryMetadataItem item;
  final LibraryPersonalEditSelection? personal;
  final LibraryWishlistEditSelection? wishlist;
  final LibraryTrackingEditSelection? tracking;
  final Map<String, String?> customFieldEdits;
  final List<ItemImageEdit> itemImageEdits;
}

class LibraryPersonalEditSelection {
  const LibraryPersonalEditSelection({
    required this.anchorType,
    required this.editionId,
    required this.variantId,
    required this.bundleReleaseId,
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

  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
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

class LibraryWishlistEditSelection {
  const LibraryWishlistEditSelection({
    required this.anchorType,
    required this.editionId,
    required this.variantId,
    required this.bundleReleaseId,
    required this.targetPriceCents,
    required this.currency,
    required this.notes,
  });

  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
}

class LibraryTrackingEditSelection {
  const LibraryTrackingEditSelection({
    required this.editionId,
    required this.variantId,
    required this.rating,
    required this.readStatus,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    this.notes,
    this.seasonNumber,
    this.episodeNumber,
    this.startedAt,
    this.finishedAt,
  });

  final String? editionId;
  final String? variantId;
  final int? rating;
  final String? readStatus;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;
  final int? seasonNumber;
  final int? episodeNumber;
  final DateTime? startedAt;
  final DateTime? finishedAt;
}
