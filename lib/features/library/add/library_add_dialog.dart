import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'dart:async';

import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_contracts.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_form_options_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_manual_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_state.dart';
import 'package:collectarr_app/features/library/add/layout/library_add_dialog_layout.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_bottom_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_mode_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_preview_pane.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

export 'controllers/library_add_dialog_requests.dart';
export 'controllers/library_add_manual_draft.dart';
export 'library_add_ranking.dart';
export 'panes/library_add_preview_pane.dart';

class LibraryAddDialog extends ConsumerStatefulWidget {
  const LibraryAddDialog({
    super.key,
    required this.type,
    this.accent,
    this.initialQuery,
    this.initialIdentifier,
    this.autoLookupInitialIdentifier = true,
    this.coverScanService = const LocalLibraryCoverScanService(),
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
  });

  final LibraryKindRegistration type;
  final Color? accent;
  final String? initialQuery;
  final String? initialIdentifier;
  final bool autoLookupInitialIdentifier;
  final LibraryCoverScanService coverScanService;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;

  @override
  ConsumerState<LibraryAddDialog> createState() => LibraryAddDialogState();
}

class LibraryAddDialogState extends ConsumerState<LibraryAddDialog> {
  late final LibraryAddSessionController _controller;
  late final LibraryAddManualDraft _manualDraft;
  static const _formOptionsController = LibraryAddFormOptionsController();

  late final TextEditingController _queryController;
  late final TextEditingController _identifierController;

  List<StorageLocation> _availableLocations = const [];
  List<String> _conditionOptions = const [];
  List<String> _tagOptions = const [];
  List<CustomFieldDefinition> _manualCustomFieldDefinitions = const [];

  double? _dialogWidth;
  double? _dialogHeight;

  double _resultsPaneWidth = 500;
  bool _isClosing = false;
  bool _manualDialogOpen = false;
  bool _hasOpenedManualDialog = false;
  final Map<String, ({String listName, Set<String> values})>
      _manualVocabularyValues = {};

