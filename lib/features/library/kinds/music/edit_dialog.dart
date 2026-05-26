import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildMusicLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return MusicLibraryEditDialog(request: request);
}

class MusicLibraryEditDialog extends ConsumerStatefulWidget {
  const MusicLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  ConsumerState<MusicLibraryEditDialog> createState() =>
      _MusicLibraryEditDialogState();
}

class _MusicLibraryEditDialogState extends ConsumerState<MusicLibraryEditDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TabController _tabController;

  late final TextEditingController _titleController;
  late final TextEditingController _sortKeyController;
  late final TextEditingController _artistController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _publisherController;
  late final TextEditingController _editionTitleController;
  late final TextEditingController _variantController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _catalogNumberController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _releaseYearController;
  late final TextEditingController _releaseStatusController;
  late final TextEditingController _countryController;
  late final TextEditingController _languageController;
  late final TextEditingController _genresController;
  late final TextEditingController _creditsController;
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _notesController;

  late final TextEditingController _conditionController;
  late final TextEditingController _gradeController;
  late final TextEditingController _purchaseDateController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _quantityController;
  late final TextEditingController _ratingController;
  late final TextEditingController _trackingController;
  late final TextEditingController _tagsController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _soldToController;
  late final TextEditingController _progressCurrentController;
  late final TextEditingController _progressTotalController;
  late final TextEditingController _timesCompletedController;
  late final TextEditingController _trackingNotesController;
  late final TextEditingController _wishlistPriceController;
  late final TextEditingController _wishlistCurrencyController;
  late final TextEditingController _wishlistNotesController;

  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  String? _selectedEditionId;
  String? _selectedVariantId;
  bool _locationChanged = false;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  DateTime? _soldAt;
  String? _physicalFormatId;
  Map<String, String?> _customFieldEdits = {};
  List<ItemImageEdit> _itemImageEdits = [];

  bool get _isOwned => widget.request.ownedItem != null;

  bool get _hasTrackingContext => _isOwned || widget.request.trackingEntry != null;

  bool get _isTrackingOnly => !_isOwned && widget.request.trackingEntry != null;

  bool get _hasWishlistContext => widget.request.wishlistItem != null;

  LibraryMetadataItem get _item => widget.request.item;
  OwnedItem? get _owned => widget.request.ownedItem;
  Color get _accent => widget.request.accent;

  LibraryEditPresentationContext get _editPresentationContext {
    return LibraryEditPresentationContext(
      isOwned: _isOwned,
      isTrackingOnly: _isTrackingOnly,
      hasTrackingContext: _hasTrackingContext,
      hasWishlistContext: _hasWishlistContext,
      isDigitalFormat: false,
      hasPhysicalFormats: widget.request.physicalFormats.isNotEmpty,
      hasEditionAnchors: widget.request.item.editions.isNotEmpty,
      hasBundleReleaseAnchors: false,
      hasCustomFields: widget.request.customFieldDefinitions.isNotEmpty,
    );
  }

  List<LibraryEditTabSpec> get _tabSpecs {
    return widget.request.type.editPresentation.builder.buildTabs(
      context: _editPresentationContext,
    );
  }

  String get _musicTitleLabel {
    final title = _titleController.text.trim();
    return title.isEmpty ? _item.title : title;
  }

  @override
  void initState() {
    super.initState();
    final item = _item;
    final owned = _owned;
    final tracking = widget.request.trackingEntry;
    _tabController = TabController(length: _tabSpecs.length, vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _titleController = TextEditingController(text: item.title);
    _sortKeyController = TextEditingController(text: item.sortKey ?? '');
    _artistController = TextEditingController(text: item.series?.seriesTitle ?? '');
    _subtitleController =
        TextEditingController(text: item.publishing?.subtitle ?? '');
    _publisherController = TextEditingController(text: item.publisher ?? '');
    _editionTitleController =
        TextEditingController(text: item.editionTitle ?? '');
    _variantController = TextEditingController(text: item.variant ?? '');
    _barcodeController = TextEditingController(text: item.barcode ?? '');
    _catalogNumberController =
        TextEditingController(text: item.music?.catalogNumber ?? '');
    _releaseDateController = TextEditingController(
      text: item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    );
    _releaseYearController =
        TextEditingController(text: item.releaseYear?.toString() ?? '');
    _releaseStatusController =
        TextEditingController(text: item.music?.releaseStatus ?? '');
    _countryController = TextEditingController(text: item.country ?? '');
    _languageController = TextEditingController(text: item.language ?? '');
    _genresController = TextEditingController(
      text: (item.genres ?? const <String>[]).join(', '),
    );
    _creditsController = TextEditingController(text: _creatorLines(item.creators));
    _coverController = TextEditingController(text: item.coverImageUrl ?? '');
    _thumbnailController =
        TextEditingController(text: item.thumbnailImageUrl ?? '');
    _synopsisController = TextEditingController(text: item.synopsis ?? '');
    _notesController = TextEditingController(text: owned?.personalNotes ?? '');

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
    _ratingController =
      TextEditingController(text: (tracking?.rating ?? owned?.rating)?.toString() ?? '');
    _trackingController =
      TextEditingController(
        text: tracking?.statusStorageValue ?? owned?.readStatus ?? '',
      );
    _tagsController = TextEditingController(text: owned?.tags ?? '');
    _sellPriceController = TextEditingController(
      text: owned?.sellPriceCents == null
          ? ''
          : (owned!.sellPriceCents! / 100).toStringAsFixed(2),
    );
    _soldToController = TextEditingController(text: owned?.soldTo ?? '');

    _progressCurrentController = TextEditingController(
      text: tracking?.progressCurrent?.toString() ?? '',
    );
    _progressTotalController = TextEditingController(
      text: tracking?.progressTotal?.toString() ?? '',
    );
    _timesCompletedController = TextEditingController(
      text: tracking?.timesCompleted?.toString() ?? '',
    );
    _trackingNotesController = TextEditingController(
      text: tracking?.notes ?? '',
    );
    final wishlist = widget.request.wishlistItem;
    _wishlistPriceController = TextEditingController(
      text: wishlist?.targetPriceCents == null
          ? ''
          : (wishlist!.targetPriceCents! / 100).toStringAsFixed(2),
    );
    _wishlistCurrencyController =
        TextEditingController(text: wishlist?.currency ?? '');
    _wishlistNotesController =
        TextEditingController(text: wishlist?.notes ?? '');

    _selectedLocationId = owned?.locationId;
    _startedAt = tracking?.startedAt ?? owned?.startedAt;
    _finishedAt = tracking?.finishedAt ?? owned?.finishedAt;
    _soldAt = owned?.soldAt;
    _physicalFormatId = _initialPhysicalFormatId(item);
    final editionSelection = resolveLibraryEditionSelection(
      item.editions,
      editionId: owned?.editionId ?? tracking?.editionId,
      editionTitle: item.editionTitle,
      variantId: owned?.variantId ?? tracking?.variantId,
      variantName: item.variant,
    );
    _selectedEditionId = editionSelection.edition?.id;
    _selectedVariantId = editionSelection.variant?.id;
    _customFieldEdits = {
      for (final value in widget.request.customFieldValues)
        value.fieldDefinitionId: value.value,
    };

    unawaited(_loadAvailableLocations());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _sortKeyController.dispose();
    _artistController.dispose();
    _subtitleController.dispose();
    _publisherController.dispose();
    _editionTitleController.dispose();
    _variantController.dispose();
    _barcodeController.dispose();
    _catalogNumberController.dispose();
    _releaseDateController.dispose();
    _releaseYearController.dispose();
    _releaseStatusController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _genresController.dispose();
    _creditsController.dispose();
    _coverController.dispose();
    _thumbnailController.dispose();
    _synopsisController.dispose();
    _notesController.dispose();
    _conditionController.dispose();
    _gradeController.dispose();
    _purchaseDateController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _quantityController.dispose();
    _ratingController.dispose();
    _trackingController.dispose();
    _tagsController.dispose();
    _sellPriceController.dispose();
    _soldToController.dispose();
    _progressCurrentController.dispose();
    _progressTotalController.dispose();
    _timesCompletedController.dispose();
    _trackingNotesController.dispose();
    _wishlistPriceController.dispose();
    _wishlistCurrencyController.dispose();
    _wishlistNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LibraryEditDialogScaffold(
        formKey: _formKey,
        accent: _accent,
        icon: widget.request.type.workspace.icon,
        title:
            'Edit ${widget.request.type.singularLabel.toLowerCase()} — ${_item.title}',
        badges: [
          if (_isOwned) const EditMiniBadge('Owned'),
          if (_isTrackingOnly) const EditMiniBadge('Tracked'),
          if (_soldAt != null) const EditMiniBadge('Sold'),
          if (_conditionController.text.trim().isNotEmpty)
            EditMiniBadge(_conditionController.text.trim()),
          if (_selectedLocationLabel != null) EditMiniBadge(_selectedLocationLabel!),
        ],
        tabController: _tabController,
        tabs: [for (final tab in _tabSpecs) EditTab(icon: tab.icon, label: tab.label)],
        views: _tabViews(),
        onClose: () => Navigator.of(context).pop(),
        onSave: _submit,
    );
  }

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  List<String> _tabSectionIds(String tabId) {
    return widget.request.type.editPresentation.builder.buildTabSectionIds(
      context: _editPresentationContext,
      tabId: tabId,
    );
  }

  Widget _tabViewFor(String id) {
    switch (id) {
      case 'main':
        return _mainTab();
      case 'classical':
        return _classicalTab();
      case 'tracks':
        return _tracksTab();
      case 'details_personal':
        return _detailsPersonalTab();
      case 'people':
        return _peopleTab();
      case 'covers':
        return _coversTab();
      case 'notes':
        return _notesTab();
      case 'links':
        return _linksTab();
      default:
        throw StateError('Unsupported music edit tab: $id');
    }
  }

  Widget _mainTab() {
    final music = _item.music;
    final tracks = music?.tracks ?? const <CatalogTrack>[];
    final trackCount = music?.trackCount ?? tracks.length;
    final sections = _tabSectionIds('main');
    return EditTabShell(
      cover: _coverPreview(),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            EditSummaryPill(
              label: 'Artist',
              value: _artistController.text,
              icon: Icons.mic_none_outlined,
              width: 180,
            ),
            EditSummaryPill(
              label: 'Format',
              value: _physicalFormatForId(_physicalFormatId)?.label ?? '—',
              icon: Icons.album_outlined,
              width: 120,
            ),
            EditSummaryPill(
              label: 'Tracks',
              value: '$trackCount',
              icon: Icons.queue_music_outlined,
              width: 96,
            ),
            EditSummaryPill(
              label: 'Released',
              value: _releaseYearController.text.trim().isEmpty
                  ? '—'
                  : _releaseYearController.text.trim(),
              icon: Icons.event_outlined,
              width: 100,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _classicalTab() {
    final sections = _tabSectionIds('classical');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _tracksTab() {
    final sections = _tabSectionIds('tracks');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _detailsPersonalTab() {
    final sections = _tabSectionIds('details_personal');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _peopleTab() {
    final sections = _tabSectionIds('people');
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

  Widget _notesTab() {
    final sections = _tabSectionIds('notes');
    return EditTabShell(
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

  Widget _sectionFor(String id) {
    final tracks = _item.music?.tracks ?? const <CatalogTrack>[];
    final totalDuration = _trackDurationLabel(tracks);
    switch (id) {
      case 'music_release_identity':
        return EditSection(
          title: 'Release identity',
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
                _field(controller: _artistController, label: 'Artist'),
              ]),
              const SizedBox(height: 10),
              _denseFields([
                _field(controller: _subtitleController, label: 'Subtitle'),
                _field(controller: _publisherController, label: widget.request.type.mediaFields.publisherLabel),
                _field(
                  controller: _editionTitleController,
                  label: widget.request.type.releaseFields.editionTitleLabel,
                ),
                _field(controller: _variantController, label: widget.request.type.releaseFields.variantLabel),
              ]),
            ],
          ),
        );
      case 'music_identifiers_release':
        return EditSection(
          title: 'Identifiers & release',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(controller: _barcodeController, label: widget.request.type.releaseFields.barcodeLabel),
                _field(controller: _catalogNumberController, label: 'Catalog number'),
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
              if (widget.request.type.releaseFields.showPhysicalFormat &&
                  widget.request.physicalFormats.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _physicalFormatId,
                  isExpanded: true,
                  dropdownColor: kEditPanelRaised,
                  borderRadius: kEditMenuBorderRadius,
                  decoration: const InputDecoration(labelText: 'Format'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('No specific format'),
                    ),
                    for (final format in widget.request.physicalFormats)
                      DropdownMenuItem<String>(
                        value: format.id,
                        child: Text(format.label),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _physicalFormatId = emptyToNull(value ?? '');
                    });
                  },
                ),
              ],
              const SizedBox(height: 10),
              _denseFields([
                _field(
                  controller: _releaseStatusController,
                  label: 'Release status',
                ),
                _field(controller: _countryController, label: 'Country'),
                _field(controller: _languageController, label: 'Language'),
              ]),
            ],
          ),
        );
      case 'music_genres':
        return EditSection(
          title: 'Genres',
          accent: _accent,
          child: TextFormField(
            controller: _genresController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Genres',
              hintText: 'Comma separated',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 'music_classical_metadata':
        return EditSection(
          title: 'Classical metadata',
          accent: _accent,
          child: const Text(
            'This tab is reserved for composer, conductor, orchestra and chorus metadata. The current music model does not persist dedicated classical structures yet, but the edit flow now mirrors the CLZ tab layout so the specialized fields can be wired in without reshaping the dialog again.',
            style: TextStyle(color: kEditTextMuted),
          ),
        );
      case 'music_composer':
        return _readonlyListSection('Composer', _creatorsForRole(['composer']));
      case 'music_conductor':
        return _readonlyListSection('Conductor', _creatorsForRole(['conductor']));
      case 'music_orchestra':
        return _readonlyListSection('Orchestra', _creatorsForRole(['orchestra', 'ensemble']));
      case 'music_chorus':
        return _readonlyListSection('Chorus', _creatorsForRole(['chorus', 'choir']));
      case 'music_track_listing':
        return EditSection(
          title: 'Track listing',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ValueContextChip(
                    icon: Icons.queue_music_outlined,
                    label: 'Tracks',
                    value: '${tracks.length}',
                  ),
                  ValueContextChip(
                    icon: Icons.schedule_outlined,
                    label: 'Length',
                    value: totalDuration ?? '—',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (tracks.isEmpty)
                const Text(
                  'No track list is available for this release yet.',
                  style: TextStyle(color: kEditTextMuted),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: kAppField,
                    border: Border.all(color: kEditDivider),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              child: Text('#', style: TextStyle(color: kEditTextMuted)),
                            ),
                            Expanded(
                              child: Text('Title', style: TextStyle(color: kEditTextMuted)),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text('Length', style: TextStyle(color: kEditTextMuted)),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: kEditDivider),
                      for (var index = 0; index < tracks.length; index++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Text(
                                  _trackPositionLabel(index, tracks[index]),
                                  style: const TextStyle(color: kEditTextMuted),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tracks[index].title),
                                    if ((tracks[index].artist ?? '').trim().isNotEmpty)
                                      Text(
                                        tracks[index].artist!.trim(),
                                        style: const TextStyle(
                                          color: kEditTextMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  _secondsLabel(tracks[index].durationSeconds) ?? '—',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(color: kEditTextMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index != tracks.length - 1)
                          const Divider(height: 1, color: kEditDivider),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      case 'music_collection_or_tracking':
        if (_isOwned) {
          return EditSection(
            title: 'Collection',
            accent: _accent,
            child: Column(
              children: [
                if (widget.request.item.editions.isNotEmpty) ...[
                  _denseFields([
                    _editionSelectionField(),
                    _variantSelectionField(),
                  ]),
                  const SizedBox(height: 10),
                ],
                _denseFields([
                  _locationField(),
                  SizedBox(
                    width: 140,
                    child: MediaRatingField(controller: _ratingController),
                  ),
                  SizedBox(
                    width: 180,
                    child: MediaTrackingStatusField(
                      profile: widget.request.type.trackingProfile,
                      value: _trackingController.text,
                      label: 'Tracking status',
                      onChanged: (value) {
                        _trackingController.text = value ?? '';
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                _denseFields([
                  _field(controller: _conditionController, label: 'Condition'),
                  _field(controller: _gradeController, label: 'Media condition'),
                  _field(
                    controller: _quantityController,
                    label: 'Quantity',
                    validator: positiveIntValidator,
                  ),
                ]),
                const SizedBox(height: 10),
                _denseFields([
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
                const SizedBox(height: 10),
                _denseFields([
                  _field(
                    controller: _timesCompletedController,
                    label: 'Times listened',
                    validator: optionalPositiveIntValidator,
                  ),
                  _field(
                    controller: _progressCurrentController,
                    label: 'Tracks heard',
                    validator: optionalPositiveIntValidator,
                  ),
                  _field(
                    controller: _progressTotalController,
                    label: 'Total tracks',
                    validator: optionalPositiveIntValidator,
                  ),
                ]),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _trackingNotesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Tracking notes',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          );
        }
        if (_hasTrackingContext) {
          return EditSection(
            title: 'Tracking',
            accent: _accent,
            child: Column(
              children: [
                if (widget.request.item.editions.isNotEmpty) ...[
                  _denseFields([
                    _editionSelectionField(),
                    _variantSelectionField(),
                  ]),
                  const SizedBox(height: 10),
                ],
                _denseFields([
                  SizedBox(
                    width: 140,
                    child: MediaRatingField(controller: _ratingController),
                  ),
                  SizedBox(
                    width: 180,
                    child: MediaTrackingStatusField(
                      profile: widget.request.type.trackingProfile,
                      value: _trackingController.text,
                      label: 'Tracking status',
                      onChanged: (value) {
                        _trackingController.text = value ?? '';
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                _denseFields([
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
                const SizedBox(height: 10),
                _denseFields([
                  _field(
                    controller: _timesCompletedController,
                    label: 'Times listened',
                    validator: optionalPositiveIntValidator,
                  ),
                  _field(
                    controller: _progressCurrentController,
                    label: 'Tracks heard',
                    validator: optionalPositiveIntValidator,
                  ),
                  _field(
                    controller: _progressTotalController,
                    label: 'Total tracks',
                    validator: optionalPositiveIntValidator,
                  ),
                ]),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _trackingNotesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Tracking notes',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          );
        }
        return EditSection(
          title: 'Personal fields',
          accent: _accent,
          child: const Text(
            'Open the edit dialog from an owned copy to populate collection-specific music fields like condition, rating, location and listening status.',
            style: TextStyle(color: kEditTextMuted),
          ),
        );
      case 'music_wishlist_reference':
        return EditSection(
          title: 'Wishlist',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
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
      case 'music_purchase_value':
        return EditSection(
          title: 'Purchase & value',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(
                  controller: _priceController,
                  label: 'Price paid',
                  validator: optionalMoneyValidator,
                ),
                _field(controller: _currencyController, label: 'Currency'),
                _field(
                  controller: _sellPriceController,
                  label: 'Current / sell value',
                  validator: optionalMoneyValidator,
                ),
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
        );
      case 'music_profit_loss':
        if (!_isOwned || _sellPriceController.text.trim().isEmpty) {
          return const SizedBox.shrink();
        }
        return EditSection(
          title: 'Profit / Loss',
          accent: _accent,
          child: SoldSummaryPanel(
            pricePaidCents: parseMoneyCents(_priceController.text),
            sellPriceCents: parseMoneyCents(_sellPriceController.text),
            currency: _currencyController.text,
          ),
        );
      case 'music_custom_fields':
        return EditSection(
          title: 'Custom fields',
          accent: _accent,
          child: CustomFieldsEditSection(
            definitions: widget.request.customFieldDefinitions,
            values: _customFieldEdits,
            accent: _accent,
            onChanged: (values) => _customFieldEdits = values,
          ),
        );
      case 'music_primary_artist':
        return EditSection(
          title: 'Primary artist',
          accent: _accent,
          child: _field(
            controller: _artistController,
            label: 'Artist / display name',
          ),
        );
      case 'music_credits':
        return EditSection(
          title: 'Credits',
          accent: _accent,
          child: TextFormField(
            controller: _creditsController,
            minLines: 8,
            maxLines: 14,
            decoration: const InputDecoration(
              labelText: 'Credits',
              hintText: 'One per line, optionally Role: Name',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 'music_remote_cover_assets':
        return EditSection(
          title: 'Remote cover assets',
          accent: _accent,
          child: Column(
            children: [
              _field(controller: _coverController, label: 'Cover image URL'),
              const SizedBox(height: 10),
              _field(controller: _thumbnailController, label: 'Thumbnail image URL'),
            ],
          ),
        );
      case 'music_local_images':
        return EditSection(
          title: 'Local images',
          accent: _accent,
          child: ItemImagesEditSection(
            images: widget.request.itemImages,
            accent: _accent,
            onChanged: (edits) => _itemImageEdits = edits,
          ),
        );
      case 'music_album_notes':
        return EditSection(
          title: 'Album notes',
          accent: _accent,
          child: TextFormField(
            controller: _synopsisController,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Synopsis / album notes',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 'music_personal_notes':
        return EditSection(
          title: 'Personal notes',
          accent: _accent,
          child: TextFormField(
            controller: _notesController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Collection notes',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 'music_identifiers':
        return EditSection(
          title: 'Identifiers',
          accent: _accent,
          child: _denseFields([
            _field(controller: _barcodeController, label: widget.request.type.releaseFields.barcodeLabel),
            _field(controller: _catalogNumberController, label: 'Catalog number'),
            _field(controller: _coverController, label: 'Front cover URL'),
            _field(controller: _thumbnailController, label: 'Thumbnail URL'),
          ]),
        );
      case 'music_metadata_source_notes':
        return EditSection(
          title: 'Metadata source notes',
          accent: _accent,
          child: const Text(
            'Provider-specific online links are not modeled separately in the current client yet. This tab keeps the CLZ-style surface for identifiers and remote asset references so the music edit flow stays consistent.',
            style: TextStyle(color: kEditTextMuted),
          ),
        );
      default:
        throw StateError('Unsupported music section: $id');
    }
  }

  Widget _denseFields(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        if (columns == 1) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                children[index],
              ],
            ],
          );
        }
        final rows = <Widget>[];
        for (var index = 0; index < children.length; index += columns) {
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var offset = 0; offset < columns; offset++) ...[
                  if (offset > 0) const SizedBox(width: 10),
                  Expanded(
                    child: index + offset < children.length
                        ? children[index + offset]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
          if (index + columns < children.length) {
            rows.add(const SizedBox(height: 10));
          }
        }
        return Column(children: rows);
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

  Widget _readonlyListSection(String title, List<String> values) {
    return EditSection(
      title: title,
      accent: _accent,
      child: values.isEmpty
          ? const Text('No entries', style: TextStyle(color: kEditTextMuted))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in values)
                  EditMiniBadge(value, color: kAppSurfaceBright),
              ],
            ),
    );
  }

  Widget _coverPreview() {
    return LibraryInteractiveCover(
      title: _musicTitleLabel,
      itemNumber: null,
      imageUrl: emptyToNull(_thumbnailController.text) ??
          emptyToNull(_coverController.text) ??
          _item.displayCoverUrl,
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
    final locationLabel =
        locationPathForId(_availableLocations, _selectedLocationId);
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

  List<String> _creatorsForRole(List<String> keywords) {
    final values = <String>[];
    for (final creator in _item.creators ?? const <Map<String, dynamic>>[]) {
      final role = creator['role']?.toString().toLowerCase() ?? '';
      if (!keywords.any(role.contains)) {
        continue;
      }
      final name = creator['name']?.toString().trim();
      if (name == null || name.isEmpty || values.contains(name)) {
        continue;
      }
      values.add(name);
    }
    return values;
  }

  String _creatorLines(List<Map<String, dynamic>>? creators) {
    if (creators == null || creators.isEmpty) {
      return '';
    }
    return creators
        .map((entry) {
          final name = entry['name']?.toString().trim() ?? '';
          final role = entry['role']?.toString().trim() ?? '';
          if (name.isEmpty) {
            return '';
          }
          return role.isEmpty ? name : '$role: $name';
        })
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  List<Map<String, dynamic>>? _creatorList(String value) {
    final lines = value
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) {
      return null;
    }
    return [
      for (final line in lines)
        if (line.contains(':'))
          {
            'role': line.split(':').first.trim(),
            'name': line.split(':').skip(1).join(':').trim(),
          }
        else
          {'name': line},
    ].where((entry) => (entry['name'] as String).isNotEmpty).toList(growable: false);
  }

  List<String>? _splitCommaList(String value) {
    final normalized = value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    return normalized.isEmpty ? null : normalized;
  }

  String _trackPositionLabel(int index, CatalogTrack track) {
    final disc = track.discNumber;
    final position = track.position ?? index + 1;
    if (disc == null || disc <= 1) {
      return '$position';
    }
    return '$disc.$position';
  }

  String? _secondsLabel(int? value) {
    if (value == null || value <= 0) {
      return null;
    }
    final minutes = value ~/ 60;
    final seconds = value % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String? _trackDurationLabel(List<CatalogTrack> tracks) {
    var total = 0;
    for (final track in tracks) {
      if (track.durationSeconds != null && track.durationSeconds! > 0) {
        total += track.durationSeconds!;
      }
    }
    if (total <= 0) {
      return null;
    }
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final currentTracks = _item.music?.tracks ?? const <CatalogTrack>[];
    final updatedSeries = CatalogSeriesDetails(
      seriesId: _item.series?.seriesId,
      seriesTitle: emptyToNull(_artistController.text),
      volumeName: _item.series?.volumeName,
      volumeNumber: _item.series?.volumeNumber,
      volumeStartYear: _item.series?.volumeStartYear,
      seasonNumber: _item.series?.seasonNumber,
      episodeNumber: _item.series?.episodeNumber,
      tags: _item.series?.tags ?? const <String>[],
    );
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: _item.publishing?.pageCount,
      coverPriceCents: _item.publishing?.coverPriceCents,
      currency: _item.publishing?.currency,
      imprint: _item.publishing?.imprint,
      subtitle: emptyToNull(_subtitleController.text),
      seriesGroup: _item.publishing?.seriesGroup,
    );
    final updatedMusic = MusicCatalogDetails(
      trackCount: _item.music?.trackCount ??
          (currentTracks.isEmpty ? null : currentTracks.length),
      tracks: currentTracks,
      catalogNumber: emptyToNull(_catalogNumberController.text),
      releaseStatus: emptyToNull(_releaseStatusController.text),
    );

    Navigator.of(context).pop(
      LibraryEditSelection(
        item: _item.copyWith(
          title: _titleController.text.trim(),
          sortKey: emptyToNull(_sortKeyController.text),
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
          series: updatedSeries.hasData ? updatedSeries : null,
          music: updatedMusic.hasData ? updatedMusic : null,
          publishing: updatedPublishing.hasData ? updatedPublishing : null,
          creators: _creatorList(_creditsController.text),
          genres: _splitCommaList(_genresController.text),
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
                progressCurrent: parseInt(_progressCurrentController.text),
                progressTotal: parseInt(_progressTotalController.text),
                timesCompleted: parseInt(_timesCompletedController.text),
                notes: emptyToNull(_trackingNotesController.text),
                seasonNumber: widget.request.trackingEntry?.seasonNumber ?? _item.series?.seasonNumber,
                episodeNumber: widget.request.trackingEntry?.episodeNumber ?? _item.series?.episodeNumber,
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

  String? _initialPhysicalFormatId(LibraryMetadataItem item) {
    final configured = _physicalFormatForId(item.physicalFormat);
    if (configured != null) {
      return configured.id;
    }
    final byLabel = physicalMediaFormatByLabelOrId(
      item.physicalFormatLabel ?? item.variant,
      formats: widget.request.physicalFormats,
    );
    return byLabel?.id;
  }

  PhysicalMediaFormat? _physicalFormatForId(String? id) {
    final normalized = emptyToNull(id ?? '');
    return normalized == null
        ? null
        : physicalMediaFormatById(
            normalized,
            formats: widget.request.physicalFormats,
          );
  }
}