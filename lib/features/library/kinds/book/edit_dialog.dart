import 'dart:typed_data';

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
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
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
  late final TextEditingController _subjectsController;
  late final TextEditingController _paperTypeController;
  late final TextEditingController _printedByController;
  late final TextEditingController _dustJacketConditionController;
  late final TextEditingController _publicationPlaceController;
  late final TextEditingController _originalCountryController;
  late final TextEditingController _originalLanguageController;
  late final TextEditingController _originalPublisherController;
  late final TextEditingController _originalPublicationPlaceController;
  late final TextEditingController _ownerLabelController;
  late final TextEditingController _signedByController;
  late final TextEditingController _purchaseStoreController;
  late final TextEditingController _marketValueController;
  late final TextEditingController _progressCurrentController;
  late final TextEditingController _progressTotalController;
  late final TextEditingController _timesCompletedController;

  late final TextEditingController _authorController;
  late final TextEditingController _editorController;
  late final TextEditingController _illustratorController;
  late final TextEditingController _coverArtistController;
  late final TextEditingController _photographerController;
  late final TextEditingController _forewordAuthorController;
  late final TextEditingController _translatorController;
  late final TextEditingController _ghostWriterController;
  late final TextEditingController _narratorController;

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
  DateTime? _originalPublicationDate;
  Map<String, String?> _customFieldEdits = {};
  List<ItemImageEdit> _itemImageEdits = [];
  String? _collectionStatus;
  late final TextEditingController _collectionStatusController;
  DateTime? _lastBagBoardDate;
  bool _firstEdition = false;
  bool _audiobookAbridged = false;
  bool _dustJacket = false;
  final List<_BookExternalLinkEdit> _externalLinkEdits =
      <_BookExternalLinkEdit>[];

  bool get _isOwned => widget.request.ownedItem != null;

  bool get _hasTrackingContext =>
      _isOwned || widget.request.trackingEntry != null;

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
    _volumeNumberController = TextEditingController(
        text: item.series?.volumeNumber?.toString() ?? '');
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
    _subjectsController = TextEditingController(
      text: (item.publishing?.subjects ?? const <String>[]).join(', '),
    );
    _paperTypeController =
        TextEditingController(text: item.publishing?.paperType ?? '');
    _printedByController =
        TextEditingController(text: item.publishing?.printedBy ?? '');
    _dustJacketConditionController = TextEditingController(
      text: item.publishing?.dustJacketCondition ?? '',
    );
    _publicationPlaceController =
        TextEditingController(text: item.publishing?.publicationPlace ?? '');
    _originalCountryController =
        TextEditingController(text: item.publishing?.originalCountry ?? '');
    _originalLanguageController =
        TextEditingController(text: item.publishing?.originalLanguage ?? '');
    _originalPublisherController =
        TextEditingController(text: item.publishing?.originalPublisher ?? '');
    _originalPublicationPlaceController = TextEditingController(
      text: item.publishing?.originalPublicationPlace ?? '',
    );
    _ownerLabelController = _draft.ownerLabelController;
    _signedByController = _draft.signedByController;
    _purchaseStoreController = _draft.purchaseStoreController;
    _marketValueController = _draft.marketValueController;
    _progressCurrentController = _draft.progressCurrentController;
    _progressTotalController = _draft.progressTotalController;
    _timesCompletedController = _draft.timesCompletedController;

    _authorController = TextEditingController(
      text: _creatorNamesForRoles(item.creators, const ['author', 'writer'])
          .join(', '),
    );
    _editorController = TextEditingController(
      text: _creatorNamesForRoles(item.creators, const ['editor']).join(', '),
    );
    _illustratorController = TextEditingController(
      text: _creatorNamesForRoles(item.creators, const ['illustrator'])
          .join(', '),
    );
    _coverArtistController = TextEditingController(
      text:
          _creatorNamesForRoles(item.creators, const ['cover artist', 'cover'])
              .join(', '),
    );
    _photographerController = TextEditingController(
      text: _creatorNamesForRoles(item.creators, const ['photographer'])
          .join(', '),
    );
    _forewordAuthorController = TextEditingController(
      text: _creatorNamesForRoles(item.creators, const ['foreword']).join(', '),
    );
    _translatorController = TextEditingController(
      text:
          _creatorNamesForRoles(item.creators, const ['translator']).join(', '),
    );
    _ghostWriterController = TextEditingController(
      text: _creatorNamesForRoles(item.creators, const ['ghost']).join(', '),
    );
    _narratorController = TextEditingController(
      text: _creatorNamesForRoles(item.creators, const ['narrator']).join(', '),
    );

    _conditionController = _draft.conditionController;
    _gradeController = _draft.gradeController;
    _purchaseDateController = _draft.purchaseDateController;
    _priceController = _draft.priceController;
    _currencyController = _draft.currencyController;
    _quantityController = _draft.quantityController;
    _notesController = _draft.notesController;
    _ratingController = _draft.ratingController;
    _trackingController = _draft.trackingController;
    _trackingController.text =
        _type.trackingProfile.normalizeStorageValue(_trackingController.text) ??
            '';
    _tagsController = _draft.tagsController;
    _tagOptions = List<String>.from(_draft.tagOptions);
    _sellPriceController = _draft.sellPriceController;
    _soldToController = _draft.soldToController;
    _wishlistPriceController = _draft.wishlistPriceController;
    _wishlistCurrencyController = _draft.wishlistCurrencyController;
    _wishlistNotesController = _draft.wishlistNotesController;
    final dialogState = _draft.cloneDialogState();
    _selectedLocationId = dialogState.selectedLocationId;
    _startedAt = dialogState.startedAt;
    _finishedAt = dialogState.finishedAt;
    _soldAt = dialogState.soldAt;
    _selectedEditionId = dialogState.selectedEditionId;
    _selectedVariantId = dialogState.selectedVariantId;
    _customFieldEdits = dialogState.customFieldEdits;
    _itemImageEdits = dialogState.itemImageEdits;
    _collectionStatus = _draft.collectionStatus;
    _collectionStatusController = TextEditingController(
      text: _collectionStatusToLabel(_collectionStatus),
    );
    _lastBagBoardDate = _draft.lastBagBoardDate;
    _originalPublicationDate = item.publishing?.originalPublicationDate;
    _firstEdition = item.publishing?.firstEdition ?? false;
    _audiobookAbridged = item.publishing?.audiobookAbridged ?? false;
    _dustJacket = item.publishing?.dustJacket ?? false;
    _externalLinkEdits.addAll(
      _buildInitialExternalLinkEdits(widget.request.item.trailerUrls),
    );

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
    _subjectsController.dispose();
    _paperTypeController.dispose();
    _printedByController.dispose();
    _dustJacketConditionController.dispose();
    _publicationPlaceController.dispose();
    _originalCountryController.dispose();
    _originalLanguageController.dispose();
    _originalPublisherController.dispose();
    _originalPublicationPlaceController.dispose();
    _authorController.dispose();
    _editorController.dispose();
    _illustratorController.dispose();
    _coverArtistController.dispose();
    _photographerController.dispose();
    _forewordAuthorController.dispose();
    _translatorController.dispose();
    _ghostWriterController.dispose();
    _narratorController.dispose();
    for (final edit in _externalLinkEdits) {
      edit.dispose();
    }
    _collectionStatusController.dispose();
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: _accent,
      icon: _type.workspace.icon,
      title: widget.request.item.title,
      badges: const <Widget>[],
      tabController: _tabController,
      tabs: [
        for (final tab in _tabSpecs) EditTab(icon: tab.icon, label: tab.label)
      ],
      views: _tabViews(),
      onClose: () => Navigator.of(context).pop(),
      onCancel: () => Navigator.of(context).pop(),
      onSave: _submit,
      onPrevious: widget.request.onPrevious,
      onNext: widget.request.onNext,
      footerContent: _isOwned ? _ownedSharedFooterRow() : null,
      tabOrderKey: 'edit_tab_order_${_type.workspace.kind.apiValue}',
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
      case 'main':
        return _mainTab();
      case 'details':
        return _detailsTab();
      case 'credits':
        return _creditsTab();
      case 'plot':
        return _plotTab();
      case 'covers':
        return _coversTab();
      case 'links':
        return _linksTab();
      case 'custom':
        return _customTab();
      case 'read_history':
        return _readHistoryTab();
      case 'value':
        return _valueTab();
      case 'personal':
        return _personalTab();
      case 'photos':
        return _photosTab();
      default:
        throw StateError('Unsupported book edit tab: $id');
    }
  }

  Widget _mainTab() {
    final sections = _tabSectionIds('main');
    return EditTabShell(
      cover: _coverPreview(),
      children: [
        _bookMainOverviewCard(),
        const SizedBox(height: 10),
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

  Widget _bookMainOverviewCard() {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: kEditTextMuted,
          fontWeight: FontWeight.w700,
        );
    final valueStyle = Theme.of(context).textTheme.bodyMedium;

    Widget line(String label, String? value) {
      final normalized = (value ?? '').trim();
      return Row(
        children: [
          SizedBox(width: 108, child: Text(label, style: style)),
          Expanded(
            child: Text(
              normalized.isEmpty ? '—' : normalized,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          ),
        ],
      );
    }

    return Material(
      color: kEditPanelRaised,
      shape: Border(
        left: BorderSide(color: _accent, width: 2),
        top: BorderSide(color: kEditDivider),
        right: BorderSide(color: kEditDivider),
        bottom: BorderSide(color: kEditDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 820;
            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                line('Series', _seriesTitleController.text),
                const SizedBox(height: 8),
                line('Volume', _volumeNumberController.text),
                const SizedBox(height: 8),
                line('Publisher', _publisherController.text),
              ],
            );
            final right = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                line('Release date', _releaseDateController.text),
                const SizedBox(height: 8),
                line('Page count', _pageCountController.text),
                const SizedBox(height: 8),
                line('Language', _languageController.text),
              ],
            );
            if (stacked) {
              return Column(
                children: [
                  left,
                  const SizedBox(height: 10),
                  right,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: left),
                const SizedBox(width: 12),
                Expanded(child: right),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _detailsTab() {
    final sections = _tabSectionIds('details');
    return EditTabShell(
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

  Widget _plotTab() {
    final sections = _tabSectionIds('plot');
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

  Widget _customTab() {
    final sections = _tabSectionIds('custom');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _readHistoryTab() {
    final sections = _tabSectionIds('read_history');
    return EditTabShell(
      children: [
        for (final sectionId in sections) _sectionFor(sectionId),
      ],
    );
  }

  Widget _valueTab() {
    final sections = _tabSectionIds('value');
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
                _field(
                    controller: _numberController,
                    label: _type.mediaFields.numberLabel),
                _field(
                    controller: _publisherController,
                    label: _type.mediaFields.publisherLabel),
                _field(
                    controller: _editionTitleController,
                    label: _type.releaseFields.editionTitleLabel),
                _field(
                    controller: _barcodeController,
                    label: _type.releaseFields.barcodeLabel),
                _field(
                    controller: _variantController,
                    label: _type.releaseFields.variantLabel),
                _field(controller: _countryController, label: 'Country'),
                _field(controller: _languageController, label: 'Language'),
                _field(controller: _imprintController, label: 'Imprint'),
                _field(
                    controller: _seriesGroupController, label: 'Series group'),
                _field(
                    controller: _publicationPlaceController,
                    label: 'Publication place'),
              ], wideColumns: 2, ultraWideColumns: 4),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _genresController,
                label: 'Genres',
                hint: 'Add genre',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _subjectsController,
                label: 'Subjects',
                hint: 'Add subject',
              ),
            ],
          ),
        );
      case 'book_credits':
        return EditSection(
          title: 'Credits',
          accent: _accent,
          child: Column(
            children: [
              EditTokenListField(
                controller: _authorController,
                label: 'Author',
                hint: 'Add author',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _editorController,
                label: 'Editor',
                hint: 'Add editor',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _illustratorController,
                label: 'Illustrator',
                hint: 'Add illustrator',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _coverArtistController,
                label: 'Cover artist',
                hint: 'Add cover artist',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _photographerController,
                label: 'Photographer',
                hint: 'Add photographer',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _forewordAuthorController,
                label: 'Foreword author',
                hint: 'Add foreword author',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _translatorController,
                label: 'Translator',
                hint: 'Add translator',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _ghostWriterController,
                label: 'Ghost writer',
                hint: 'Add ghost writer',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _narratorController,
                label: 'Narrator',
                hint: 'Add narrator',
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
                controller: _seriesTagsController,
                label: 'Series tags',
                hint: 'Add tag',
              ),
            ],
          ),
        );
      case 'book_contents':
        return EditSection(
          title: 'Edition & publication details',
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
                _field(controller: _paperTypeController, label: 'Paper type'),
                _field(controller: _printedByController, label: 'Printed by'),
                _field(
                  controller: _originalPublisherController,
                  label: 'Original publisher',
                ),
                _field(
                  controller: _originalPublicationPlaceController,
                  label: 'Original publication place',
                ),
                _field(
                  controller: _originalCountryController,
                  label: 'Original country',
                ),
                _field(
                  controller: _originalLanguageController,
                  label: 'Original language',
                ),
              ], wideColumns: 2, ultraWideColumns: 3),
              const SizedBox(height: 10),
              _responsiveFields([
                _datePickerField(
                  label: 'Original publication date',
                  value: _originalPublicationDate,
                  onChanged: (value) =>
                      setState(() => _originalPublicationDate = value),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    value: _firstEdition,
                    onChanged: (value) => setState(() => _firstEdition = value),
                    title: const Text('First edition'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    value: _dustJacket,
                    onChanged: (value) => setState(() => _dustJacket = value),
                    title: const Text('Dust jacket'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                _field(
                  controller: _dustJacketConditionController,
                  label: 'Dust jacket condition',
                ),
              ]),
              const SizedBox(height: 10),
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  value: _audiobookAbridged,
                  onChanged: (value) =>
                      setState(() => _audiobookAbridged = value),
                  title: const Text('Audiobook abridged'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
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
          title: 'Links',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Manage website links (Goodreads, Amazon, publisher pages, etc.).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kEditTextMuted,
                    ),
              ),
              const SizedBox(height: 10),
              if (_externalLinkEdits.isEmpty)
                const EditSectionStateMessage(
                  message: 'No links yet. Add one below.',
                  icon: Icons.link_off_outlined,
                )
              else
                Column(
                  children: [
                    for (var index = 0;
                        index < _externalLinkEdits.length;
                        index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildExternalLinkRow(index),
                      ),
                  ],
                ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _addExternalLink,
                  icon: const Icon(Icons.add_link),
                  label: const Text('Add Link'),
                ),
              ),
            ],
          ),
        );
      case 'book_read_history':
        return EditSection(
          title: 'Read history',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track your progress with reading status, rating and timeline.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kEditTextMuted,
                    ),
              ),
              const SizedBox(height: 10),
              _responsiveFields([
                SizedBox(
                  width: 180,
                  child: MediaTrackingStatusField(
                    profile: _type.trackingProfile,
                    value: _trackingController.text,
                    label: 'Reading status',
                    onChanged: (value) {
                      _trackingController.text = value ?? '';
                    },
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: MediaRatingField(controller: _ratingController),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _datePickerField(
                  label: 'Start date',
                  value: _startedAt,
                  onChanged: (value) => setState(() => _startedAt = value),
                ),
                _datePickerField(
                  label: 'End date',
                  value: _finishedAt,
                  onChanged: (value) => setState(() => _finishedAt = value),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _progressCurrentController,
                  label: 'Pages read',
                  validator: optionalIntValidator,
                ),
                _field(
                  controller: _progressTotalController,
                  label: 'Total pages',
                  validator: optionalIntValidator,
                ),
                _field(
                  controller: _timesCompletedController,
                  label: 'Times completed',
                  validator: optionalIntValidator,
                ),
              ]),
            ],
          ),
        );
      case 'book_value':
        return EditSection(
          title: 'Value',
          accent: _accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(
                  controller: _priceController,
                  label: 'Purchase price',
                  validator: optionalMoneyValidator,
                ),
                _field(controller: _currencyController, label: 'Currency'),
                _field(
                  controller: _sellPriceController,
                  label: 'Sold price',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: _soldToController, label: 'Sold to'),
                _datePickerField(
                  label: 'Sold date',
                  value: _soldAt,
                  onChanged: (value) => setState(() => _soldAt = value),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _purchaseStoreController,
                  label: 'Purchase store',
                ),
                _field(
                  controller: _marketValueController,
                  label: 'Estimated market value',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _datePickerField(
                  label: 'Last bag & board date',
                  value: _lastBagBoardDate,
                  onChanged: (value) =>
                      setState(() => _lastBagBoardDate = value),
                ),
              ]),
              if (parseMoneyCents(_priceController.text) != null ||
                  parseMoneyCents(_sellPriceController.text) != null) ...[
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
                if (_isOwned)
                  _field(
                    controller: _ownerLabelController,
                    label: 'Owner',
                  ),
                if (_isOwned)
                  _field(
                    controller: _signedByController,
                    label: 'Signed by',
                  ),
                SizedBox(
                    width: 120,
                    child: MediaRatingField(controller: _ratingController)),
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
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
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
      localBytes: _localImageData('front_cover'),
      secondaryLocalBytes: _localImageData('back_cover'),
      accentColor: _accent,
      borderRadius: 8,
    );
  }

  Uint8List? _localImageData(String imageType) {
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

  Widget _locationField({String labelText = 'Location'}) {
    final label = _selectedLocationLabel;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _pickLocation,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
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

  Widget _ownedSharedFooterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: SingleValuePickField(
              controller: _collectionStatusController,
              options: const ['In collection', 'For sale', 'On order'],
              label: 'Collection status',
              showPickerListAction: true,
              onChanged: (selectedLabel) {
                _collectionStatus = _collectionStatusFromLabel(selectedLabel);
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Index'),
              child: Text(
                  widget.request.ownedItem?.indexNumber?.toString() ?? '—'),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: _field(
              controller: _quantityController,
              label: 'Quantity',
              validator: positiveIntValidator,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 360,
            child: _locationField(labelText: 'Location'),
          ),
        ],
      ),
    );
  }

  String _collectionStatusToLabel(String? value) {
    return switch (value) {
      'for_sale' => 'For sale',
      'on_order' => 'On order',
      _ => 'In collection',
    };
  }

  String? _collectionStatusFromLabel(String? label) {
    final normalized = label?.trim().toLowerCase();
    return switch (normalized) {
      'for sale' => 'for_sale',
      'on order' => 'on_order',
      _ => null,
    };
  }

  String? get _selectedLocationLabel {
    final locationLabel =
        locationPathForId(_availableLocations, _selectedLocationId);
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

  List<String> _creatorNamesForRoles(
    List<Map<String, dynamic>>? creators,
    List<String> roleNeedles,
  ) {
    if (creators == null || creators.isEmpty) {
      return const <String>[];
    }
    final names = <String>[];
    for (final creator in creators) {
      final name = creator['name']?.toString().trim();
      if (name == null || name.isEmpty) {
        continue;
      }
      final role = creator['role']?.toString().toLowerCase() ?? '';
      if (!roleNeedles.any((needle) => role.contains(needle))) {
        continue;
      }
      if (!names.contains(name)) {
        names.add(name);
      }
    }
    return names;
  }

  List<String> _creatorNames(List<Map<String, dynamic>>? creators) {
    return creators
            ?.map((entry) => entry['name']?.toString().trim() ?? '')
            .where((value) => value.isNotEmpty)
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

  List<Map<String, dynamic>>? _creatorList(
    String value, {
    String? role,
  }) {
    final names = _splitList(value);
    if (names == null) {
      return null;
    }
    return [
      for (final name in names) {'name': name, if (role != null) 'role': role}
    ];
  }

  List<Map<String, dynamic>>? _buildUpdatedCreators() {
    final existing =
        widget.request.item.creators ?? const <Map<String, dynamic>>[];
    const knownRoleNeedles = <String>[
      'author',
      'writer',
      'editor',
      'illustrator',
      'cover',
      'photographer',
      'foreword',
      'translator',
      'ghost',
      'narrator',
    ];

    final merged = <Map<String, dynamic>>[];

    for (final creator in existing) {
      final role = creator['role']?.toString().toLowerCase() ?? '';
      if (knownRoleNeedles.any((needle) => role.contains(needle))) {
        continue;
      }
      merged.add(Map<String, dynamic>.from(creator));
    }

    void addCreators(String text, String role) {
      final parsed = _creatorList(text, role: role);
      if (parsed != null) {
        merged.addAll(parsed);
      }
    }

    addCreators(_authorController.text, 'Author');
    addCreators(_editorController.text, 'Editor');
    addCreators(_illustratorController.text, 'Illustrator');
    addCreators(_coverArtistController.text, 'Cover Artist');
    addCreators(_photographerController.text, 'Photographer');
    addCreators(_forewordAuthorController.text, 'Foreword Author');
    addCreators(_translatorController.text, 'Translator');
    addCreators(_ghostWriterController.text, 'Ghost Writer');
    addCreators(_narratorController.text, 'Narrator');

    return merged.isEmpty ? null : merged;
  }

  List<_BookExternalLinkEdit> _buildInitialExternalLinkEdits(
    List<TrailerLink> links,
  ) {
    final externalLinks =
        links.where((link) => link.isExternalLink).toList(growable: false);
    return [
      for (final link in externalLinks)
        _BookExternalLinkEdit(
          url: link.url,
          description: link.description ?? link.title ?? '',
        ),
    ];
  }

  void _addExternalLink() {
    setState(() {
      _externalLinkEdits.add(_BookExternalLinkEdit());
    });
  }

  void _removeExternalLinkAt(int index) {
    setState(() {
      final removed = _externalLinkEdits.removeAt(index);
      removed.dispose();
    });
  }

  void _moveExternalLink(int fromIndex, int toIndex) {
    if (toIndex < 0 || toIndex >= _externalLinkEdits.length) {
      return;
    }
    setState(() {
      final entry = _externalLinkEdits.removeAt(fromIndex);
      _externalLinkEdits.insert(toIndex, entry);
    });
  }

  Widget _buildExternalLinkRow(int index) {
    final link = _externalLinkEdits[index];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kEditPanelRaised,
        border: Border.all(color: kEditDivider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          children: [
            _responsiveFields([
              TextFormField(
                key: ValueKey('bookExternalLinkUrlField_$index'),
                controller: link.urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://example.com',
                ),
              ),
              TextFormField(
                key: ValueKey('bookExternalLinkDescriptionField_$index'),
                controller: link.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Goodreads, Amazon, etc.',
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Move up',
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  onPressed: index > 0
                      ? () => _moveExternalLink(index, index - 1)
                      : null,
                ),
                IconButton(
                  tooltip: 'Move down',
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  onPressed: index < _externalLinkEdits.length - 1
                      ? () => _moveExternalLink(index, index + 1)
                      : null,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Remove link',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _removeExternalLinkAt(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TrailerLink> _buildUpdatedLinks() {
    final preservedTrailers = widget.request.item.trailerUrls
        .where((link) => !link.isExternalLink)
        .toList(growable: false);
    final external = <TrailerLink>[];
    for (final edit in _externalLinkEdits) {
      final url = edit.urlController.text.trim();
      if (url.isEmpty) {
        continue;
      }
      final uri = Uri.tryParse(url);
      final scheme = uri?.scheme.toLowerCase();
      if (uri == null || (scheme != 'http' && scheme != 'https')) {
        continue;
      }
      final description = edit.descriptionController.text.trim();
      external.add(
        TrailerLink(
          url: url,
          title: description.isEmpty ? null : description,
          description: description.isEmpty ? null : description,
          source: 'External Link',
          isAutomatic: false,
          kind: 'external',
        ),
      );
    }
    return [...preservedTrailers, ...external];
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
    _draft.collectionStatus = _collectionStatus;
    _draft.lastBagBoardDate = _lastBagBoardDate;
    _draft.replaceMediaEdits(
      customFieldEdits: _customFieldEdits,
      itemImageEdits: _itemImageEdits,
    );
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
    final existingPublishing = widget.request.item.publishing;
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: parseInt(_pageCountController.text),
      coverPriceCents: existingPublishing?.coverPriceCents,
      currency: existingPublishing?.currency,
      imprint: emptyToNull(_imprintController.text),
      subtitle: emptyToNull(_subtitleController.text),
      seriesGroup: emptyToNull(_seriesGroupController.text),
      publicationPlace: emptyToNull(_publicationPlaceController.text),
      originalCountry: emptyToNull(_originalCountryController.text),
      originalLanguage: emptyToNull(_originalLanguageController.text),
      originalPublicationDate: _originalPublicationDate,
      originalPublicationPlace:
          emptyToNull(_originalPublicationPlaceController.text),
      originalPublisher: emptyToNull(_originalPublisherController.text),
      paperType: emptyToNull(_paperTypeController.text),
      printedBy: emptyToNull(_printedByController.text),
      subjects: _splitList(_subjectsController.text) ?? const <String>[],
      dustJacketCondition: emptyToNull(_dustJacketConditionController.text),
      dustJacket: _dustJacket,
      audiobookAbridged: _audiobookAbridged,
      firstEdition: _firstEdition,
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
          creators: _buildUpdatedCreators(),
          characters: _splitList(_charactersController.text),
          storyArcs: _splitList(_storyArcsController.text),
          genres: _splitList(_genresController.text),
          country: emptyToNull(_countryController.text),
          language: emptyToNull(_languageController.text),
          trailerUrls: _buildUpdatedLinks(),
        ),
        personal: !_isOwned
            ? null
            : LibraryPersonalEditSelection(
                anchorType:
                    (_selectedEditionId != null || _selectedVariantId != null)
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
                signedBy: emptyToNull(_signedByController.text),
                keyComic: null,
                keyReason: null,
                coverPriceCents: null,
                purchaseStore: emptyToNull(_purchaseStoreController.text),
                collectionStatus: _collectionStatus,
                lastBagBoardDate: _lastBagBoardDate,
                marketValueCents: parseMoneyCents(_marketValueController.text),
                ownerLabel: emptyToNull(_ownerLabelController.text),
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
                notes: widget.request.trackingEntry?.notes,
                seasonNumber: widget.request.trackingEntry?.seasonNumber ??
                    widget.request.item.series?.seasonNumber,
                episodeNumber: widget.request.trackingEntry?.episodeNumber ??
                    widget.request.item.series?.episodeNumber,
              ),
        customFieldEdits: _customFieldEdits,
        itemImageEdits: _itemImageEdits,
        wishlist: !_hasWishlistContext
            ? null
            : LibraryWishlistEditSelection(
                anchorType:
                    (_selectedEditionId != null || _selectedVariantId != null)
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

class _BookExternalLinkEdit {
  _BookExternalLinkEdit({
    String url = '',
    String description = '',
  })  : urlController = TextEditingController(text: url),
        descriptionController = TextEditingController(text: description);

  final TextEditingController urlController;
  final TextEditingController descriptionController;

  void dispose() {
    urlController.dispose();
    descriptionController.dispose();
  }
}
