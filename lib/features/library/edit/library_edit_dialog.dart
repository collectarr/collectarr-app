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
import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_value_tabs.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
export 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/kinds/shared/video_season_tracking_section.dart';
import 'package:collectarr_app/features/library/kinds/shared/video_episode_rating_section.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/tracking/tracking_editor_widgets.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
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
  Map<String, int> _episodeRatings = {};

  // Comics-specific grading fields
  late final TextEditingController _rawOrSlabbedController;
  late final TextEditingController _gradingCompanyController;
  late final TextEditingController _graderNotesController;
  late final TextEditingController _signedByController;
  late final TextEditingController _labelTypeController;
  late final TextEditingController _certificationNumberController;
  late final TextEditingController _coverPriceController;
  bool _keyComic = false;
  late final TextEditingController _keyReasonController;

  // Physical media fields
  late final TextEditingController _featuresController;
  late final TextEditingController _purchaseStoreController;
  late final TextEditingController _boxSetNameController;
  late final TextEditingController _storageDeviceController;
  late final TextEditingController _storageSlotController;
  List<String> _hdrFormats = [];

  // Edition / specs fields
  late final TextEditingController _regionController;
  late final TextEditingController _packagingController;
  late final TextEditingController _distributorController;
  late final TextEditingController _screenRatioController;

  // Collection status & bag/board
  String? _collectionStatus;
  DateTime? _lastBagBoardDate;
  late final TextEditingController _marketValueController;
  late final TextEditingController _audioTracksController;
  late final TextEditingController _subtitlesController;
  late final TextEditingController _layersController;
  late final TextEditingController _colorController;
  late final TextEditingController _nrDiscsController;

  String? _physicalFormatId;
  Map<String, String?> _customFieldEdits = {};
  List<ItemImageEdit> _itemImageEdits = [];

  bool get _isOwned => widget.ownedItem != null;

  bool get _hasTrackingContext => _isOwned || widget.trackingEntry != null;

  bool get _isTrackingOnly => !_isOwned && widget.trackingEntry != null;

  bool get _hasWishlistContext => widget.wishlistItem != null;

  bool get _hasReleaseAnchor {
    return _selectedOwnedAnchorType != PersonalItemAnchorType.item.apiValue;
  }

  /// Release-level fields (edition title, variant, barcode, physical format)
  /// are visible when editing a catalog-only item or when the ownership
  /// anchor targets a specific release rather than the abstract media work.
  bool get _showsReleaseSection {
    if (!_hasTrackingContext) return true; // catalog-only: always show
    return _hasReleaseAnchor;
  }

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
    _episodeRatings = Map<String, int>.from(tracking?.episodeRatings ?? const {});

    _rawOrSlabbedController =
        TextEditingController(text: owned?.rawOrSlabbed ?? '');
    _gradingCompanyController =
        TextEditingController(text: owned?.gradingCompany ?? '');
    _graderNotesController =
        TextEditingController(text: owned?.graderNotes ?? '');
    _signedByController = TextEditingController(text: owned?.signedBy ?? '');
    _labelTypeController = TextEditingController(text: owned?.labelType ?? '');
    _certificationNumberController =
        TextEditingController(text: owned?.certificationNumber ?? '');
    _coverPriceController = TextEditingController(
      text: owned?.coverPriceCents == null
          ? ''
          : (owned!.coverPriceCents! / 100).toStringAsFixed(2),
    );
    _keyComic = owned?.keyComic ?? false;
    _keyReasonController = TextEditingController(text: owned?.keyReason ?? '');
    _featuresController = TextEditingController(text: owned?.features ?? '');
    _hdrFormats = List<String>.from(owned?.hdrFormats ?? const <String>[]);
    _purchaseStoreController = TextEditingController(text: owned?.purchaseStore ?? '');
    _boxSetNameController = TextEditingController(text: owned?.boxSetName ?? '');
    _storageDeviceController = TextEditingController(text: owned?.storageDevice ?? '');
    _storageSlotController = TextEditingController(text: owned?.storageSlot ?? '');
    _regionController = TextEditingController(text: owned?.region ?? '');
    _packagingController = TextEditingController(text: owned?.packaging ?? '');
    _distributorController = TextEditingController(text: owned?.distributor ?? '');
    _collectionStatus = owned?.collectionStatus;
    _lastBagBoardDate = owned?.lastBagBoardDate;
    _marketValueController = TextEditingController(
      text: owned?.marketValueCents == null
          ? ''
          : (owned!.marketValueCents! / 100).toStringAsFixed(2),
    );
    final catalogVideo = widget.item.video;
    _screenRatioController = TextEditingController(text: catalogVideo?.screenRatio ?? '');
    _audioTracksController = TextEditingController(text: catalogVideo?.audioTracks ?? '');
    _subtitlesController = TextEditingController(text: catalogVideo?.subtitles ?? '');
    _layersController = TextEditingController(text: catalogVideo?.layers ?? '');
    _colorController = TextEditingController(text: catalogVideo?.color ?? '');
    _nrDiscsController = TextEditingController(text: catalogVideo?.nrDiscs?.toString() ?? '');
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
    _selectedBundleReleaseId = normalizeLibrarySelectionId(
      owned?.bundleReleaseId,
    );
    _selectedTrackingEditionId = tracking?.editionId ?? _selectedEditionId;
    _selectedTrackingVariantId = tracking?.variantId ?? _selectedVariantId;
    _selectedWishlistAnchorType =
        wishlist?.personalAnchor?.apiValue ?? PersonalItemAnchorType.item.apiValue;
    _selectedWishlistEditionId = wishlistEditionSelection.edition?.id;
    _selectedWishlistVariantId = wishlistEditionSelection.variant?.id;
    _selectedWishlistBundleReleaseId = normalizeLibrarySelectionId(
      wishlist?.bundleReleaseId,
    );

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
    _marketValueController.dispose();
    _soldToController.dispose();
    _rawOrSlabbedController.dispose();
    _gradingCompanyController.dispose();
    _graderNotesController.dispose();
    _signedByController.dispose();
    _labelTypeController.dispose();
    _certificationNumberController.dispose();
    _coverPriceController.dispose();
    _keyReasonController.dispose();
    _featuresController.dispose();
    _purchaseStoreController.dispose();
    _boxSetNameController.dispose();
    _storageDeviceController.dispose();
    _storageSlotController.dispose();
    _regionController.dispose();
    _packagingController.dispose();
    _distributorController.dispose();
    _screenRatioController.dispose();
    _audioTracksController.dispose();
    _subtitlesController.dispose();
    _layersController.dispose();
    _colorController.dispose();
    _nrDiscsController.dispose();
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
      onClose: () => Navigator.of(context).pop(),
      onSave: _submit,
      tabOrderKey: 'edit_tab_order_${widget.type.workspace.kind.apiValue}',
      ebaySearchQuery: widget.item.itemNumber != null
          ? '${widget.item.title} #${widget.item.itemNumber}'
          : widget.item.title,
    );
  }

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  Widget _tabViewFor(String id) {
    switch (id) {
      case 'main':
        return _mainTab();
      case 'media':
        return _mediaTab();
      case 'edition':
        return _editionTab();
      case 'specs':
        return _specsTab();
      case 'cast':
        return _castTab();
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
      case 'discs':
        return _discsTab();
      default:
        throw StateError('Unsupported generic edit tab: $id');
    }
  }

  // -------------------------------------------------------------------------
  // Tab: Media (catalog snapshot — work-level fields only)
  // -------------------------------------------------------------------------

  Widget _mediaTab() {
    final mediaFields = widget.type.mediaFields;
    final releaseFields = widget.type.releaseFields;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Media',
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
                _field(controller: _numberController, label: mediaFields.numberLabel),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                    controller: _publisherController, label: mediaFields.publisherLabel),
              ]),
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
              ]),
              if (mediaFields.showPageCount || mediaFields.showImprint || mediaFields.showSeriesGroup) ...[
                const SizedBox(height: 10),
                _responsiveFields([
                  if (mediaFields.showPageCount)
                    _field(
                      controller: _pageCountController,
                      label: 'Page count',
                      validator: optionalIntValidator,
                    ),
                  if (mediaFields.showImprint)
                    _field(controller: _imprintController, label: 'Imprint'),
                  if (mediaFields.showSeriesGroup)
                    _field(
                      controller: _seriesGroupController,
                      label: 'Series group',
                    ),
                ]),
              ],
            ],
          ),
        ),
        if (_showsReleaseSection)
          EditSection(
            title: 'Release details',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _responsiveFields([
                  _field(
                      controller: _editionTitleController,
                      label: releaseFields.editionTitleLabel),
                  _field(controller: _variantController, label: releaseFields.variantLabel),
                  _field(controller: _barcodeController, label: releaseFields.barcodeLabel),
                ]),
                if (releaseFields.showPhysicalFormat && widget.physicalFormats.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _physicalFormatId,
                    isExpanded: true,
                    dropdownColor: appPalette(context).panelRaised,
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
              ],
            ),
          ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Cast & Crew (placeholder — read-only credits display)
  // -------------------------------------------------------------------------

  Widget _castTab() {
    final creators = widget.item.creators;
    final hasCreators = creators != null && creators.isNotEmpty;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Cast & Crew',
          accent: widget.accent,
          child: hasCreators
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final credit in creators)
                      if (credit['name']?.toString().trim().isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 16, color: appPalette(context).textMuted),
                              const SizedBox(width: 8),
                              Text(
                                credit['name'].toString().trim(),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              if (credit['role']?.toString().trim().isNotEmpty == true) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '— ${credit['role']}',
                                  style: TextStyle(color: appPalette(context).textMuted),
                                ),
                              ],
                            ],
                          ),
                        ),
                  ],
                )
              : Text(
                  'No cast or crew data available.',
                  style: TextStyle(color: appPalette(context).textMuted),
                ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Discs (placeholder — future disc management)
  // -------------------------------------------------------------------------

  Widget _discsTab() {
    final editions = widget.item.editions;
    final allDiscs = <(String, CatalogDisc)>[];
    for (final edition in editions) {
      for (final disc in edition.discs) {
        allDiscs.add((edition.title, disc));
      }
    }
    return EditTabShell(
      children: [
        EditSection(
          title: 'Disc contents',
          accent: widget.accent,
          child: allDiscs.isEmpty
              ? Text(
                  'No disc data available yet. Disc management will be enabled in a future update.',
                  style: TextStyle(color: appPalette(context).textMuted),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (editionTitle, disc) in allDiscs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.album, size: 16, color: appPalette(context).textMuted),
                            const SizedBox(width: 8),
                            Text(
                              disc.discName ?? 'Disc ${disc.discNumber}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            if (disc.discFormat != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${disc.discFormat})',
                                style: TextStyle(color: appPalette(context).textMuted),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              editionTitle,
                              style: TextStyle(
                                color: appPalette(context).textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Main (catalog snapshot + condition/grade)
  // -------------------------------------------------------------------------

  bool get _hasMediaTab => _tabSpecs.any((t) => t.id == 'media');
  bool get _hasEditionTab => _tabSpecs.any((t) => t.id == 'edition');
  bool get _hasSpecsTab => _tabSpecs.any((t) => t.id == 'specs');

  Widget _mainTab() {
    final mediaFields = widget.type.mediaFields;
    final releaseFields = widget.type.releaseFields;
    final editPresentation = _editPresentation;
    return EditTabShell(
      children: [
        if (!_hasMediaTab) ...[
        // ---- Media-level fields (the abstract work) ----
        EditSection(
          title: 'Media',
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
                _field(controller: _numberController, label: mediaFields.numberLabel),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                    controller: _publisherController, label: mediaFields.publisherLabel),
              ]),
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
              ]),
              if (mediaFields.showPageCount || mediaFields.showImprint || mediaFields.showSeriesGroup) ...[
                const SizedBox(height: 10),
                _responsiveFields([
                  if (mediaFields.showPageCount)
                    _field(
                      controller: _pageCountController,
                      label: 'Page count',
                      validator: optionalIntValidator,
                    ),
                  if (mediaFields.showImprint)
                    _field(controller: _imprintController, label: 'Imprint'),
                  if (mediaFields.showSeriesGroup)
                    _field(
                      controller: _seriesGroupController,
                      label: 'Series group',
                    ),
                ]),
              ],
            ],
          ),
        ),
        // ---- Release-level fields (specific edition/variant) ----
        if (_showsReleaseSection)
          EditSection(
            title: 'Release details',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _responsiveFields([
                  _field(
                      controller: _editionTitleController,
                      label: releaseFields.editionTitleLabel),
                  _field(controller: _variantController, label: releaseFields.variantLabel),
                  _field(controller: _barcodeController, label: releaseFields.barcodeLabel),
                ]),
                if (releaseFields.showPhysicalFormat && widget.physicalFormats.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _physicalFormatId,
                    isExpanded: true,
                    dropdownColor: appPalette(context).panelRaised,
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
              ],
            ),
          ),
        ], // end if (!_hasMediaTab)
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
                      style: TextStyle(color: appPalette(context).textMuted),
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
        if (editPresentation.showsOwnershipReferenceSection && !_hasEditionTab)
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
                        _selectedBundleReleaseId =
                          normalizeLibrarySelectionId(value);
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
                  _responsiveFields([
                    _field(
                      controller: _labelTypeController,
                      label: 'Label type',
                    ),
                    _field(
                      controller: _certificationNumberController,
                      label: 'Certification number',
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
                      style: TextStyle(color: appPalette(context).textMuted),
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
  // Tab: Edition (release-level fields — video types)
  // -------------------------------------------------------------------------

  Widget _editionTab() {
    final releaseFields = widget.type.releaseFields;
    final editPresentation = _editPresentation;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Release details',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(
                    controller: _editionTitleController,
                    label: releaseFields.editionTitleLabel),
                _field(
                    controller: _variantController,
                    label: releaseFields.variantLabel),
                _field(
                    controller: _barcodeController,
                    label: releaseFields.barcodeLabel),
              ]),
              if (releaseFields.showPhysicalFormat &&
                  widget.physicalFormats.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _physicalFormatId ?? '',
                  isExpanded: true,
                  dropdownColor: appPalette(context).panelRaised,
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
                  controller: _regionController,
                  label: 'Region',
                  hint: 'e.g. A, B, C (Blu-ray) or 1-6 (DVD)',
                ),
                _field(
                  controller: _packagingController,
                  label: 'Packaging',
                  hint: 'e.g. Keep Case, Steelbook, Digibook',
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _distributorController,
                  label: 'Distributor',
                ),
                _field(
                  controller: _nrDiscsController,
                  label: 'Nr. of Discs',
                  validator: optionalIntValidator,
                ),
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
                    fieldKey:
                        const Key('library-edit-owned-bundle-field'),
                    label: editPresentation.ownedBundleLabel,
                    selectedBundleReleaseId: _selectedBundleReleaseId,
                    onChanged: (value) {
                      setState(() {
                        _selectedBundleReleaseId =
                          normalizeLibrarySelectionId(value);
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        EditSection(
          title: 'Box Set',
          accent: widget.accent,
          child: TextFormField(
            controller: _boxSetNameController,
            decoration: const InputDecoration(
              labelText: 'Box Set Name',
              hintText: 'Name of the box set this disc belongs to',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Specs (edition specifications — video types)
  // -------------------------------------------------------------------------

  Widget _specsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Video specifications',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(
                  controller: _screenRatioController,
                  label: 'Screen Ratio',
                  hint: 'e.g. 2.39:1, 1.85:1, 16:9',
                ),
                _field(
                  controller: _colorController,
                  label: 'Color',
                  hint: 'B&W, Color, or Both',
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _layersController,
                  label: 'Layers',
                  hint: 'e.g. Single, Dual',
                ),
              ]),
            ],
          ),
        ),
        EditSection(
          title: 'HDR',
          accent: widget.accent,
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final format in const [
                'HDR10',
                'HDR10+',
                'Dolby Vision',
                'HLG',
              ])
                FilterChip(
                  label: Text(format),
                  selected: _hdrFormats.contains(format),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _hdrFormats.add(format);
                      } else {
                        _hdrFormats.remove(format);
                      }
                    });
                  },
                ),
            ],
          ),
        ),
        EditSection(
          title: 'Audio & Subtitles',
          accent: widget.accent,
          child: Column(
            children: [
              TextFormField(
                controller: _audioTracksController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Audio Tracks',
                  hintText:
                      'One per line, e.g.\nEnglish DTS-HD MA 7.1\nFrench DD 5.1',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitlesController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Subtitles',
                  hintText:
                      'One per line, e.g.\nEnglish\nFrench\nSpanish',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Features',
          accent: widget.accent,
          child: TextFormField(
            controller: _featuresController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Features',
              hintText: 'Disc features, special editions, bonus content...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Value
  // -------------------------------------------------------------------------

  Widget _valueTab() {
    return LibraryEditValueTab(
      accent: widget.accent,
      buildResponsiveFields: _responsiveFields,
      buildField: _field,
      buildDatePickerField: _datePickerField,
      priceController: _priceController,
      currencyController: _currencyController,
      purchaseDateController: _purchaseDateController,
      purchaseStoreController: _purchaseStoreController,
      marketValueController: _marketValueController,
      sellPriceController: _sellPriceController,
      onPickPurchaseDate: _pickPurchaseDate,
      collectionStatus: _collectionStatus,
      onCollectionStatusChanged: (value) => setState(() => _collectionStatus = value),
      lastBagBoardDate: _lastBagBoardDate,
      onLastBagBoardDateChanged: (value) => setState(() => _lastBagBoardDate = value),
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Sold
  // -------------------------------------------------------------------------

  Widget _soldTab() {
    return buildLibraryEditSoldTab(
      context: context,
      accent: widget.accent,
      buildResponsiveFields: _responsiveFields,
      buildField: _field,
      soldAt: _soldAt,
      onSoldChanged: (value) {
        setState(() {
          _soldAt = value ? DateTime.now() : null;
        });
      },
      onPickSoldDate: _pickSoldDate,
      sellPriceController: _sellPriceController,
      soldToController: _soldToController,
      priceController: _priceController,
      currencyController: _currencyController,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Wishlist-only and digital copies do not expose storage location fields.',
                    style: TextStyle(color: appPalette(context).textMuted),
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
              if (_showPhysicalOwnedFields) ...[
                _responsiveFields([
                  TextFormField(
                    controller: _storageDeviceController,
                    decoration: const InputDecoration(
                      labelText: 'Storage Device',
                      hintText: 'e.g. DVD Shelf, Blu-ray Cabinet',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextFormField(
                    controller: _storageSlotController,
                    decoration: const InputDecoration(
                      labelText: 'Storage Slot',
                      hintText: 'e.g. Row 3, Slot 5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ]),
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
        if (_showsEpisodeTrackingFields)
          VideoSeasonTrackingSection(
            itemId: widget.item.id,
            accent: widget.accent,
          ),
        if (_showsEpisodeTrackingFields)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: VideoEpisodeRatingSection(
              itemId: widget.item.id,
              accent: widget.accent,
              trackingEntry: widget.trackingEntry?.copyWith(
                episodeRatings: _episodeRatings,
              ),
              onEpisodeRatingsChanged: (updated) {
                setState(() => _episodeRatings = updated);
              },
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
                        _selectedWishlistBundleReleaseId =
                          normalizeLibrarySelectionId(value);
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
            child: Text(
              'Storage, value, quantity and personal notes are only available once the item has an owned copy. Tracking progress stays editable here.',
              style: TextStyle(color: appPalette(context).textMuted),
            ),
          ),
        if (_showPhysicalOwnedFields && !_hasSpecsTab)
          EditSection(
            title: 'Physical media',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HDR formats',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final format in const [
                      'HDR10',
                      'HDR10+',
                      'Dolby Vision',
                      'HLG',
                    ])
                      FilterChip(
                        label: Text(format),
                        selected: _hdrFormats.contains(format),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _hdrFormats.add(format);
                            } else {
                              _hdrFormats.remove(format);
                            }
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _featuresController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Features',
                    hintText: 'Disc features, special editions, bonus content...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _boxSetNameController,
                  decoration: const InputDecoration(
                    labelText: 'Box Set Name',
                    hintText: 'Name of the box set this disc belongs to',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                color: label == null ? appPalette(context).textMuted : null,
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
    final updatedVideo = VideoCatalogDetails(
      runtimeMinutes: widget.item.video?.runtimeMinutes,
      color: emptyToNull(_colorController.text),
      nrDiscs: int.tryParse(_nrDiscsController.text),
      screenRatio: emptyToNull(_screenRatioController.text),
      audioTracks: emptyToNull(_audioTracksController.text),
      subtitles: emptyToNull(_subtitlesController.text),
      layers: emptyToNull(_layersController.text),
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
        video: updatedVideo.hasData ? updatedVideo : null,
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
              labelType:
                  _isDigitalFormat ? null : emptyToNull(_labelTypeController.text),
              certificationNumber:
                  _isDigitalFormat ? null : emptyToNull(_certificationNumberController.text),
              keyComic: _keyComic,
              keyReason: emptyToNull(_keyReasonController.text),
              coverPriceCents:
                  _isDigitalFormat ? null : parseMoneyCents(_coverPriceController.text),
              features: emptyToNull(_featuresController.text),
              hdrFormats: _hdrFormats.isEmpty ? null : _hdrFormats,
              purchaseStore: emptyToNull(_purchaseStoreController.text),
              boxSetName: emptyToNull(_boxSetNameController.text),
              storageDevice: emptyToNull(_storageDeviceController.text),
              storageSlot: emptyToNull(_storageSlotController.text),
              region: emptyToNull(_regionController.text),
              packaging: emptyToNull(_packagingController.text),
              distributor: emptyToNull(_distributorController.text),
              screenRatio: emptyToNull(_screenRatioController.text),
              audioTracks: emptyToNull(_audioTracksController.text),
              subtitles: emptyToNull(_subtitlesController.text),
              layers: emptyToNull(_layersController.text),
              color: emptyToNull(_colorController.text),
              nrDiscs: int.tryParse(_nrDiscsController.text),
              collectionStatus: _collectionStatus,
              lastBagBoardDate: _lastBagBoardDate,
              marketValueCents: parseMoneyCents(_marketValueController.text),
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
              episodeRatings: _episodeRatings.isEmpty ? null : _episodeRatings,
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
      onChanged: (value) => onChanged(normalizeLibrarySelectionId(value)),
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
      onChanged: variants.isEmpty
          ? (_) {}
          : (value) => onChanged(normalizeLibrarySelectionId(value)),
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
      onChanged: (value) => onChanged(normalizeLibrarySelectionId(value)),
    );
  }

  void _setOwnedAnchorType(String value) {
    final state = resolveOwnedAnchorSelectionState(
      anchorType: value,
      editions: widget.item.editions,
      selectedEditionId: _selectedEditionId,
      selectedVariantId: _selectedVariantId,
      editionTitle: widget.item.editionTitle,
      variantName: widget.item.variant,
      availableBundleReleaseIds: [
        for (final release in widget.availableBundleReleases) release.id,
      ],
    );
    setState(() {
      _selectedOwnedAnchorType = state.anchorType;
      _selectedEditionId = state.selectedEditionId;
      _selectedVariantId = state.selectedVariantId;
      _selectedBundleReleaseId = state.selectedBundleReleaseId;
      _selectedTrackingEditionId = state.selectedTrackingEditionId;
      _selectedTrackingVariantId = state.selectedTrackingVariantId;
    });
  }

  void _setWishlistAnchorType(String value) {
    final state = resolveWishlistAnchorSelectionState(
      anchorType: value,
      editions: widget.item.editions,
      selectedEditionId: _selectedWishlistEditionId,
      selectedVariantId: _selectedWishlistVariantId,
      editionTitle: widget.item.editionTitle,
      variantName: widget.item.variant,
      availableBundleReleaseIds: [
        for (final release in widget.availableBundleReleases) release.id,
      ],
    );
    setState(() {
      _selectedWishlistAnchorType = state.anchorType;
      _selectedWishlistEditionId = state.selectedEditionId;
      _selectedWishlistVariantId = state.selectedVariantId;
      _selectedWishlistBundleReleaseId = state.selectedBundleReleaseId;
    });
  }
}
