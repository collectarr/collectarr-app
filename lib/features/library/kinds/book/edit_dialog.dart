import 'dart:typed_data';

import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/storage_location.dart';

import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_tabs/book_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_tabs/book_section_tab.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'edit_tabs/book_sections.dart';

Widget buildBookLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  final resolvedRequest = request.scope == LibraryEditScope.all
      ? request.copyWith(scope: LibraryEditScope.media)
      : request;
  return BookLibraryEditDialog(
    request: resolvedRequest,
    draft: LibraryEditDraft.fromRequest(resolvedRequest),
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
  late final TextEditingController _indexNumberController;
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
  List<String> _genreOptions = const [];
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

  List<BookEdition> get _bookEditions =>
      widget.request.item is BookWorkspaceEntry
          ? (widget.request.item as BookWorkspaceEntry).bookEditions
          : const <BookEdition>[];

  LibraryEditPresentationContext get _tabPresentationContext {
    return LibraryEditPresentationContext(
      isOwned: _isOwned,
      isTrackingOnly: _isTrackingOnly,
      hasTrackingContext: _hasTrackingContext,
      hasWishlistContext: _hasWishlistContext,
      isDigitalFormat: false,
      hasPhysicalFormats: false,
      hasEditionAnchors: _bookEditions.isNotEmpty,
      hasBundleReleaseAnchors: false,
      hasCustomFields: widget.request.customFieldDefinitions.isNotEmpty,
      scope: widget.request.resolvedScope,
    );
  }

  List<LibraryEditTabSpec> get _tabSpecs {
    return _type.editPresentation
        .builderForScope(widget.request.resolvedScope)
        .buildTabs(
          context: _tabPresentationContext,
        );
  }

  String get _bookTitleLabel => _titleController.text.trim().isEmpty
      ? widget.request.item.title
      : _titleController.text.trim();

  String get _bookHeaderTitle {
    final title = _bookTitleLabel;
    final author = _authorController.text.trim();
    if (author.isEmpty) {
      return title;
    }
    return '$title / $author';
  }

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
    _indexNumberController = TextEditingController(
      text: widget.request.ownedItem?.indexNumber?.toString() ?? '',
    );
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
      _authorController,
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
    _indexNumberController.dispose();
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
      title: _bookHeaderTitle,
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
    return _type.editPresentation
        .builderForScope(widget.request.resolvedScope)
        .buildTabSectionIds(
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
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _bookSummaryPills() {
    return Wrap(
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
    );
  }

  Widget _detailsTab() {
    final sections = _tabSectionIds('details');
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
      header: [
        _bookSummaryPills(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _creditsTab() {
    final sections = _tabSectionIds('credits');
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _plotTab() {
    final sections = _tabSectionIds('plot');
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _coversTab() {
    final sections = _tabSectionIds('covers');
    return BookSectionTab(
      cover: _coverPreview(),
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _linksTab() {
    final sections = _tabSectionIds('links');
    return BookLinksTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _customTab() {
    final sections = _tabSectionIds('custom');
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _readHistoryTab() {
    final sections = _tabSectionIds('read_history');
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _valueTab() {
    final sections = _tabSectionIds('value');
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _personalTab() {
    final sections = _tabSectionIds('personal');
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _photosTab() {
    final sections = _tabSectionIds('photos');
    return BookSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _sectionFor(String id) {
    return _bookSectionFor(id);
  }

  void _updateState(VoidCallback update) {
    setState(update);
  }

  Widget _responsiveFields(List<Widget> children) {
    return LibraryEditResponsiveRow(children: children);
  }

  Widget _denseFields(
    List<Widget> children, {
    int wideColumns = 2,
    int ultraWideColumns = 3,
  }) {
    return LibraryEditDenseFields(
      wideColumns: wideColumns,
      ultraWideColumns: ultraWideColumns,
      children: children,
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return LibraryEditTextField(
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
    );
  }

  Widget _footerField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: const InputDecoration(
        suffixIcon: SizedBox.shrink(),
        suffixIconConstraints: BoxConstraints(
          minWidth: 0,
          minHeight: 40,
        ),
      ).copyWith(labelText: label),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
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
                      _collectionStatus =
                          _collectionStatusFromLabel(selectedLabel);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
                  child: _footerField(
                    controller: _indexNumberController,
                    label: 'Index',
                    validator: optionalIntValidator,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
                  child: _footerField(
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
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
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
            Expanded(
              flex: 2,
              child: _footerField(
                controller: _indexNumberController,
                label: 'Index',
                validator: optionalIntValidator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _footerField(
                controller: _quantityController,
                label: 'Quantity',
                validator: positiveIntValidator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: _locationField(labelText: 'Location'),
            ),
          ],
        );
      },
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
    final genreOptions = await loadMultiValuePickListOptions(
      ref.read(localDatabaseProvider),
      listName: kGenrePickListName,
      mediaKind: widget.request.type.workspace.kind.apiValue,
      selectedValues: splitPickListValues(_genresController.text),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _tagOptions = tagOptions;
      _genreOptions = genreOptions;
    });
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

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return LibraryDateFieldButton(
      label: label,
      value: value,
      onChanged: onChanged,
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
      volumeNumber: parseDouble(_volumeNumberController.text),
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
        scope: widget.request.resolvedScope,
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
                indexNumber: parseInt(_indexNumberController.text),
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

  BookEdition? _selectedEdition() {
    final selectedId = _selectedEditionId;
    if (selectedId == null) {
      return null;
    }
    for (final edition in _bookEditions) {
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
        for (final edition in _bookEditions)
          DropdownMenuItem<String>(
            value: edition.id,
            child: Text(edition.title),
          ),
      ],
      onChanged: (value) {
        BookEdition? edition;
        final selectedId = emptyToNull(value ?? '');
        if (selectedId != null) {
          for (final candidate in _bookEditions) {
            if (candidate.id == selectedId) {
              edition = candidate;
              break;
            }
          }
        }
        setState(() {
          _selectedEditionId = edition?.id;
          _selectedVariantId = _resolvePrimaryVariantId(edition);
        });
      },
    );
  }

  Widget _variantSelectionField() {
    final edition = _selectedEdition();
    final variants = edition?.variants ?? const <BookVariant>[];
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

  String? _resolvePrimaryVariantId(BookEdition? edition) {
    if (edition == null) {
      return null;
    }
    for (final variant in edition.variants) {
      if (variant.isPrimary) {
        return variant.id;
      }
    }
    return edition.variants.isEmpty ? null : edition.variants.first.id;
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
