import 'dart:typed_data';

import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/api/mappers/music_mapper.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/edit/library_edit_list_fields.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_tabs/music_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_tabs/music_section_tab.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'edit_tabs/music_sections.dart';
part 'edit_tabs/music_server_compare.dart';

Widget buildMusicLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return MusicLibraryEditDialog(
    request: request,
    draft: LibraryEditDraft.fromRequest(request),
  );
}

class MusicLibraryEditDialog extends ConsumerStatefulWidget {
  const MusicLibraryEditDialog({
    super.key,
    required this.request,
    this.draft,
  });

  final LibraryEditDialogRequest request;
  final LibraryEditDraft? draft;

  @override
  ConsumerState<MusicLibraryEditDialog> createState() =>
      _MusicLibraryEditDialogState();
}

class _MusicLibraryEditDialogState extends ConsumerState<MusicLibraryEditDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final LibraryEditDraft _draft;

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
  late final TextEditingController _originalReleaseDateController;
  late final TextEditingController _recordingDateController;
  late final TextEditingController _releaseYearController;
  late final TextEditingController _releaseStatusController;
  late final TextEditingController _studioController;
  late final TextEditingController _packagingController;
  late final TextEditingController _mediaConditionController;
  late final TextEditingController _soundTypeController;
  late final TextEditingController _vinylColorController;
  late final TextEditingController _vinylWeightController;
  late final TextEditingController _rpmController;
  late final TextEditingController _sparsController;
  late final TextEditingController _instrumentController;
  late final TextEditingController _compositionController;
  late final TextEditingController _extrasController;
  late final TextEditingController _countryController;
  late final TextEditingController _languageController;
  late final TextEditingController _genresController;
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
  late final TextEditingController _indexNumberController;
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
  late final TextEditingController _purchaseStoreController;
  late final TextEditingController _boxSetController;
  late final TextEditingController _storageDeviceController;
  late final TextEditingController _storageSlotController;
  late final TextEditingController _signedByController;
  late final TextEditingController _collectionStatusController;

  List<StorageLocation> _availableLocations = const [];
  String? _selectedLocationId;
  String? _selectedEditionId;
  String? _selectedVariantId;
  bool _locationChanged = false;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  DateTime? _soldAt;
  bool _isLive = false;
  String? _physicalFormatId;
  Map<String, String?> _customFieldEdits = {};
  List<ItemImageEdit> _itemImageEdits = [];
  int _selectedTrackDisc = 1;
  int _nextTrackRowId = 1;
  List<_EditableMusicTrackRow> _editableTrackRows = [];
  final Map<int, _MusicDiscDraft> _discDrafts = <int, _MusicDiscDraft>{};
  late List<String> _composerCredits;
  late List<String> _conductorCredits;
  late List<String> _orchestraCredits;
  late List<String> _chorusCredits;
  late List<String> _songwriterCredits;
  late List<String> _producerCredits;
  late List<String> _engineerCredits;
  late List<MusicCreditEntry> _musicianCredits;
  late List<String> _genreValues;
  late List<String> _soundValues;
  final List<_MusicExternalLinkEdit> _externalLinkEdits =
      <_MusicExternalLinkEdit>[];
  String _rpmSelection = '';
  bool _isFetchingServerSnapshot = false;
  String? _serverSnapshotError;
  MusicRelease? _serverSnapshotItem;
  bool _didAutoOpenMetadataCompare = false;

  bool get _isOwned => widget.request.ownedItem != null;

  bool get _hasTrackingContext =>
      _isOwned || widget.request.trackingEntry != null;

  bool get _isTrackingOnly => !_isOwned && widget.request.trackingEntry != null;

  bool get _hasWishlistContext => widget.request.wishlistItem != null;

  LibraryMetadataItem get _item => widget.request.item;
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
      scope: widget.request.resolvedScope,
    );
  }

  List<LibraryEditTabSpec> get _tabSpecs {
    return widget.request.type.editPresentation
        .builderForScope(widget.request.resolvedScope)
        .buildTabs(
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
    _draft = widget.draft ?? LibraryEditDraft.fromRequest(widget.request);
    final item = _item;
    _tabController = TabController(length: _tabSpecs.length, vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _titleController = _draft.titleController;
    _sortKeyController = _draft.sortKeyController;
    _artistController =
        TextEditingController(text: item.series?.seriesTitle ?? '');
    _subtitleController =
        TextEditingController(text: item.publishing?.subtitle ?? '');
    _publisherController = _draft.publisherController;
    _editionTitleController = _draft.editionTitleController;
    _variantController = _draft.variantController;
    _barcodeController = _draft.barcodeController;
    _catalogNumberController =
        TextEditingController(text: item.music?.catalogNumber ?? '');
    _releaseDateController = _draft.releaseDateController;
    _originalReleaseDateController = TextEditingController(
      text: item.music?.originalReleaseDate == null
          ? ''
          : formatDate(item.music!.originalReleaseDate!),
    );
    _recordingDateController = TextEditingController(
      text: item.music?.recordingDate == null
          ? ''
          : formatDate(item.music!.recordingDate!),
    );
    _releaseYearController = _draft.releaseYearController;
    _releaseStatusController =
        TextEditingController(text: item.music?.releaseStatus ?? '');
    _studioController = TextEditingController(text: item.music?.studio ?? '');
    _packagingController = _draft.packagingController;
    _mediaConditionController = TextEditingController(
      text: item.music?.mediaCondition ?? '',
    );
    _soundTypeController = TextEditingController(
      text: item.music?.soundType ?? '',
    );
    _vinylColorController = TextEditingController(
      text: item.music?.vinylColor ?? '',
    );
    _vinylWeightController = TextEditingController(
      text: item.music?.vinylWeight ?? '',
    );
    _rpmController = TextEditingController(text: item.music?.rpm ?? '');
    _sparsController = TextEditingController(text: item.music?.spars ?? '');
    _instrumentController = TextEditingController(
      text: item.music?.instrument ?? '',
    );
    _compositionController = TextEditingController(
      text: item.music?.composition ?? '',
    );
    _extrasController = _draft.featuresController;
    _countryController = _draft.countryController;
    _languageController = _draft.languageController;
    _genresController = TextEditingController(
      text: (item.genres ?? const <String>[]).join(', '),
    );
    _genreValues = _splitCommaList(_genresController.text) ?? const <String>[];
    _soundValues =
        _splitCommaList(_soundTypeController.text) ?? const <String>[];
    _externalLinkEdits
        .addAll(_buildInitialExternalLinkEdits(_item.trailerUrls));
    _coverController = _draft.coverController;
    _thumbnailController = _draft.thumbnailController;
    _synopsisController = _draft.synopsisController;
    _notesController = _draft.notesController;

    _conditionController = _draft.conditionController;
    _gradeController = _draft.gradeController;
    _purchaseDateController = _draft.purchaseDateController;
    _priceController = _draft.priceController;
    _currencyController = _draft.currencyController;
    _quantityController = _draft.quantityController;
    _indexNumberController = TextEditingController(
      text: widget.request.ownedItem?.indexNumber?.toString() ?? '',
    );
    _ratingController = _draft.ratingController;
    _trackingController = _draft.trackingController;
    _trackingController.text =
        widget.request.type.trackingProfile.normalizeStorageValue(
              _trackingController.text,
            ) ??
            '';
    _tagsController = _draft.tagsController;
    _sellPriceController = _draft.sellPriceController;
    _soldToController = _draft.soldToController;

    _progressCurrentController = _draft.progressCurrentController;
    _progressTotalController = _draft.progressTotalController;
    _timesCompletedController = _draft.timesCompletedController;
    _trackingNotesController = _draft.trackingNotesController;
    _wishlistPriceController = _draft.wishlistPriceController;
    _wishlistCurrencyController = _draft.wishlistCurrencyController;
    _wishlistNotesController = _draft.wishlistNotesController;
    _purchaseStoreController = _draft.purchaseStoreController;
    _boxSetController = _draft.boxSetNameController;
    _storageDeviceController = _draft.storageDeviceController;
    _storageSlotController = _draft.storageSlotController;
    _signedByController = _draft.signedByController;
    _collectionStatusController = TextEditingController(
      text:
          _collectionStatusToLabel(widget.request.ownedItem?.collectionStatus),
    );

    _physicalFormatId = _draft.physicalFormatId;
    final dialogState = _draft.cloneDialogState();
    _selectedLocationId = dialogState.selectedLocationId;
    _startedAt = dialogState.startedAt;
    _finishedAt = dialogState.finishedAt;
    _soldAt = dialogState.soldAt;
    _selectedEditionId = dialogState.selectedEditionId;
    _selectedVariantId = dialogState.selectedVariantId;
    _customFieldEdits = dialogState.customFieldEdits;
    _itemImageEdits = dialogState.itemImageEdits;
    _isLive = item.music?.isLive ?? false;
    _composerCredits = _creatorsForRole(const ['composer']);
    _conductorCredits = _creatorsForRole(const ['conductor']);
    _orchestraCredits = _creatorsForRole(const ['orchestra', 'ensemble']);
    _chorusCredits = _creatorsForRole(const ['chorus', 'choir']);
    _songwriterCredits = _creatorsForRole(const ['songwriter', 'lyricist']);
    _producerCredits = _creatorsForRole(const ['producer']);
    _engineerCredits = _creatorsForRole(const ['engineer']);
    _musicianCredits = _musicianEntriesForRole();
    final normalizedRpm = _rpmController.text.trim();
    _rpmSelection = switch (normalizedRpm) {
      '' => '',
      '33' || '45' || '78' => normalizedRpm,
      _ => 'custom',
    };
    _initializeTrackEditingState();

    unawaited(_loadAvailableLocations());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoOpenMetadataCompareIfRequested();
    });
  }

  void _autoOpenMetadataCompareIfRequested() {
    if (_didAutoOpenMetadataCompare ||
        !widget.request.openMetadataCompareOnOpen ||
        !mounted) {
      return;
    }
    _didAutoOpenMetadataCompare = true;
    final compareTabIndex =
        _tabSpecs.indexWhere((tab) => tab.id == 'classical');
    if (compareTabIndex >= 0 && compareTabIndex < _tabController.length) {
      _tabController.animateTo(compareTabIndex);
    }
    unawaited(_compareWithServerSnapshot());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _artistController.dispose();
    _subtitleController.dispose();
    _catalogNumberController.dispose();
    _originalReleaseDateController.dispose();
    _recordingDateController.dispose();
    _releaseStatusController.dispose();
    _studioController.dispose();
    _mediaConditionController.dispose();
    _soundTypeController.dispose();
    _vinylColorController.dispose();
    _vinylWeightController.dispose();
    _rpmController.dispose();
    _sparsController.dispose();
    _instrumentController.dispose();
    _compositionController.dispose();
    _indexNumberController.dispose();
    _collectionStatusController.dispose();
    _genresController.dispose();
    _disposeTrackEditingState();
    _disposeExternalLinkEditingState();
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artistName = _artistController.text.trim();
    final title =
        artistName.isEmpty ? _item.title : '${_item.title} / $artistName';
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: _accent,
      icon: widget.request.type.workspace.icon,
      title: title,
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
      tabOrderKey:
          'edit_tab_order_${widget.request.type.workspace.kind.apiValue}',
    );
  }

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  List<String> _tabSectionIds(String tabId) {
    return widget.request.type.editPresentation
        .builderForScope(widget.request.resolvedScope)
        .buildTabSectionIds(
          context: _editPresentationContext,
          tabId: tabId,
        );
  }

  Widget _tabViewFor(String id) {
    switch (id) {
      case 'main':
        return _mainTab();
      case 'details':
        return _detailsTab();
      case 'classical':
        return _classicalTab();
      case 'people':
        return _peopleTab();
      case 'tracks':
        return _tracksTab();
      case 'personal':
        return _personalTab();
      case 'custom':
        return _customTab();
      case 'covers':
        return _coversTab();
      case 'photos':
        return _photosTab();
      case 'links':
        return _linksTab();
      default:
        throw StateError('Unsupported music edit tab: $id');
    }
  }

  Widget _mainTab() {
    final sections = _tabSectionIds('main');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _classicalTab() {
    final sections = _tabSectionIds('classical');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _tracksTab() {
    final sections = _tabSectionIds('tracks');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _detailsTab() {
    final sections = _tabSectionIds('details');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _peopleTab() {
    final sections = _tabSectionIds('people');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _personalTab() {
    final sections = _tabSectionIds('personal');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _customTab() {
    final sections = _tabSectionIds('custom');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _coversTab() {
    final sections = _tabSectionIds('covers');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
      cover: _coverPreview(),
    );
  }

  Widget _photosTab() {
    final sections = _tabSectionIds('photos');
    return MusicSectionTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _linksTab() {
    final sections = _tabSectionIds('links');
    return MusicLinksTab(
      sections: sections,
      sectionBuilder: _sectionFor,
    );
  }

  Widget _sectionFor(String id) {
    return _musicSectionFor(id);
  }

  void _updateState(VoidCallback update) {
    setState(update);
  }

  List<int> get _discNumbersFromTracks {
    final values = <int>{};
    for (final row in _editableTrackRows) {
      values.add(row.discNumber <= 0 ? 1 : row.discNumber);
    }
    if (values.isEmpty) {
      values.add(1);
    }
    final sorted = values.toList()..sort();
    return sorted;
  }

  List<_EditableMusicTrackRow> get _visibleTrackRows {
    final rows = _editableTrackRows
        .where((row) => row.discNumber == _selectedTrackDisc)
        .toList(growable: false);
    rows.sort(
        (left, right) => (left.position ?? 0).compareTo(right.position ?? 0));
    return rows;
  }

  List<_EditableMusicTrackRow> get _selectedVisibleTrackRows {
    return _visibleTrackRows
        .where((row) => row.selected)
        .toList(growable: false);
  }

  Widget _trackSelectionToolbar() {
    final selectedRows = _selectedVisibleTrackRows;
    final hasSelection = selectedRows.isNotEmpty;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed: hasSelection ? _clearTrackSelection : null,
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: _visibleTrackRows.isEmpty ? null : _selectAllTracksInDisc,
          child: const Text('Select all'),
        ),
        OutlinedButton(
          onPressed: hasSelection ? _autocapSelectedTracks : null,
          child: const Text('Autocap'),
        ),
        PopupMenuButton<int>(
          enabled: hasSelection && _discNumbersFromTracks.length > 1,
          tooltip: 'Move selected to disc',
          onSelected: _moveSelectedTracksToDisc,
          itemBuilder: (context) => [
            for (final disc in _discNumbersFromTracks)
              if (disc != _selectedTrackDisc)
                PopupMenuItem<int>(
                  value: disc,
                  child: Text('Move to Disc #$disc'),
                ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: kEditDivider),
              color: kAppField,
            ),
            child: const Text('Move to disc'),
          ),
        ),
        FilledButton(
          onPressed: hasSelection ? _removeSelectedTracks : null,
          child: const Text('Remove selected'),
        ),
      ],
    );
  }

  void _initializeTrackEditingState() {
    final tracks = _item.music?.tracks ?? const <CatalogTrack>[];
    _editableTrackRows = [
      for (final track in tracks)
        _createTrackRow(
          discNumber: track.discNumber ?? 1,
          position: track.position,
          title: track.title,
          artist: track.artist,
          durationLabel: _secondsLabel(track.durationSeconds),
        ),
    ];
    final existingDiscs = _item.music?.discs ?? const <CatalogDisc>[];
    for (final disc in _discNumbersFromTracks) {
      final source = existingDiscs.firstWhere(
        (entry) => entry.discNumber == disc,
        orElse: () => CatalogDisc(discNumber: disc),
      );
      _discDrafts[disc] = _MusicDiscDraft(
        discTitle: source.discName ?? 'Disc #$disc',
        storageDevice: source.storageDevice ?? '',
        slot: source.slot ?? '',
        matrixSideA: source.matrixSideA ?? '',
        matrixSideB: source.matrixSideB ?? '',
      );
    }
    _selectedTrackDisc = _discNumbersFromTracks.first;
    for (final disc in _discNumbersFromTracks) {
      _renumberDiscTracks(disc);
    }
  }

  void _disposeTrackEditingState() {
    for (final row in _editableTrackRows) {
      row.dispose();
    }
    for (final draft in _discDrafts.values) {
      draft.dispose();
    }
  }

  void _disposeExternalLinkEditingState() {
    for (final edit in _externalLinkEdits) {
      edit.dispose();
    }
  }

  _MusicDiscDraft _discDraftFor(int discNumber) {
    return _discDrafts.putIfAbsent(
      discNumber,
      () => _MusicDiscDraft(
        discTitle: 'Disc #$discNumber',
        storageDevice: '',
        slot: '',
        matrixSideA: '',
        matrixSideB: '',
      ),
    );
  }

  void _addDiscDraft() {
    setState(() {
      final nextDisc = _discNumbersFromTracks.isEmpty
          ? 1
          : (_discNumbersFromTracks.last + 1);
      _discDraftFor(nextDisc);
      _selectedTrackDisc = nextDisc;
    });
    _addTrackForSelectedDisc();
  }

  void _removeDiscDraft(int discNumber) {
    setState(() {
      final removedRows = _editableTrackRows
          .where((row) => row.discNumber == discNumber)
          .toList(growable: false);
      for (final row in removedRows) {
        row.dispose();
      }
      _editableTrackRows.removeWhere((row) => row.discNumber == discNumber);
      _discDrafts.remove(discNumber)?.dispose();
      final remaining = _discNumbersFromTracks;
      _selectedTrackDisc = remaining.first;
    });
  }

  void _addTrackForSelectedDisc({bool header = false}) {
    setState(() {
      final nextPosition = _visibleTrackRows.isEmpty
          ? 1
          : ((_visibleTrackRows.last.position ?? _visibleTrackRows.length) + 1);
      final newRow = _createTrackRow(
        discNumber: _selectedTrackDisc,
        position: nextPosition,
        title: header ? 'Header' : '',
        artist: '',
        durationLabel: '',
        isHeader: header,
        indentLevel: 0,
      );
      _editableTrackRows.add(newRow);
      _renumberDiscTracks(_selectedTrackDisc);
    });
  }

  void _addTrackUnderHeader(_EditableMusicTrackRow headerRow) {
    setState(() {
      final newRow = _createTrackRow(
        discNumber: headerRow.discNumber,
        position: headerRow.position == null ? null : headerRow.position! + 1,
        title: '',
        artist: '',
        durationLabel: '',
        indentLevel: headerRow.indentLevel + 1,
        parentHeaderRowId: headerRow.rowId,
      );
      final startIndex = _editableTrackRows.indexOf(headerRow);
      var insertIndex = startIndex + 1;
      while (insertIndex < _editableTrackRows.length) {
        final candidate = _editableTrackRows[insertIndex];
        if (candidate.discNumber != headerRow.discNumber ||
            candidate.indentLevel <= headerRow.indentLevel) {
          break;
        }
        insertIndex += 1;
      }
      _editableTrackRows.insert(insertIndex, newRow);
      _renumberDiscTracks(headerRow.discNumber);
    });
  }

  void _removeTrackRow(_EditableMusicTrackRow row) {
    setState(() {
      final toRemove = <_EditableMusicTrackRow>[row];
      if (row.isHeader) {
        final startIndex = _editableTrackRows.indexOf(row);
        for (var index = startIndex + 1;
            index < _editableTrackRows.length;
            index++) {
          final candidate = _editableTrackRows[index];
          if (candidate.discNumber != row.discNumber ||
              candidate.indentLevel <= row.indentLevel) {
            break;
          }
          toRemove.add(candidate);
        }
      }
      for (final candidate in toRemove) {
        _editableTrackRows.remove(candidate);
        candidate.dispose();
      }
      _renumberDiscTracks(row.discNumber);
    });
  }

  void _reorderVisibleTrackRows(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) {
      return;
    }
    setState(() {
      final rows = _visibleTrackRows;
      if (oldIndex < 0 || oldIndex >= rows.length) {
        return;
      }
      final targetIndex = newIndex;
      final row = rows[oldIndex];
      _editableTrackRows.remove(row);
      final remainingRows = _visibleTrackRows;
      if (targetIndex <= 0 || remainingRows.isEmpty) {
        final insertAt = _editableTrackRows.indexWhere(
          (candidate) => candidate.discNumber == _selectedTrackDisc,
        );
        _editableTrackRows.insert(insertAt < 0 ? 0 : insertAt, row);
      } else if (targetIndex >= remainingRows.length) {
        final lastIndex = _editableTrackRows.lastIndexWhere(
          (candidate) => candidate.discNumber == _selectedTrackDisc,
        );
        _editableTrackRows.insert(lastIndex + 1, row);
      } else {
        final anchor = remainingRows[targetIndex];
        final anchorIndex = _editableTrackRows.indexOf(anchor);
        _editableTrackRows.insert(anchorIndex, row);
      }
      _renumberDiscTracks(_selectedTrackDisc);
    });
  }

  void _selectAllTracksInDisc() {
    setState(() {
      for (final row in _visibleTrackRows) {
        row.selected = true;
      }
    });
  }

  void _clearTrackSelection() {
    setState(() {
      for (final row in _visibleTrackRows) {
        row.selected = false;
      }
    });
  }

  void _autocapSelectedTracks() {
    setState(() {
      for (final row in _selectedVisibleTrackRows) {
        row.titleController.text = _toTitleCase(row.titleController.text);
        if (!row.isHeader) {
          row.artistController.text = _toTitleCase(row.artistController.text);
        }
      }
    });
  }

  List<_MusicExternalLinkEdit> _buildInitialExternalLinkEdits(
    List<TrailerLink> links,
  ) {
    final externalLinks =
        links.where((link) => link.isExternalLink).toList(growable: false);
    return [
      for (final link in externalLinks)
        _MusicExternalLinkEdit(
          url: link.url,
          description: link.description ?? link.title ?? '',
        ),
    ];
  }

  void _addExternalLink() {
    setState(() {
      _externalLinkEdits.add(_MusicExternalLinkEdit());
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
            _denseFields([
              TextFormField(
                key: ValueKey('musicExternalLinkUrlField_$index'),
                controller: link.urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://example.com',
                ),
              ),
              TextFormField(
                key: ValueKey('musicExternalLinkDescriptionField_$index'),
                controller: link.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Spotify, Discogs, etc.',
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
    final preservedTrailers = _item.trailerUrls
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

  String _toTitleCase(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return '';
    }
    return words
        .map((word) => word.length <= 1
            ? word.toUpperCase()
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  void _moveSelectedTracksToDisc(int discNumber) {
    setState(() {
      final sourceDisc = _selectedTrackDisc;
      for (final row in _selectedVisibleTrackRows) {
        row.discNumber = discNumber;
        row.selected = false;
      }
      _discDraftFor(discNumber);
      _selectedTrackDisc = discNumber;
      _renumberDiscTracks(sourceDisc);
      _renumberDiscTracks(discNumber);
    });
  }

  void _removeSelectedTracks() {
    setState(() {
      final selected = _selectedVisibleTrackRows;
      for (final row in selected) {
        _editableTrackRows.remove(row);
        row.dispose();
      }
      _renumberDiscTracks(_selectedTrackDisc);
    });
  }

  void _renumberDiscTracks(int discNumber) {
    var index = 1;
    for (final row
        in _editableTrackRows.where((row) => row.discNumber == discNumber)) {
      row.position = index;
      index += 1;
    }
  }

  int? _parseTrackDurationSeconds(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized.contains(':')) {
      final parts = normalized.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0].trim());
        final seconds = int.tryParse(parts[1].trim());
        if (minutes == null || seconds == null || seconds < 0 || seconds > 59) {
          return null;
        }
        return minutes * 60 + seconds;
      }
      if (parts.length == 3) {
        final hours = int.tryParse(parts[0].trim());
        final minutes = int.tryParse(parts[1].trim());
        final seconds = int.tryParse(parts[2].trim());
        if (hours == null ||
            minutes == null ||
            seconds == null ||
            minutes < 0 ||
            minutes > 59 ||
            seconds < 0 ||
            seconds > 59) {
          return null;
        }
        return hours * 3600 + minutes * 60 + seconds;
      }
      return null;
    }
    return int.tryParse(normalized);
  }

  List<CatalogTrack> _buildSubmittedTracks() {
    final output = <CatalogTrack>[];
    for (final row in _editableTrackRows) {
      final title = row.titleController.text.trim();
      final artist = emptyToNull(row.artistController.text);
      final durationSeconds =
          _parseTrackDurationSeconds(row.lengthController.text.trim());
      if (title.isEmpty && artist == null && durationSeconds == null) {
        continue;
      }
      output.add(
        CatalogTrack(
          title: title.isEmpty ? 'Untitled track' : title,
          artist: artist,
          durationSeconds: durationSeconds,
          position: row.position,
          discNumber: row.discNumber,
        ),
      );
    }
    output.sort((left, right) {
      final byDisc = (left.discNumber ?? 1).compareTo(right.discNumber ?? 1);
      if (byDisc != 0) {
        return byDisc;
      }
      return (left.position ?? 0).compareTo(right.position ?? 0);
    });
    return output;
  }

  List<CatalogDisc> _buildSubmittedDiscMetadata() {
    final output = <CatalogDisc>[];
    for (final discNumber in _discNumbersFromTracks) {
      final draft = _discDraftFor(discNumber);
      final discTracks = _editableTrackRows
          .where((row) => row.discNumber == discNumber)
          .toList(growable: false);
      if (discTracks.isEmpty) {
        continue;
      }
      output.add(
        CatalogDisc(
          discNumber: discNumber,
          discName: emptyToNull(draft.discTitleController.text),
          storageDevice: emptyToNull(draft.storageDeviceController.text),
          slot: emptyToNull(draft.slotController.text),
          matrixSideA: emptyToNull(draft.matrixSideAController.text),
          matrixSideB: emptyToNull(draft.matrixSideBController.text),
        ),
      );
    }
    output.sort((left, right) => left.discNumber.compareTo(right.discNumber));
    return output;
  }

  Widget _tracksDiscMetaRow(int discNumber) {
    final draft = _discDraftFor(discNumber);
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TextFormField(
            controller: draft.discTitleController,
            decoration: const InputDecoration(labelText: 'Disc Title'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: draft.storageDeviceController,
            decoration: const InputDecoration(labelText: 'Storage Device'),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 92,
          child: TextFormField(
            controller: draft.slotController,
            decoration: const InputDecoration(labelText: 'Slot'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: draft.matrixSideAController,
            decoration: const InputDecoration(labelText: 'Matrix No. Side A'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: draft.matrixSideBController,
            decoration: const InputDecoration(labelText: 'Matrix No. Side B'),
          ),
        ),
      ],
    );
  }

  Widget _editableTrackRow(_EditableMusicTrackRow row, int index) {
    final indentWidth = row.indentLevel * 18.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Checkbox(
              value: row.selected,
              onChanged: (value) {
                setState(() => row.selected = value ?? false);
              },
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(
            width: 24,
            child: ReorderableDragStartListener(
              index: index,
              child: const Icon(
                Icons.drag_handle,
                size: 16,
                color: kEditTextMuted,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${row.position ?? (index + 1)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (indentWidth > 0) ...[
            SizedBox(width: indentWidth),
            const Icon(Icons.subdirectory_arrow_right,
                size: 14, color: kEditTextMuted),
            const SizedBox(width: 4),
          ],
          Expanded(
            flex: 10,
            child: TextFormField(
              controller: row.titleController,
              style: row.isHeader
                  ? const TextStyle(fontWeight: FontWeight.w700)
                  : null,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: row.artistController,
              enabled: !row.isHeader,
              decoration: const InputDecoration(labelText: 'Artist'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 82,
            child: TextFormField(
              controller: row.lengthController,
              enabled: !row.isHeader,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'Length',
                hintText: 'm:ss',
              ),
            ),
          ),
          if (row.isHeader)
            IconButton(
              tooltip: 'Add track under header',
              onPressed: () => _addTrackUnderHeader(row),
              icon: const Icon(Icons.add, size: 16),
            ),
          IconButton(
            tooltip: 'Remove track',
            onPressed: () => _removeTrackRow(row),
            icon: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }

  _EditableMusicTrackRow _createTrackRow({
    required int discNumber,
    required int? position,
    required String title,
    required String? artist,
    required String? durationLabel,
    bool selected = false,
    bool isHeader = false,
    int indentLevel = 0,
    int? parentHeaderRowId,
  }) {
    final row = _EditableMusicTrackRow(
      rowId: _nextTrackRowId,
      discNumber: discNumber,
      position: position,
      title: title,
      artist: artist,
      durationLabel: durationLabel,
      selected: selected,
      isHeader: isHeader,
      indentLevel: indentLevel,
      parentHeaderRowId: parentHeaderRowId,
    );
    _nextTrackRowId += 1;
    return row;
  }

  Widget _denseFields(List<Widget> children) {
    return LibraryEditDenseFields(
      wideColumns: 2,
      ultraWideColumns: 4,
      wideBreakpoint: 620,
      ultraWideBreakpoint: 900,
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

  Widget _editableRoleSection({
    required String title,
    required List<String> values,
    required ValueChanged<List<String>> onChanged,
    required String hintText,
  }) {
    return EditSection(
      title: title,
      accent: _accent,
      child: EditableNameListField(
        key: ValueKey(title),
        values: values,
        onChanged: onChanged,
        hintText: hintText,
      ),
    );
  }

  Widget _editableMusicianRoleSection({
    required String title,
    required List<MusicCreditEntry> values,
    required ValueChanged<List<MusicCreditEntry>> onChanged,
    required String hintName,
    required String hintInstrument,
  }) {
    return EditSection(
      title: title,
      accent: _accent,
      child: EditableMusicianListField(
        key: ValueKey(title),
        values: values,
        onChanged: onChanged,
        hintName: hintName,
        hintInstrument: hintInstrument,
      ),
    );
  }

  Widget _rpmField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RPM',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '', label: Text('N/A')),
            ButtonSegment(value: '33', label: Text('33')),
            ButtonSegment(value: '45', label: Text('45')),
            ButtonSegment(value: '78', label: Text('78')),
            ButtonSegment(value: 'custom', label: Text('Custom')),
          ],
          selected: {_rpmSelection},
          onSelectionChanged: (selected) {
            final choice = selected.first;
            setState(() {
              _rpmSelection = choice;
              if (choice != 'custom') {
                _rpmController.text = choice;
              } else if (_rpmController.text.trim().isEmpty) {
                _rpmController.text = '';
              }
            });
          },
          showSelectedIcon: false,
        ),
        if (_rpmSelection == 'custom') ...[
          const SizedBox(height: 8),
          _field(controller: _rpmController, label: 'Custom RPM'),
        ],
      ],
    );
  }

  Widget _coverPreview() {
    return LibraryInteractiveCover(
      title: _musicTitleLabel,
      itemNumber: null,
      imageUrl: emptyToNull(_thumbnailController.text) ??
          emptyToNull(_coverController.text) ??
          _item.displayCoverUrl,
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
                      _collectionStatusController.text =
                          _collectionStatusToLabel(
                              _collectionStatusFromLabel(selectedLabel));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
                  child: _field(
                    controller: _indexNumberController,
                    label: 'Index',
                    validator: optionalIntValidator,
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
                  _collectionStatusController.text = _collectionStatusToLabel(
                      _collectionStatusFromLabel(selectedLabel));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _field(
                controller: _indexNumberController,
                label: 'Index',
                validator: optionalIntValidator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _field(
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

  List<MusicCreditEntry> _musicianEntriesForRole() {
    final values = <MusicCreditEntry>[];
    for (final creator in _item.creators ?? const <Map<String, dynamic>>[]) {
      final role = creator['role']?.toString().trim() ?? '';
      if (!_roleMatches(
        role,
        const ['musician', 'performer', 'instrumentalist'],
      )) {
        continue;
      }
      final rawName = creator['name']?.toString().trim() ?? '';
      if (rawName.isEmpty) {
        continue;
      }
      final instrument = _extractInstrumentFromRole(role);
      values.add(
        MusicCreditEntry(
          name: rawName,
          instrument: instrument,
        ),
      );
    }
    return values;
  }

  String? _extractInstrumentFromRole(String role) {
    final match = RegExp(r'\(([^)]+)\)').firstMatch(role);
    final value = match?.group(1)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  List<Map<String, dynamic>>? _buildCreatorsForSubmit() {
    final original = (_item.creators ?? const <Map<String, dynamic>>[])
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList(growable: true);

    final managedKeywords = <String>[
      'composer',
      'conductor',
      'orchestra',
      'ensemble',
      'chorus',
      'choir',
      'songwriter',
      'lyricist',
      'producer',
      'engineer',
      'musician',
      'performer',
      'instrumentalist',
    ];
    final preserved = <Map<String, dynamic>>[
      for (final entry in original)
        if (!_roleMatches(entry['role']?.toString(), managedKeywords)) entry,
    ];
    final rebuilt = <Map<String, dynamic>>[
      ...preserved,
      ..._roleEntries(_composerCredits, 'Composer'),
      ..._roleEntries(_conductorCredits, 'Conductor'),
      ..._roleEntries(_orchestraCredits, 'Orchestra'),
      ..._roleEntries(_chorusCredits, 'Chorus'),
      ..._roleEntries(_songwriterCredits, 'Songwriter'),
      ..._roleEntries(_producerCredits, 'Producer'),
      ..._roleEntries(_engineerCredits, 'Engineer'),
      ..._musicianRoleEntries(_musicianCredits),
    ];
    if (rebuilt.isEmpty) {
      return null;
    }
    final deduped = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final entry in rebuilt) {
      final name = (entry['name']?.toString() ?? '').trim();
      if (name.isEmpty) {
        continue;
      }
      final role = (entry['role']?.toString() ?? '').trim();
      final key = '${role.toLowerCase()}|${name.toLowerCase()}';
      if (!seen.add(key)) {
        continue;
      }
      deduped.add({
        if (role.isNotEmpty) 'role': role,
        'name': name,
      });
    }
    return deduped.isEmpty ? null : deduped;
  }

  List<Map<String, dynamic>> _roleEntries(List<String> names, String role) {
    return [
      for (final name in names)
        if (name.trim().isNotEmpty) {'role': role, 'name': name.trim()},
    ];
  }

  List<Map<String, dynamic>> _musicianRoleEntries(
    List<MusicCreditEntry> values,
  ) {
    return [
      for (final value in values)
        if (value.name.trim().isNotEmpty)
          {
            'role': value.instrument?.trim().isNotEmpty == true
                ? 'Musician (${value.instrument!.trim()})'
                : 'Musician',
            'name': value.name.trim(),
          },
    ];
  }

  bool _roleMatches(String? role, List<String> keywords) {
    final normalized = role?.toLowerCase() ?? '';
    return keywords.any(normalized.contains);
  }

  List<String>? _splitCommaList(String value) {
    final normalized = value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    return normalized.isEmpty ? null : normalized;
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
    _draft.availableLocations = List<StorageLocation>.from(_availableLocations);
    _draft.selectedLocationId = _selectedLocationId;
    _draft.selectedEditionId = _selectedEditionId;
    _draft.selectedVariantId = _selectedVariantId;
    _draft.locationChanged = _locationChanged;
    _draft.startedAt = _startedAt;
    _draft.finishedAt = _finishedAt;
    _draft.soldAt = _soldAt;
    _draft.physicalFormatId = _physicalFormatId;
    _draft.replaceMediaEdits(
      customFieldEdits: _customFieldEdits,
      itemImageEdits: _itemImageEdits,
    );
    final currentTracks = _buildSubmittedTracks();
    final currentDiscs = _buildSubmittedDiscMetadata();
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
      discs: currentDiscs,
      catalogNumber: emptyToNull(_catalogNumberController.text),
      releaseStatus: emptyToNull(_releaseStatusController.text),
      originalReleaseDate: parseDate(_originalReleaseDateController.text),
      recordingDate: parseDate(_recordingDateController.text),
      studio: emptyToNull(_studioController.text),
      rpm: emptyToNull(_rpmController.text),
      spars: emptyToNull(_sparsController.text),
      soundType: emptyToNull(_soundTypeController.text),
      vinylColor: emptyToNull(_vinylColorController.text),
      vinylWeight: emptyToNull(_vinylWeightController.text),
      mediaCondition: emptyToNull(_mediaConditionController.text),
      instrument: emptyToNull(_instrumentController.text),
      isLive: _isLive,
      composition: emptyToNull(_compositionController.text),
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
          creators: _buildCreatorsForSubmit(),
          genres: _splitCommaList(_genresController.text),
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
                features: emptyToNull(_extrasController.text),
                purchaseStore: emptyToNull(_purchaseStoreController.text),
                boxSetName: emptyToNull(_boxSetController.text),
                storageDevice: emptyToNull(_storageDeviceController.text),
                storageSlot: emptyToNull(_storageSlotController.text),
                packaging: emptyToNull(_packagingController.text),
                collectionStatus: _collectionStatusFromLabel(
                  emptyToNull(_collectionStatusController.text),
                ),
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
                seasonNumber: widget.request.trackingEntry?.seasonNumber ??
                    _item.series?.seasonNumber,
                episodeNumber: widget.request.trackingEntry?.episodeNumber ??
                    _item.series?.episodeNumber,
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

class _EditableMusicTrackRow {
  _EditableMusicTrackRow({
    required this.rowId,
    required this.discNumber,
    required this.position,
    required String title,
    required String? artist,
    required String? durationLabel,
    this.selected = false,
    this.isHeader = false,
    this.indentLevel = 0,
    this.parentHeaderRowId,
  })  : titleController = TextEditingController(text: title),
        artistController = TextEditingController(text: artist ?? ''),
        lengthController = TextEditingController(text: durationLabel ?? '');

  final int rowId;
  int discNumber;
  int? position;
  bool selected;
  final bool isHeader;
  final int indentLevel;
  final int? parentHeaderRowId;
  final TextEditingController titleController;
  final TextEditingController artistController;
  final TextEditingController lengthController;

  void dispose() {
    titleController.dispose();
    artistController.dispose();
    lengthController.dispose();
  }
}

class _MusicDiscDraft {
  _MusicDiscDraft({
    required String discTitle,
    required String storageDevice,
    required String slot,
    required String matrixSideA,
    required String matrixSideB,
  })  : discTitleController = TextEditingController(text: discTitle),
        storageDeviceController = TextEditingController(text: storageDevice),
        slotController = TextEditingController(text: slot),
        matrixSideAController = TextEditingController(text: matrixSideA),
        matrixSideBController = TextEditingController(text: matrixSideB);

  final TextEditingController discTitleController;
  final TextEditingController storageDeviceController;
  final TextEditingController slotController;
  final TextEditingController matrixSideAController;
  final TextEditingController matrixSideBController;

  void dispose() {
    discTitleController.dispose();
    storageDeviceController.dispose();
    slotController.dispose();
    matrixSideAController.dispose();
    matrixSideBController.dispose();
  }
}

class _MusicExternalLinkEdit {
  _MusicExternalLinkEdit({
    String url = '',
    String description = '',
  }) {
    urlController.text = url;
    descriptionController.text = description;
  }

  final TextEditingController urlController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void dispose() {
    urlController.dispose();
    descriptionController.dispose();
  }
}