  void _closeDialog([LibraryAddDialogResult? result]) {
    if (!mounted || _isClosing) return;
    _isClosing = true;
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || route == null || !route.isCurrent) return;
      if (navigator.canPop()) navigator.pop(result);
    });
  }

  LibraryAddDialogResult _addResult(Iterable<String> itemIds) {
    return LibraryAddDialogResult(
      target: _controller.state.target,
      itemIds: itemIds
          .where((id) => id.trim().isNotEmpty)
          .toSet()
          .toList(growable: false),
    );
  }

  List<String> _currentSubmissionItemIds() {
    final state = _controller.state;
    final ids = <String>[];
    final checkedResultIds = state.selection.checkedResultIds;
    if (checkedResultIds.isNotEmpty) {
      for (final item in state.search.results) {
        if (checkedResultIds.contains(item.reference.id)) {
          ids.add(item.reference.id);
        }
      }
    }
    if (ids.isEmpty) {
      final selectedItem = state.selectedItem;
      if (selectedItem != null) {
        ids.add(selectedItem.reference.id);
      }
    }
    return ids;
  }

  double _clampedResultsPaneWidth(double totalWidth) {
    return LibraryAddDialogLayout.clampResultsPaneWidth(
      totalWidth: totalWidth,
      requestedWidth: _resultsPaneWidth,
    );
  }

  void _resizeResultsPane(double delta, double totalWidth) {
    setState(() {
      _resultsPaneWidth = LibraryAddDialogLayout.clampResultsPaneWidth(
        totalWidth: totalWidth,
        requestedWidth: _clampedResultsPaneWidth(totalWidth) + delta,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _manualCustomFieldDefinitions =
        List<CustomFieldDefinition>.of(widget.customFieldDefinitions);
    if (libraryUiPolicyForKind(widget.type.kind).wideDialog) {
      _resultsPaneWidth = 720;
    }
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    _identifierController =
        TextEditingController(text: widget.initialIdentifier ?? '');

    _manualDraft = LibraryAddManualDraft(
      customFieldValues: widget.customFieldValues,
      itemImages: widget.itemImages,
      kindDraft: libraryAddForKind(widget.type.kind).createManualDraft(),
    );
    _manualDraft.kindDraft.catalogTitle = _queryController.text;

    _controller = LibraryAddSessionController(
      kind: widget.type.kind,
      type: widget.type,
      ownedMutations: ref.read(ownedItemMutationsProvider),
      wishlistMutations: ref.read(wishlistMutationsProvider),
      trackingMutations: ref.read(trackingMutationsProvider),
      api: ref.read(apiClientProvider),
      catalog: CatalogTransportRepository(ref.read(localDatabaseProvider)),
      coverScanService: widget.coverScanService,
      onAuthSessionExpired: (error, action) => ref
          .read(authControllerProvider.notifier)
          .clearSessionIfRejected(error),
    );

    _controller.addListener(_onControllerStateChanged);

    final editCap = libraryEditPresentationForKind(widget.type.kind);
    _conditionOptions = editCap.conditions;
    _loadAvailableLocations();
    _loadPickListOptions();
    _loadPrefillDefaults();
    unawaited(_loadManualCustomFieldDefinitions());

    if (widget.initialIdentifier != null &&
        widget.initialIdentifier!.isNotEmpty &&
        widget.autoLookupInitialIdentifier) {
      _controller.setMode(LibraryAddDialogMode.identifier);
      _controller.updateIdentifier(widget.initialIdentifier!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.lookupIdentifier(identifierCode: widget.initialIdentifier!);
      });
    } else if (widget.initialIdentifier != null &&
        widget.initialIdentifier!.isNotEmpty) {
      _controller.setMode(LibraryAddDialogMode.identifier);
      _controller.updateIdentifier(widget.initialIdentifier!);
    } else if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.updateQuery(widget.initialQuery!);
    }
  }

  void _onControllerStateChanged() {
    if (!mounted) return;
    final state = _controller.state;
    if (_queryController.text != state.search.query) {
      _queryController.value = TextEditingValue(
        text: state.search.query,
        selection: TextSelection.collapsed(offset: state.search.query.length),
      );
    }
    if (_identifierController.text != state.search.identifierCode) {
      _identifierController.value = TextEditingValue(
        text: state.search.identifierCode,
        selection:
            TextSelection.collapsed(offset: state.search.identifierCode.length),
      );
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant LibraryAddDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type.kind != widget.type.kind) {
      _manualDraft.dispose();
      _hasOpenedManualDialog = false;
      _manualVocabularyValues.clear();
      _manualDraft = LibraryAddManualDraft(
        customFieldValues: widget.customFieldValues,
        itemImages: widget.itemImages,
        kindDraft: libraryAddForKind(widget.type.kind).createManualDraft(),
      );
      _manualCustomFieldDefinitions =
          List<CustomFieldDefinition>.of(widget.customFieldDefinitions);
      unawaited(_loadManualCustomFieldDefinitions());
    }
  }

  Future<void> _loadAvailableLocations() async {
    final locations = await _formOptionsController.loadLocations(
      ref.read(localDatabaseProvider),
    );
    if (!mounted) return;
    setState(() {
      _availableLocations = locations;
    });
  }

  Future<void> _loadPrefillDefaults() async {
    final defaults = await PrefillDefaults.load();
    if (!mounted) return;
    if (defaults.tags != null) {
      _controller.setDefaultTags(defaults.tags);
    }
    if (defaults.locationId != null) {
      _controller.setDefaultLocationId(defaults.locationId);
    }
    await _loadPickListOptions();
  }

  Future<void> _loadPickListOptions() async {
    final state = _controller.state;
    final options = await _formOptionsController.loadPickLists(
      database: ref.read(localDatabaseProvider),
      type: widget.type,
      selectedCondition: state.defaultCondition,
      selectedTags: state.defaultTags,
    );
    if (!mounted) return;
    setState(() {
      _conditionOptions = options.conditions;
      _tagOptions = options.tags;
    });
  }

  Future<void> _showDefaultTagsEditor() async {
    final controller =
        TextEditingController(text: _controller.state.defaultTags ?? '');
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (dialogCtx) => AccentAlertDialog(
          title: const Text('Owned default tags'),
          content: SizedBox(
            width: 440,
            child: TagPickListField(
              controller: controller,
              options: _tagOptions,
              label: 'Tags',
              hint: 'Comma-separated tags',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(
                joinPickListValues(splitPickListValues(controller.text)) ?? '',
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      if (!mounted || result == null) return;
      _controller.setDefaultTags(result.isEmpty ? null : result);
    } finally {
      controller.dispose();
    }
  }

  Future<void> _pickDefaultLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _controller.state.defaultLocationId,
    );
    if (result == null) return;
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) return;
    setState(() {
      _availableLocations = locations;
    });
    _controller.setDefaultLocationId(result.isEmpty ? null : result);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _manualDraft.dispose();
    _queryController.dispose();
    _identifierController.dispose();
    _controller.dispose();
    super.dispose();
  }

  LibraryAddManualPaneRequest _buildManualPaneRequest(
    LibraryAddSessionState state,
    Color accent, {
    BuildContext? manualDialogContext,
  }) {
    return LibraryAddManualPaneRequest(
      kind: widget.type.kind,
      accent: accent,
      type: widget.type,
      commonDraft: state.commonDraft,
      kindDraft: state.manualDraft,
      manualDraft: _manualDraft.kindDraft,
      onCommonDraftChanged: (common) =>
          _controller.updateCommonDraft((_) => common),
      onKindDraftChanged: (draft) => _controller.updateKindDraft((_) => draft),
      tagsController: _manualDraft.tagsController,
      personalNotesController: _manualDraft.personalNotesController,
      coverPriceController: _manualDraft.coverPriceController,
      priceController: _manualDraft.priceController,
      purchaseDateController: _manualDraft.purchaseDateController,
      purchaseStoreController: _manualDraft.purchaseStoreController,
      sellPriceController: _manualDraft.sellPriceController,
      soldDateController: _manualDraft.soldDateController,
      ownerLabelController: _manualDraft.ownerLabelController,
      linksController: _manualDraft.linksController,
      isAdding: state.isAdding || state.submitState.isLoading,
      defaultCondition: state.defaultCondition,
      conditions: _conditionOptions,
      locations: _availableLocations,
      defaultLocationId: state.defaultLocationId,
      defaultLocationLabel:
          locationPathForId(_availableLocations, state.defaultLocationId),
      defaultPurchaseDate: state.defaultPurchaseDate,
      defaultTags: state.defaultTags,
      onAddOwned: () => _submitManualFromManualPane(
        LibraryAddTarget.owned,
        manualDialogContext,
      ),
      onAddWishlist: () => _submitManualFromManualPane(
        LibraryAddTarget.wishlist,
        manualDialogContext,
      ),
      onAddTrack: () => _submitManualFromManualPane(
        LibraryAddTarget.track,
        manualDialogContext,
      ),
      onPropose: _proposeManualDraft,
      customFieldDefinitions: _manualCustomFieldDefinitions,
      customFieldValues: _manualDraft.customFieldValues,
      onCustomFieldValuesChanged: (vals) {
        _manualDraft.customFieldValues = vals;
        _notifyManualDraftChanged();
      },
      itemImages: _manualDraft.itemImages,
      onItemImagesChanged: (imgs) {
        _applyManualImageEdits(imgs);
        _notifyManualDraftChanged();
      },
      onVocabularyValueChanged: _recordManualVocabularyValue,
      onVocabularyValuesChanged: _recordManualVocabularyValues,
    );
  }

  void _recordManualVocabularyValue({
    required String fieldId,
    required String? listName,
    required String? value,
  }) {
    if (listName == null || value == null || value.trim().isEmpty) {
      _manualVocabularyValues.remove(fieldId);
      return;
    }
    _manualVocabularyValues[fieldId] = (
      listName: listName,
      values: {value.trim()},
    );
  }

  void _recordManualVocabularyValues({
    required String fieldId,
    required String? listName,
    required Set<String> values,
  }) {
    final customValues = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    if (listName == null || customValues.isEmpty) {
      _manualVocabularyValues.remove(fieldId);
      return;
    }
    _manualVocabularyValues[fieldId] = (
      listName: listName,
      values: customValues,
    );
  }

  Future<void> _persistManualVocabularyValues() async {
    if (_manualVocabularyValues.isEmpty) return;
    final valuesByList = <String, Set<String>>{};
    for (final pending in _manualVocabularyValues.values) {
      final values = valuesByList.putIfAbsent(
        pending.listName,
        () => <String>{},
      );
      values.addAll(pending.values);
    }
    final repository = PickListRepository(ref.read(localDatabaseProvider));
    for (final entry in valuesByList.entries) {
      for (final value in entry.value) {
        await repository.addValue(
          entry.key,
          value,
          mediaKind: widget.type.kind.apiValue,
        );
      }
    }
    _manualVocabularyValues.clear();
  }

  void _notifyManualDraftChanged() {
    _controller.state = _controller.state.copyWith();
  }

  Future<void> _loadManualCustomFieldDefinitions() async {
    if (widget.customFieldDefinitions.isNotEmpty) return;
    final definitions = await CustomFieldRepository(
      ref.read(localDatabaseProvider),
    ).listDefinitions(
      mediaKind: widget.type.kind.apiValue,
      targetScope: CustomFieldTargetScope.ownedCopy,
    );
    if (!mounted) return;
    setState(() => _manualCustomFieldDefinitions = definitions);
  }

  Future<void> _proposeManualDraft() async {
    if (_controller.state.isAdding) return;
    final capability = libraryAddForKind(widget.type.kind);
    final Map<String, Object?>? catalogItem =
        capability.buildManualProposalData(
      _manualDraft.kindDraft,
      title: _manualDraft.kindDraft.catalogTitle,
    );
    if (catalogItem == null) {
      _controller.reportSubmissionError(
        capability.manualCandidateValidationMessage,
      );
      return;
    }
    _controller.state = _controller.state.copyWith(isAdding: true);
    try {
      await createAndRecordLibraryMetadataProposal(
        api: ref.read(apiClientProvider),
        kind: widget.type.kind.apiValue,
        catalogItem: catalogItem,
        source: 'Manual Add form',
      );
      await _persistManualVocabularyValues();
      if (!mounted) return;
      showAppToast(
        context,
        '${widget.type.identity.singularLabel} proposal sent for review.',
        tone: AppToastTone.success,
      );
    } catch (error) {
      if (!mounted) return;
      showAppToast(
        context,
        'Could not send the proposal. $error',
        tone: AppToastTone.error,
      );
    } finally {
      if (mounted) {
        _controller.state = _controller.state.copyWith(isAdding: false);
      }
    }
  }

  void _submitManualFromManualPane(
    LibraryAddTarget target,
    BuildContext? manualDialogContext,
  ) {
    unawaited(() async {
      final itemId = await _submitManual(target);
      if (itemId == null || !mounted) return;
      if (manualDialogContext == null) {
        _closeDialog(_addResult([itemId]));
        return;
      }
      if (manualDialogContext.mounted) {
        Navigator.of(manualDialogContext).pop();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _closeDialog(_addResult([itemId]));
      });
    }());
  }

  Future<String?> _submitManual(LibraryAddTarget target) async {
    if (_controller.state.isAdding) return null;
    final hasOwnedOnlyDetails = _manualDraft.customFieldValues.values
            .any((value) => value?.trim().isNotEmpty ?? false) ||
        _manualDraft.itemImages.isNotEmpty;
    if (target != LibraryAddTarget.owned && hasOwnedOnlyDetails) {
      showAppToast(
        context,
        'Custom fields and personal images are saved with an owned copy. '
        'Choose Add to Collection or clear those fields first.',
        tone: AppToastTone.error,
      );
      return null;
    }
    _controller.setTarget(target);
    _controller.clearSubmissionError();
    final capability = libraryAddForKind(widget.type.kind);
    final candidate = capability.buildManualCandidate(
      _manualDraft.kindDraft,
      title: _manualDraft.kindDraft.catalogTitle,
    );
    if (candidate == null) {
      _controller.reportSubmissionError(
        capability.manualCandidateValidationMessage,
      );
      return null;
    }
    final current = _controller.state.commonDraft;
    _controller.updateCommonDraft(
      (_) => LibraryAddCommonDraft(
        condition: current.condition ?? _controller.state.defaultCondition,
        purchaseDate:
            current.purchaseDate ?? _controller.state.defaultPurchaseDate,
        pricePaidCents: current.pricePaidCents,
        currency: current.currency,
        personalNotes: _textOrNull(
              _manualDraft.personalNotesController.text,
            ) ??
            current.personalNotes,
        quantity: current.quantity,
        tags: _textOrNull(_manualDraft.tagsController.text) ??
            _controller.state.defaultTags ??
            current.tags,
        locationId: current.locationId ?? _controller.state.defaultLocationId,
        purchaseStore: current.purchaseStore,
        collectionStatus: current.collectionStatus,
        isDigital: current.isDigital,
      ),
    );
    if (!mounted) return null;
    final success = await _controller.submitSelectedItem(
      candidate,
      onOwnedCopyCreated: target == LibraryAddTarget.owned
          ? (ownedRef) async {
              try {
                await _persistManualOwnedDetails(
                  ownedRef: ownedRef,
                  catalogRef: candidate.reference,
                );
              } catch (error) {
                if (mounted) {
                  showAppToast(
                    context,
                    'The item was added, but some personal details could not '
                    'be saved. $error',
                    tone: AppToastTone.error,
                  );
                }
              }
            }
          : null,
    );
    if (success && mounted) {
      await _persistManualVocabularyValues();
      return candidate.reference.id;
    }
    if (mounted) {
      final error = _controller.state.submitState.error;
      _controller.reportSubmissionError(
        error?.toString() ?? 'The item could not be added. Please try again.',
      );
    }
    return null;
  }

  void _applyManualImageEdits(List<ItemImageEdit> edits) {
    final existingById = {
      for (final image in _manualDraft.itemImages) image.id: image,
    };
    final now = DateTime.now().toUtc();
    _manualDraft.itemImages = [
      for (final edit in edits)
        if (!edit.deleted)
          if (edit.imageData ?? existingById[edit.id]?.imageData
              case final imageData?)
            ItemImage(
              id: edit.id,
              ownedRef: existingById[edit.id]?.ownedRef ??
                  OwnedCopyRef.fromKey(
                    '${widget.type.kind.apiValue}:draft:draft',
                  ),
              imageData: imageData,
              imageType: edit.imageType,
              caption: edit.caption,
              sortOrder: edit.sortOrder,
              createdAt:
                  edit.createdAt ?? existingById[edit.id]?.createdAt ?? now,
            ),
    ];
  }

  Future<void> _persistManualOwnedDetails({
    required OwnedCopyRef ownedRef,
    required CatalogEntityRef catalogRef,
  }) async {
    final now = DateTime.now().toUtc();
    final definitionsById = {
      for (final definition in _manualCustomFieldDefinitions)
        definition.id: definition,
    };
    final values = <CustomFieldValue>[];
    for (final entry in _manualDraft.customFieldValues.entries) {
      final definition = definitionsById[entry.key];
      if (definition == null) continue;
      final value = normalizeCustomFieldInputValue(definition, entry.value);
      if (value == null) continue;
      values.add(
        CustomFieldValue(
          id: const Uuid().v4(),
          targetId: ownedRef.key,
          targetScope: CustomFieldTargetScope.ownedCopy,
          catalogRef: catalogRef,
          fieldDefinitionId: definition.id,
          value: value,
          updatedAt: now,
        ),
      );
    }
    final db = ref.read(localDatabaseProvider);
    if (values.isNotEmpty) {
      await CustomFieldRepository(db).upsertValues(values);
    }
    final imageRepository = ItemImageRepository(db);
    for (final image in _manualDraft.itemImages) {
      await imageRepository.add(image.copyWith(ownedRef: ownedRef));
    }
  }

  Future<void> _openManualDialog(
    Color accent,
    LibraryAddCapability capability,
  ) async {
    if (_manualDialogOpen) return;
    if (!_hasOpenedManualDialog) {
      _manualDraft.kindDraft.catalogTitle = _queryController.text;
      _hasOpenedManualDialog = true;
    }
    _controller.dismissSuggestions();
    _manualDialogOpen = true;

    Widget buildManualDialog(BuildContext dialogContext) {
      return ValueListenableBuilder<LibraryAddSessionState>(
        valueListenable: _controller,
        builder: (context, state, _) => capability.buildManualPane(
          context,
          _buildManualPaneRequest(
            state,
            accent,
            manualDialogContext: dialogContext,
          ),
        ),
      );
    }

    try {
      if (AppWindowClass.of(context).isCompact) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (routeContext) => Scaffold(
              body: SafeArea(child: buildManualDialog(routeContext)),
            ),
          ),
        );
      } else {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: buildManualDialog,
        );
      }
    } finally {
      _manualDialogOpen = false;
    }
  }

  void _selectAddMode(LibraryAddDialogMode mode) {
    _controller.setMode(mode);
  }

  String? _textOrNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent ??
        LibraryAccentScope.accentOf(context,
            fallback: widget.type.identity.accent);
    final state = _controller.state;
    final ownedByCatalogRef = ref.watch(collectionByCatalogRefProvider);
    final isWideLayout = libraryUiPolicyForKind(widget.type.kind).wideDialog;
    final resultPolicy = libraryAddForKind(widget.type.kind).resultPolicy;
    final visibleCore = state.visibleCoreResults(
      resultPolicy,
      isOwnedCatalogItem: (item) =>
          ownedByCatalogRef.containsKey(item.reference),
    );
    final selectedItem = state.selectedItem;
    final checkedCoreCount = state.search.results
        .where((item) =>
            state.selection.checkedResultIds.contains(item.reference.id))
        .length;
    final checkedSelectionCount = checkedCoreCount;
    final hasCheckedSelection = checkedSelectionCount > 0;

    final addCapability = libraryAddForKind(widget.type.kind);
    final searchContext = LibraryAddSearchContext(
      query: state.search.query,
      identifierCode: state.search.identifierCode,
      advancedFilters: state.search.advancedFilters,
    );

    LibraryAddModeBarRequest buildModeBarRequest(
      List<LibraryAddAdvancedFilterField<String>> advancedFilterDescriptors,
    ) {
      return LibraryAddModeBarRequest(
        type: widget.type,
        accent: accent,
        isWideLayout: isWideLayout,
        mode: state.mode,
        queryController: _queryController,
        identifierController: _identifierController,
        isSearching: state.search.isSearching,
        onModeChanged: _selectAddMode,
        onSearch: () {
          _controller.dismissSuggestions();
          _controller.updateQuery(_queryController.text);
          _controller.executeSearch();
        },
        onQueryChanged: _controller.updateQuery,
        suggestions: state.search.suggestions,
        showSuggestions: state.search.showSuggestions,
        onSelectSuggestion: (item) {
          _queryController.text = item.summary.primaryLabel;
          _controller.selectSuggestion(item);
        },
        onDismissSuggestions: _controller.dismissSuggestions,
        canScanCover: libraryAddForKind(widget.type.kind).chrome.canScanCover,
        isScanningCover: state.search.isScanningCover,
        onScanCover: () => _controller.scanCover(context),
        onLookupIdentifier: () => _controller.lookupIdentifier(
          identifierCode: _identifierController.text,
        ),
        onManual: () => _openManualDialog(accent, addCapability),
        showAdvanced: state.search.showAdvancedSearch,
        onToggleAdvanced: _controller.toggleAdvancedSearch,
        advancedFilterState: state.search.advancedFilters,
        onAdvancedFilterChanged: _controller.updateAdvancedFilter,
        advancedFilterDescriptors: advancedFilterDescriptors,
        kindSpecificPaneBuilder:
            addCapability.search.presentation.controlsBuilder,
      );
    }

    final descriptorRequest = buildModeBarRequest(const []);
    final modeBarRequest = buildModeBarRequest(
      addCapability.search.input.advancedFilterDescriptorsBuilder(
        descriptorRequest,
      ),
    );

    final palette = appPalette(context);
    final dialogTheme = buildLibraryAddDialogTheme(accent, palette);

    return LibraryDialogScaffold(
      accent: accent,
      themeData: dialogTheme,
      width: _dialogWidth ?? LibraryAddDialogLayout.defaultDialogWidth,
      height: _dialogHeight ?? LibraryAddDialogLayout.defaultDialogHeight,
      minWidth: LibraryAddDialogLayout.minDialogWidth,
      maxWidth: LibraryAddDialogLayout.maxDialogWidth,
      minHeight: LibraryAddDialogLayout.minDialogHeight,
      maxHeight: LibraryAddDialogLayout.maxDialogHeight,
      onResizeWidth: (delta) => setState(() {
        _dialogWidth = LibraryAddDialogLayout.clampDialogWidth(
          (_dialogWidth ?? LibraryAddDialogLayout.defaultDialogWidth) + delta,
        );
      }),
      onResizeHeight: (delta) => setState(() {
        _dialogHeight = LibraryAddDialogLayout.clampDialogHeight(
          (_dialogHeight ?? LibraryAddDialogLayout.defaultDialogHeight) + delta,
        );
      }),
      header: AccentDialogHeader(
        title: 'Add ${widget.type.identity.pluralLabel}',
        icon: widget.type.identity.icon,
        onClose: _closeDialog,
      ),
      contextBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.initialIdentifier != null &&
              widget.initialIdentifier!.trim().isNotEmpty &&
              state.mode == LibraryAddDialogMode.identifier)
            LibraryAddIdentifierPrefillBanner(
              type: widget.type,
              identifierCode: widget.initialIdentifier!.trim(),
            ),
          Builder(
            builder: (scopedContext) => LibraryAddModeBar(
              type: widget.type,
              accent: accent,
              isWideLayout: isWideLayout,
              mode: state.mode,
              queryController: _queryController,
              identifierController: _identifierController,
              isSearching: state.search.isBusy,
              onModeChanged: _selectAddMode,
              onSearch: () {
                _controller.dismissSuggestions();
                _controller.updateQuery(_queryController.text);
                _controller.executeSearch();
              },
              onQueryChanged: _controller.updateQuery,
              suggestions: state.search.suggestions,
              showSuggestions: state.search.showSuggestions,
              onSelectSuggestion: (item) {
                _queryController.text = item.summary.primaryLabel;
                _controller.selectSuggestion(item);
              },
              onDismissSuggestions: _controller.dismissSuggestions,
              canScanCover:
                  libraryAddForKind(widget.type.kind).chrome.canScanCover,
              isScanningCover: state.search.isScanningCover,
              onScanCover: () => _controller.scanCover(scopedContext),
              onLookupIdentifier: () => _controller.lookupIdentifier(
                identifierCode: _identifierController.text,
              ),
              onManual: () => _openManualDialog(accent, addCapability),
              showAdvanced: state.search.showAdvancedSearch,
              onToggleAdvanced: _controller.toggleAdvancedSearch,
              advancedFilterState: state.search.advancedFilters,
              onAdvancedFilterChanged: _controller.updateAdvancedFilter,
              advancedFilterDescriptors:
                  modeBarRequest.advancedFilterDescriptors,
              kindSpecificPaneBuilder: modeBarRequest.kindSpecificPaneBuilder,
            ),
          ),
          if (state.search.error != null)
            Material(
              color: palette.panel,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.search.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: switch (state.mode) {
        LibraryAddDialogMode.search ||
        LibraryAddDialogMode.identifier =>
          LayoutBuilder(
            builder: (context, constraints) {
              final searchPaneWidget = LibraryAddSearchPane(
                type: widget.type,
                isBusy: state.search.isBusy,
                isLoadingMoreResults: state.search.isLoadingMoreResults,
                hasMoreResults: state.search.hasMoreResults,
                loadMoreError: state.search.loadMoreError,
                onLoadMoreResults: _controller.loadMoreResults,
                error: state.search.error,
                accent: accent,
                results: visibleCore,
                selectedResultId: state.selection.selectedResultId,
                checkedResultIds: state.selection.checkedResultIds,
                ownedCatalogRefs: ownedByCatalogRef.keys.toSet(),
                coreMatchSummary: (item) => addCapability.search.presentation
                    .coreMatchSummary(item, searchContext),
                resultPolicy: resultPolicy,
                resultPolicyState: state.selection.resultPolicyState,
                onResultPolicyOptionChanged: _controller.setResultPolicyOption,
                onSelectResult: _controller.selectResult,
                onToggleResultCheck: _controller.toggleCheckedResult,
              );

              final previewPaneWidget = LibraryAddPreviewPane(
                type: widget.type,
                accent: accent,
                isWideLayout: isWideLayout,
                previewPaneBuilder: addCapability.previewPaneBuilder,
                item: selectedItem,
                isFetchingPreview: selectedItem != null &&
                    state.preview.pendingHydratedResultRefs
                        .contains(selectedItem.reference),
                searched: state.search.results.isNotEmpty,
              );

              if (constraints.maxWidth < 720) {
                final searchHeight = constraints.maxHeight > 400
                    ? 300.0
                    : constraints.maxHeight * 0.5;
                return Column(
                  children: [
                    SizedBox(
                      height: searchHeight,
                      child: searchPaneWidget,
                    ),
                    Expanded(child: previewPaneWidget),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: _clampedResultsPaneWidth(constraints.maxWidth),
                    child: searchPaneWidget,
                  ),
                  LibraryAddPaneResizeDivider(
                    onDragDelta: (delta) => _resizeResultsPane(
                      delta,
                      constraints.maxWidth,
                    ),
                  ),
                  Expanded(child: previewPaneWidget),
                ],
              );
            },
          ),
      },
      footer: () {
        final bottomBarRequest = LibraryAddBottomBarRequest(
          type: widget.type,
          conditions: _conditionOptions,
          defaultTags: state.defaultTags,
          accent: accent,
          selectedItem: selectedItem,
          addTarget: state.target,
          addCount: checkedSelectionCount > 0 ? checkedSelectionCount : 1,
          hasCheckedSelection: hasCheckedSelection,
          isAdding: state.isAdding || state.submitState.isLoading,
          defaultCondition: state.defaultCondition,
          defaultLocationLabel:
              locationPathForId(_availableLocations, state.defaultLocationId),
          defaultPurchaseDate: state.defaultPurchaseDate,
          onAddTargetChanged: _controller.setTarget,
          onDefaultConditionChanged: _controller.setDefaultCondition,
          onEditDefaultTagsPressed: _showDefaultTagsEditor,
          onDefaultLocationPressed: _pickDefaultLocation,
          onDefaultPurchaseDateChanged: _controller.setDefaultPurchaseDate,
          onAdd: () async {
            final success = await _controller.submitCurrentSelection();
            if (success && mounted) {
              _closeDialog(_addResult(_currentSubmissionItemIds()));
            }
          },
          isWideLayout: isWideLayout,
        );
        return LibraryAddBottomBar(
          request: bottomBarRequest,
        );
      }(),
    );
  }
}
