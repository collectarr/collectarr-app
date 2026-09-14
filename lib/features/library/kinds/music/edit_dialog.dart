import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'dart:typed_data';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';

import 'dart:async';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_list_fields.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/anchors/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_draft.dart';
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
  MusicReleaseGroup? _serverSnapshotItem;
  bool _didAutoOpenMetadataCompare = false;

  bool get _isOwned => widget.request.ownedItem != null;

  bool get _hasTrackingContext =>
      _isOwned || widget.request.trackingSummary != null;

  bool get _isTrackingOnly =>
      !_isOwned && widget.request.trackingSummary != null;

  bool get _hasWishlistContext => widget.request.wishlistItem != null;

  CatalogSearchCandidate get _item => widget.request.kindItem;
  Color get _accent => widget.request.accent;

  LibraryEditPresentationContext get _editPresentationContext {
    return LibraryEditPresentationContext(
      isOwned: _isOwned,
      isTrackingOnly: _isTrackingOnly,
      hasTrackingContext: _hasTrackingContext,
      hasWishlistContext: _hasWishlistContext,
      isDigitalFormat: false,
      hasPhysicalFormats: widget.request.physicalFormats.isNotEmpty,
      hasOwnedTargetOptions: _itemEditions.isNotEmpty,
      hasAdditionalTargetOptions: false,
      hasCustomFields: widget.request.customFieldDefinitions.isNotEmpty,
      scope: widget.request.scope ?? LibraryEditScope.all,
    );
  }

  List<LibraryEditTabSpec> get _tabSpecs {
    return musicKindModule.editCapabilities.presentationCapability.presentation
        .builderForScope(widget.request.scope ?? LibraryEditScope.all)
        .buildTabs(
          context: _editPresentationContext,
        );
  }

  String get _musicTitleLabel {
    final title = _titleController.text.trim();
    return title.isEmpty ? _item.title : title;
  }

  MusicReleaseGroup get _musicGroup =>
      _item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);

  MusicRelease? get _musicRelease => _musicGroup.primaryRelease;

  MusicMedium? get _musicMedium => _musicRelease?.mediums.firstOrNull;

  List<Map<String, dynamic>> get _musicCredits => [
        for (final contribution in _musicRelease?.contributions ??
            const <MusicReleaseContribution>[])
          contribution.toJson(),
      ];

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? LibraryEditDraft.fromRequest(widget.request);
    _tabController = TabController(length: _tabSpecs.length, vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    final musicDraft = _draft.kindDetails is MusicEditDraft
        ? _draft.kindDetails as MusicEditDraft
        : null;
    final group = _musicGroup;
    final release = _musicRelease;
    final medium = _musicMedium;
    final mediumPayload = medium?.metadataJson ?? const <String, dynamic>{};

    _titleController = _draft.metadata.titleController;
    _sortKeyController = _draft.metadata.sortKeyController;
    _artistController = TextEditingController(text: group.artist ?? '');
    _subtitleController = TextEditingController(text: release?.subtitle ?? '');
    _publisherController = TextEditingController(
      text: release?.publisher ?? '',
    );
    _editionTitleController =
        TextEditingController(text: release?.title ?? group.title);
    _variantController = TextEditingController();
    _barcodeController =
        TextEditingController(text: release?.barcode ?? release?.upc ?? '');
    _catalogNumberController =
        TextEditingController(text: release?.catalogNumber ?? '');
    final initialRelDate = group.originalReleaseDate ?? release?.releaseDate;
    _releaseDateController = TextEditingController(
      text: initialRelDate == null ? '' : formatDate(initialRelDate),
    );
    _originalReleaseDateController = TextEditingController(
      text: group.originalReleaseDate == null
          ? ''
          : formatDate(group.originalReleaseDate!),
    );
    _recordingDateController = TextEditingController(
      text: group.recordingDate == null ? '' : formatDate(group.recordingDate!),
    );
    _releaseYearController = TextEditingController(
      text: initialRelDate?.year.toString() ?? '',
    );
    _releaseStatusController =
        TextEditingController(text: release?.releaseStatus ?? '');
    _studioController = TextEditingController(text: group.studio ?? '');
    _packagingController =
        TextEditingController(text: release?.packaging ?? '');
    _mediaConditionController = TextEditingController(
      text: medium?.mediaCondition ?? '',
    );
    _soundTypeController = TextEditingController(
      text: medium?.soundType ?? '',
    );
    _vinylColorController = TextEditingController(
      text: medium?.vinylColor ?? '',
    );
    _vinylWeightController = TextEditingController(
      text: medium?.vinylWeight ?? '',
    );
    _rpmController = TextEditingController(
        text:
            (medium?.rpm ?? _intValue(mediumPayload['rpm']))?.toString() ?? '');
    _sparsController = TextEditingController(text: medium?.spars ?? '');
    _instrumentController = TextEditingController(
      text: _textValue(mediumPayload['instrument']) ?? '',
    );
    _compositionController = TextEditingController(
      text: _textValue(mediumPayload['composition']) ?? '',
    );
    _extrasController = TextEditingController();
    _countryController =
        TextEditingController(text: release?.countryCode ?? '');
    _languageController = TextEditingController(text: release?.language ?? '');
    _genresController = TextEditingController(
      text: group.genres.join(', '),
    );
    _genreValues = _splitCommaList(_genresController.text) ?? const <String>[];
    _soundValues =
        _splitCommaList(_soundTypeController.text) ?? const <String>[];
    _externalLinkEdits.addAll(_buildInitialExternalLinkEdits(_itemLinks));
    _coverController = _draft.metadata.coverController;
    _thumbnailController = _draft.metadata.thumbnailController;
    _synopsisController = _draft.metadata.synopsisController;
    _notesController = _draft.personal.notesController;

    _conditionController = _draft.personal.conditionController;
    _gradeController = _draft.personal.gradeController;
    _purchaseDateController = _draft.personal.purchaseDateController;
    _priceController = _draft.personal.priceController;
    _currencyController = _draft.personal.currencyController;
    _quantityController = _draft.personal.quantityController;
    final typedOwned =
        MusicOwnedItemProjection.fromDispatch(widget.request.ownedItemDispatch);
    _indexNumberController = TextEditingController(
      text: typedOwned?.indexNumber?.toString() ?? '',
    );
    _ratingController = _draft.tracking.ratingController;
    _trackingController = _draft.tracking.trackingController;
    _trackingController.text =
        widget.request.type.trackingProfile.normalizeStorageValue(
              _trackingController.text,
            ) ??
            '';
    _tagsController = _draft.personal.tagsController;
    _sellPriceController = _draft.personal.sellPriceController;
    _soldToController = _draft.personal.soldToController;

    _progressCurrentController = _draft.tracking.progressCurrentController;
    _progressTotalController = _draft.tracking.progressTotalController;
    _timesCompletedController = _draft.tracking.timesCompletedController;
    _trackingNotesController = _draft.tracking.trackingNotesController;
    _wishlistPriceController = _draft.personal.wishlistPriceController;
    _wishlistCurrencyController = _draft.personal.wishlistCurrencyController;
    _wishlistNotesController = _draft.personal.wishlistNotesController;
    _purchaseStoreController = _draft.personal.purchaseStoreController;
    _boxSetController = TextEditingController();
    _storageDeviceController =
        musicDraft?.storageDeviceController ?? TextEditingController();
    _storageSlotController =
        musicDraft?.storageSlotController ?? TextEditingController();
    _signedByController = TextEditingController(
      text: musicDraft?.signedBy ?? typedOwned?.details.signedBy ?? '',
    );
    _collectionStatusController = TextEditingController(
      text: _collectionStatusToLabel(typedOwned?.collectionStatus),
    );

    final resolvedFormat = physicalMediaFormatByLabelOrId(
      medium?.mediumType ?? release?.packaging,
      formats: widget.request.physicalFormats,
    );
    _physicalFormatId = resolvedFormat?.id ??
        emptyToNull(medium?.mediumType ?? release?.packaging ?? '');
    final dialogState = _draft.cloneDialogState();
    _selectedLocationId = dialogState.selectedLocationId;
    _startedAt = dialogState.startedAt;
    _finishedAt = dialogState.finishedAt;
    _soldAt = dialogState.soldAt;
    final selectedTarget = dialogState.selectedTargetRef;
    _selectedEditionId = selectedTarget?.entityType.apiValue == 'release'
        ? selectedTarget?.id
        : selectedTarget?.parentId;
    _selectedVariantId = selectedTarget?.entityType.apiValue == 'release'
        ? selectedTarget?.id
        : null;
    _customFieldEdits = dialogState.customFieldEdits;
    _itemImageEdits = dialogState.itemImageEdits;
    _isLive = group.isLive ?? false;
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
    _publisherController.dispose();
    _editionTitleController.dispose();
    _variantController.dispose();
    _barcodeController.dispose();
    _countryController.dispose();
    _languageController.dispose();
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
      icon: widget.request.type.identity.icon,
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
      tabOrderKey: 'library_edit_tabs_${widget.request.type.kind.apiValue}_'
          '${(widget.request.scope ?? LibraryEditScope.all).name}',
    );
  }

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  List<String> _tabSectionIds(String tabId) {
    return musicKindModule.editCapabilities.presentationCapability.presentation
        .builderForScope(widget.request.scope ?? LibraryEditScope.all)
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
    final group = _musicGroup;
    _editableTrackRows = [
      for (final release in group.releases)
        for (final medium in release.mediums)
          for (final track in medium.tracks)
            _createTrackRow(
              discNumber: medium.mediumNumber <= 0 ? 1 : medium.mediumNumber,
              position: int.tryParse(track.position),
              title: track.title,
              artist: null,
              durationLabel: _secondsLabel(track.durationSeconds),
            ),
    ];
    for (final disc in _discNumbersFromTracks) {
      final medium = [
        for (final release in group.releases) ...release.mediums,
      ].where((medium) => medium.mediumNumber == disc).firstOrNull;
      final source = medium?.metadataJson ?? const <String, dynamic>{};
      _discDrafts[disc] = _MusicDiscDraft(
        discTitle: medium?.title ?? 'Medium #$disc',
        storageDevice: _textValue(source['storage_device']) ?? '',
        slot: _textValue(source['slot']) ?? '',
        matrixSideA: _textValue(source['matrix_side_a']) ?? '',
        matrixSideB: _textValue(source['matrix_side_b']) ?? '',
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
    List<TrailerLinkDto> links,
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

  List<TrailerLinkDto> _buildUpdatedLinks() {
    final preservedTrailers = _itemLinks
        .where((link) => !link.isExternalLink)
        .toList(growable: false);
    final external = <TrailerLinkDto>[];
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
        TrailerLinkDto(
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

  List<MusicMedium> _buildSubmittedMediums(MusicRelease release) {
    final originalByNumber = <int, MusicMedium>{
      for (final medium in release.mediums)
        if (medium.mediumNumber > 0) medium.mediumNumber: medium,
    };
    final numbers = <int>{
      ...originalByNumber.keys,
      ..._discNumbersFromTracks,
    }.toList()
      ..sort();

    return [
      for (final mediumNumber in numbers)
        if (_editableTrackRows.any((row) => row.discNumber == mediumNumber))
          _buildSubmittedMedium(
            release: release,
            original: originalByNumber[mediumNumber],
            mediumNumber: mediumNumber,
          ),
    ];
  }

  MusicMedium _buildSubmittedMedium({
    required MusicRelease release,
    required MusicMedium? original,
    required int mediumNumber,
  }) {
    final mediumId = original?.id ??
        MusicMediumId('${release.id.value}:medium:$mediumNumber');
    final rows = _editableTrackRows
        .where((row) => row.discNumber == mediumNumber)
        .toList(growable: false)
      ..sort(
          (left, right) => (left.position ?? 0).compareTo(right.position ?? 0));
    final originalTracks = <String, MusicTrack>{
      for (final track in original?.tracks ?? const <MusicTrack>[])
        track.position: track,
    };
    final tracks = [
      for (final row in rows)
        if (_trackInputIsPresent(row))
          _buildSubmittedTrack(
            row: row,
            mediumId: mediumId,
            original: originalTracks[row.position?.toString()],
          ),
    ];
    final discDraft = _discDraftFor(mediumNumber);
    return MusicMedium(
      id: mediumId,
      releaseId: release.id,
      mediumNumber: mediumNumber,
      mediumType: _physicalFormatForId(_physicalFormatId)?.label ??
          original?.mediumType,
      title: emptyToNull(discDraft.discTitleController.text) ?? original?.title,
      trackCount: tracks.length,
      expectedTrackCount: original?.expectedTrackCount,
      missingTrackCount: original?.missingTrackCount,
      missingTrackPositions: original?.missingTrackPositions ?? const [],
      toc: original?.toc,
      cddbId: original?.cddbId,
      leadoutOffset: original?.leadoutOffset,
      bpDiscId: original?.bpDiscId,
      mediaCondition: emptyToNull(_mediaConditionController.text) ??
          original?.mediaCondition,
      soundType: emptyToNull(_soundTypeController.text) ?? original?.soundType,
      vinylColor:
          emptyToNull(_vinylColorController.text) ?? original?.vinylColor,
      vinylWeight:
          emptyToNull(_vinylWeightController.text) ?? original?.vinylWeight,
      rpm: _intValue(_rpmController.text) ?? original?.rpm,
      spars: emptyToNull(_sparsController.text) ?? original?.spars,
      tracks: tracks,
      metadataJson: original?.metadataJson ?? const <String, dynamic>{},
    );
  }

  MusicTrack _buildSubmittedTrack({
    required _EditableMusicTrackRow row,
    required MusicMediumId mediumId,
    required MusicTrack? original,
  }) {
    final position = row.position?.toString() ?? original?.position ?? '1';
    final durationSeconds =
        _parseTrackDurationSeconds(row.lengthController.text.trim());
    return MusicTrack(
      id: original?.id ?? MusicTrackId('${mediumId.value}:track:$position'),
      mediumId: mediumId,
      position: position,
      title: emptyToNull(row.titleController.text) ?? 'Untitled track',
      composition:
          original?.composition ?? emptyToNull(_compositionController.text),
      durationMs: durationSeconds == null
          ? original?.durationMs
          : durationSeconds * 1000,
      offsetMs: original?.offsetMs,
      bitrateKbps: original?.bitrateKbps,
      fileSizeBytes: original?.fileSizeBytes,
      trackHash: original?.trackHash,
      instrument:
          original?.instrument ?? emptyToNull(_instrumentController.text),
      metadataJson: original?.metadataJson ?? const <String, dynamic>{},
    );
  }

  bool _trackInputIsPresent(_EditableMusicTrackRow row) {
    return row.titleController.text.trim().isNotEmpty ||
        row.artistController.text.trim().isNotEmpty ||
        row.lengthController.text.trim().isNotEmpty;
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
    for (final creator in _musicCredits) {
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
    for (final creator in _musicCredits) {
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
    final original = _musicCredits
        .map((Map<String, dynamic> entry) => Map<String, dynamic>.from(entry))
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

  String? _submittedTrackDurationLabel() {
    var total = 0;
    for (final row in _editableTrackRows) {
      final seconds = _parseTrackDurationSeconds(row.lengthController.text);
      if (seconds != null && seconds > 0) {
        total += seconds;
      }
    }
    return total == 0 ? null : _secondsLabel(total);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _draft.personal.availableLocations =
        List<StorageLocation>.from(_availableLocations);
    _draft.personal.selectedLocationId = _selectedLocationId;
    final selectedTarget = _musicTargetRef(
      _item.catalogRef,
      editionId: _selectedEditionId,
      variantId: _selectedVariantId,
    );
    _draft.personal.selectedOwnedTargetRef =
        selectedTarget.entityType.apiValue == 'work' ? null : selectedTarget;
    _draft.personal.locationChanged = _locationChanged;
    _draft.tracking.startedAt = _startedAt;
    _draft.tracking.finishedAt = _finishedAt;
    _draft.personal.soldAt = _soldAt;
    _draft.replaceMediaEdits(
      customFieldEdits: _customFieldEdits,
      itemImageEdits: _itemImageEdits,
    );
    final originalGroup = _musicGroup;
    final originalRelease = originalGroup.primaryRelease ??
        MusicRelease(
          id: MusicReleaseId('${originalGroup.id.value}:release'),
          releaseGroupId: originalGroup.id,
          title: originalGroup.title,
        );
    final updatedRelease = MusicRelease(
      id: originalRelease.id,
      releaseGroupId: originalRelease.releaseGroupId,
      title: emptyToNull(_editionTitleController.text) ?? originalRelease.title,
      sortTitle: originalRelease.sortTitle,
      subtitle: emptyToNull(_subtitleController.text),
      releaseType: originalRelease.releaseType,
      releaseStatus: emptyToNull(_releaseStatusController.text) ??
          originalRelease.releaseStatus,
      releaseDate:
          parseDate(_releaseDateController.text) ?? originalRelease.releaseDate,
      publisher:
          emptyToNull(_publisherController.text) ?? originalRelease.publisher,
      countryCode:
          emptyToNull(_countryController.text) ?? originalRelease.countryCode,
      language:
          emptyToNull(_languageController.text) ?? originalRelease.language,
      barcode: emptyToNull(_barcodeController.text) ?? originalRelease.barcode,
      upc: originalRelease.upc,
      catalogNumber: emptyToNull(_catalogNumberController.text) ??
          originalRelease.catalogNumber,
      packaging: _physicalFormatForId(_physicalFormatId)?.label ??
          emptyToNull(_packagingController.text) ??
          originalRelease.packaging,
      coverImageUrl: originalRelease.coverImageUrl,
      coverImageKey: originalRelease.coverImageKey,
      contributions: [
        for (final entry in _buildCreatorsForSubmit() ??
            [
              for (final contribution in originalRelease.contributions)
                contribution.toJson(),
            ])
          MusicReleaseContribution.fromJson(entry),
      ],
      identifiers: originalRelease.identifiers,
      mediums: _buildSubmittedMediums(originalRelease),
      metadataJson: {
        ...originalRelease.metadataJson,
        'trailer_urls': [
          for (final link in _buildUpdatedLinks()) link.toJson()
        ],
      },
    );
    final updatedGroup = MusicReleaseGroup(
      id: originalGroup.id,
      title: emptyToNull(_titleController.text) ?? originalGroup.title,
      sortTitle:
          emptyToNull(_sortKeyController.text) ?? originalGroup.sortTitle,
      artist: emptyToNull(_artistController.text) ?? originalGroup.artist,
      originalTitle: originalGroup.originalTitle,
      synopsis: emptyToNull(_synopsisController.text) ?? originalGroup.synopsis,
      originalReleaseDate: parseDate(_originalReleaseDateController.text) ??
          originalGroup.originalReleaseDate,
      recordingDate: parseDate(_recordingDateController.text) ??
          originalGroup.recordingDate,
      studio: emptyToNull(_studioController.text) ?? originalGroup.studio,
      isLive: _isLive,
      genres: _splitCommaList(_genresController.text) ?? originalGroup.genres,
      coverImageUrl:
          emptyToNull(_coverController.text) ?? originalGroup.coverImageUrl,
      coverImageKey: originalGroup.coverImageKey,
      releases: [
        if (originalGroup.releases.isEmpty) updatedRelease,
        for (final release in originalGroup.releases)
          release.id == originalRelease.id ? updatedRelease : release,
      ],
      metadataJson: {
        ...originalGroup.metadataJson,
        'trailer_urls': [
          for (final link in _buildUpdatedLinks()) link.toJson()
        ],
      },
    );
    final updatedItem = CatalogItemDto(
      identity: _item.identity,
      kindMetadata: updatedGroup,
    );
    final updatedCandidate = CatalogSearchCandidate.fromItem(updatedItem);

    Navigator.of(context).pop(
      LibraryEditSelection(
        item: updatedCandidate.editMetadata,
        kindItem: updatedCandidate,
        personal: !_isOwned
            ? null
            : LibraryPersonalEditSelection(
                targetRef: selectedTarget,
                condition: emptyToNull(_conditionController.text),
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
                purchaseStore: emptyToNull(_purchaseStoreController.text),
                collectionStatus: _collectionStatusFromLabel(
                  emptyToNull(_collectionStatusController.text),
                ),
              ),
        tracking: !_hasTrackingContext
            ? null
            : LibraryTrackingEditSelection(
                targetRef: selectedTarget,
                rating: parseInt(_ratingController.text),
                readStatus: emptyToNull(_trackingController.text),
                startedAt: _startedAt,
                finishedAt: _finishedAt,
                progressCurrent: parseInt(_progressCurrentController.text),
                progressTotal: parseInt(_progressTotalController.text),
                timesCompleted: parseInt(_timesCompletedController.text),
                notes: emptyToNull(_trackingNotesController.text),
              ),
        customFieldEdits: _customFieldEdits,
        itemImageEdits: _itemImageEdits,
        wishlist: !_hasWishlistContext
            ? null
            : LibraryWishlistEditSelection(
                catalogRef: selectedTarget,
                targetPriceCents:
                    parseMoneyCents(_wishlistPriceController.text),
                currency: emptyToNull(_wishlistCurrencyController.text),
                notes: emptyToNull(_wishlistNotesController.text),
              ),
      ),
    );
  }

  List<CatalogEditionDto> get _itemEditions => [
        for (final release in _musicGroup.releases)
          CatalogEditionDto(
            id: release.id.value,
            title: release.title,
            publisher: release.publisher,
            upc: release.upc ?? release.barcode,
            language: release.language,
            releaseDate: release.releaseDate,
            physicalFormat: release.packaging,
            physicalFormatLabel: release.packaging,
            discs: [
              for (final medium in release.mediums)
                CatalogDiscDto(
                  discNumber: medium.mediumNumber,
                  name: medium.title,
                  tracks: [
                    for (final track in medium.tracks)
                      CatalogTrackDto(
                        title: track.title,
                        position: int.tryParse(track.position),
                        durationSeconds: track.durationSeconds,
                        discNumber: medium.mediumNumber,
                      ),
                  ],
                ),
            ],
          ),
      ];

  List<TrailerLinkDto> get _itemLinks => _item.toTransport().trailerUrls;

  CatalogEditionDto? _selectedEdition() {
    final selectedId = _selectedEditionId;
    if (selectedId == null) {
      return null;
    }
    for (final edition in _itemEditions) {
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
        for (final edition in _itemEditions)
          DropdownMenuItem<String>(
            value: edition.id,
            child: Text(edition.title),
          ),
      ],
      onChanged: (value) {
        final edition = resolveLibraryEditionSelection(
          _itemEditions,
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
    final variants = edition?.variants ?? const <CatalogVariantDto>[];
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

CatalogEntityRef _musicTargetRef(
  CatalogEntityRef rootRef, {
  String? editionId,
  String? variantId,
}) {
  final edition = _normalizedMusicTargetId(editionId);
  final variant = _normalizedMusicTargetId(variantId);
  if (variant != null) {
    return CatalogEntityRef(
      kind: rootRef.kind,
      entityType: const CatalogEntityTypeId('release'),
      id: variant,
      rootId: rootRef.id,
      parentId: edition,
    );
  }
  if (edition != null) {
    return CatalogEntityRef(
      kind: rootRef.kind,
      entityType: const CatalogEntityTypeId('release'),
      id: edition,
      rootId: rootRef.id,
    );
  }
  return rootRef;
}

String? _normalizedMusicTargetId(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String? _textValue(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
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
