import 'package:collectarr_app/features/library/edit/sections/library_entry_personal_section.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_external_links_edit_session.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_personal_field_registry.dart';
import 'dart:async';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_target_option.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_money_amount_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_notes_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_personal_fields_layout.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/pick_lists/vocabulary_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';

class LibraryEditRenderer extends ConsumerStatefulWidget {
  const LibraryEditRenderer({
    super.key,
    required this.type,
    required this.kindItem,
    required this.libraryEntry,
    this.libraryEntryDispatch,
    this.wishlistItem,
    this.trackingSummary,
    required this.accent,
    this.wishlistTargetOptions = const [],
    this.physicalFormats = const [],
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
    this.onPrevious,
    this.onNext,
    this.target,
  })  : request = null,
        isEntryTarget = target is EntryTargetRef || libraryEntry != null;

  LibraryEditRenderer.fromRequest({
    super.key,
    required LibraryEditDialogRequest request,
  })  : request = request,
        target = request.target,
        type = request.type,
        kindItem = request.kindItem,
        libraryEntry = request.libraryEntry,
        libraryEntryDispatch = request.libraryEntryDispatch,
        wishlistItem = request.wishlistItem,
        trackingSummary = request.trackingSummary,
        accent = request.accent,
        wishlistTargetOptions = request.wishlistTargetOptions,
        physicalFormats = request.physicalFormats,
        customFieldDefinitions = request.customFieldDefinitions,
        customFieldValues = request.customFieldValues,
        itemImages = request.itemImages,
        onPrevious = request.onPrevious,
        onNext = request.onNext,
        isEntryTarget = request.isLibraryEntry;

  final LibraryKindRegistration type;

  /// Concrete candidate retained only for kind-entry draft/custom boundaries.
  final CatalogSearchCandidate kindItem;
  final LibraryEntrySummary? libraryEntry;

  /// Concrete kind-entry aggregate passed through the typed edit boundary.
  final LibraryEntryDispatch? libraryEntryDispatch;
  final WishlistItem? wishlistItem;
  final TrackingSummary? trackingSummary;
  final Color accent;
  final List<CatalogTargetOption> wishlistTargetOptions;
  final List<PhysicalMediaFormat> physicalFormats;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryTargetRef? target;
  final bool isEntryTarget;
  final LibraryEditDialogRequest? request;

  @override
  ConsumerState<LibraryEditRenderer> createState() =>
      _LibraryEditRendererState();
}

class _LinkEntry {
  _LinkEntry({
    required this.urlController,
    required this.descriptionController,
  });

  final TextEditingController urlController;
  final TextEditingController descriptionController;

  void dispose() {
    urlController.dispose();
    descriptionController.dispose();
  }
}

class _LibraryEditRendererState extends ConsumerState<LibraryEditRenderer>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final LibraryEditShellState _draft;
  late final TabController _tabController;
  late List<LibraryEditTabSpec> _tabSpecs;
  late final List<_LinkEntry> _links;
  bool _linksEdited = false;
  bool _isSaving = false;

  bool get _isEntry => _draft.isEntry;

  LibraryEditPresentationCapability get _editCapability =>
      libraryEditPresentationForKind(widget.type.kind);

  LibraryEditPresentationContext get _editPresentationContext =>
      LibraryEditPresentationContext(
        isEntry: _isEntry,
        isTrackingOnly: _draft.isTrackingOnly,
        hasTrackingContext: _draft.hasTrackingContext,
        hasWishlistContext: _draft.hasWishlistContext,
        isDigitalFormat: _draft.isDigitalFormat,
        hasPhysicalFormats: widget.physicalFormats.isNotEmpty,
        hasCustomFields: widget.customFieldDefinitions.isNotEmpty,
      );

  @override
  void initState() {
    super.initState();
    final request = widget.request;
    _draft = request != null
        ? LibraryEditShellState.fromRequest(request)
        : LibraryEditShellState.fromItem(
            type: widget.type,
            target: widget.target,
            item: widget.kindItem,
            libraryEntry: widget.libraryEntry,
            libraryEntryDispatch: widget.libraryEntryDispatch,
            wishlistItem: widget.wishlistItem,
            trackingSummary: widget.trackingSummary,
            accent: widget.accent,
            wishlistTargetOptions: widget.wishlistTargetOptions,
            physicalFormats: widget.physicalFormats,
            customFieldDefinitions: widget.customFieldDefinitions,
            customFieldValues: widget.customFieldValues,
            itemImages: widget.itemImages,
          );

    _links = [];

    _tabSpecs = libraryEditPresentationForKind(widget.type.kind)
        .presentation
        .builderForTarget(widget.isEntryTarget)
        .buildTabs(context: _editPresentationContext);

    _tabController = TabController(
      length: _tabSpecs.length,
      vsync: this,
    );

    _loadEditOptions();
  }

  Future<void> _loadEditOptions() async {
    final db = ref.read(localDatabaseProvider);
    final mediaKind = widget.type.kind.apiValue;
    final libraryEntryRef =
        _draft.libraryEntry?.ref ?? _draft.libraryEntryDispatch?.ref;
    final entrySession = _draft.session.entrySession;
    if (libraryEntryRef != null &&
        entrySession is LibraryEntryExternalLinksSource) {
      final linksSource = entrySession as LibraryEntryExternalLinksSource;
      await _draft.userExternalLinks.load(
        db,
        libraryEntryRef,
        legacyManualLinks: linksSource.legacyManualExternalLinks,
      );
    }
    final locations = await LocationRepository(db).getAll();
    final owners = await loadSingleValuePickListOptions(
      db,
      listName: UniversalVocabularies.owners.key,
      mediaKind: mediaKind,
      selectedValue: _draft.personal.ownerLabelController.text,
    );
    final purchaseStores = await loadSingleValuePickListOptions(
      db,
      listName: UniversalVocabularies.purchaseStore.key,
      mediaKind: mediaKind,
      selectedValue: _draft.personal.purchaseStoreController.text,
    );
    final tags = await loadTagPickListOptions(
      db,
      mediaKind: mediaKind,
      selectedTags: splitPickListValues(_draft.personal.tagsController.text),
    );
    final kindVocabs = <String, List<String>>{};
    final vocCapability = _editCapability.vocabularies;
    if (vocCapability != null) {
      final repo = DatabaseVocabularyRepository(db);
      for (final def in vocCapability.definitions) {
        final options = await repo.loadOptions(
          mediaKind: mediaKind,
          definition: def,
        );
        kindVocabs[def.key] = options;
      }
    }

    if (mounted) {
      setState(() {
        _draft.personal.availableLocations = locations;
        _draft.locationOptions = locations.map((l) => l.name).toList();
        _draft.ownerOptions = owners;
        _draft.purchaseStoreOptions = purchaseStores;
        _draft.tagOptions = tags;
        _draft.kindVocabularies = kindVocabs;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final link in _links) {
      link.dispose();
    }
    _draft.dispose();
    super.dispose();
  }

  void _markDirty() {
    _draft.markDirty();
    if (mounted) setState(() {});
  }

  Future<void> _submit(LibraryEditSubmitAction action) async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() == false) return;
    setState(() => _isSaving = true);
    try {
      if (_linksEdited) {
        final updatedLinks = <TrailerLinkDto>[
          for (final l in _links)
            if (l.urlController.text.trim().isNotEmpty)
              TrailerLinkDto(
                url: l.urlController.text.trim(),
                title: emptyToNull(l.descriptionController.text.trim()),
                description: emptyToNull(l.descriptionController.text.trim()),
                source: 'manual',
                isAutomatic: false,
                kind: 'external',
              ),
        ];
        _draft.session.setExternalLinks(updatedLinks);
      }
      final selection = _draft.session.save(
        _draft,
        submitAction: action,
      );
      final prepared = selection.copyWith(
        localChanges: [
          ...selection.localChanges,
          if (!_draft.pendingVocabularyValues.isEmpty)
            _draft.pendingVocabularyValues.toEditChange(
              defaultMediaKind: widget.type.kind.apiValue,
            ),
        ],
      );
      await commitLibraryEdit(context, prepared);
      // Keep the draft dirty if the persistence transaction fails.
      _draft.markClean();
    } catch (error, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save changes: $error')),
        );
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'collectarr_app',
          context: ErrorDescription('while saving a library entry'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _proposeToCore() async {
    if (_formKey.currentState?.validate() == false) return;
    final proposed = _draft.session.buildCorrectionSelection(_draft);
    final request = LibraryEditDialogRequest(
      type: widget.type,
      item: _draft.kindItem,
      target: _draft.target,
      libraryEntry: _draft.libraryEntry,
      libraryEntryDispatch: _draft.libraryEntryDispatch,
      accent: widget.accent,
    );
    final sent = await showLibraryCoreCorrectionReview(
      context: context,
      source: LibraryCoreCorrectionSource.fromTypedFields(
        request: request,
        coreCatalogRef: coreCatalogRefForEditRequest(request),
        originalFields: {
          ..._draft.kindItem.kindCapability.mapTransport(
            (item) => item.kindData,
          ),
        },
        proposedFields: {
          ...proposed.kindItem.kindCapability.mapTransport(
            (item) => item.kindData,
          ),
        },
      ),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposal sent to Core.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = libraryEditPresentationForKind(widget.type.kind)
        .presentation
        .builderForTarget(widget.isEntryTarget)
        .buildDialogTitle(
          kindItem: widget.kindItem,
        );

    return LibraryEditDialogScaffold(
      formKey: _formKey,
      footerContent: LibraryEntryEditScope.maybeOf(context) == null
          ? null
          : LibraryEntryStatusStrip(
              draft: LibraryEntryEditScope.maybeOf(context)!),
      accent: widget.accent,
      isBusy: _isSaving,
      icon: widget.type.identity.icon,
      title: title,
      badges: const <Widget>[],
      tabController: _tabController,
      tabs: [
        for (final tab in _tabSpecs) EditTab(icon: tab.icon, label: tab.label)
      ],
      tabIds: [for (final tab in _tabSpecs) tab.id],
      views: _tabViews(),
      onClose: () => Navigator.of(context).pop(),
      onCancel: () => Navigator.of(context).pop(),
      onSave: _isSaving
          ? null
          : () => unawaited(_submit(LibraryEditSubmitAction.save)),
      onProposeToCore: _isSaving ||
              (LibraryEntryEditScope.maybeOf(context)
                          ?.record
                          .sourceCatalogRef ==
                      null &&
                  LibraryEntryEditScope.maybeOf(context) != null)
          ? null
          : () => unawaited(_proposeToCore()),
      onPrevious: _isSaving ? null : widget.onPrevious,
      onNext: _isSaving ? null : widget.onNext,
      tabOrderKey:
          'library_edit_tabs_${widget.type.kind.apiValue}_${widget.isEntryTarget ? 'entry' : 'catalog'}',
    );
  }

  static String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String _personalFieldLabel(String key) {
    final field = personalFieldContributorFor(widget.type.kind)
        .fields
        .where((candidate) => candidate.key == key)
        .firstOrNull;
    if (field == null) {
      throw StateError(
        'The ${widget.type.kind.apiValue} kind has no personal field "$key".',
      );
    }
    return field.label;
  }

  List<String> _kindVocabularyOptions({
    required String suffix,
    required List<String> fallback,
  }) {
    final vocabularies = _editCapability.vocabularies;
    if (vocabularies == null) return fallback;
    for (final definition in vocabularies.definitions) {
      if (definition.key.endsWith('.$suffix')) {
        return _draft.kindVocabularies[definition.key] ?? fallback;
      }
    }
    return fallback;
  }

  Widget _buildPersonalVocabularyField({
    required String suffix,
    required String label,
    required TextEditingController controller,
    required List<String> fallback,
  }) {
    final definition =
        _editCapability.vocabularies?.definitionForSuffix(suffix);
    final options = _kindVocabularyOptions(
      suffix: suffix,
      fallback: fallback,
    );
    return LibraryDropdownPickField<String>(
      label: label,
      value: controller.text.trim().isEmpty ? null : controller.text.trim(),
      options: [
        for (final option in options)
          LibraryFieldOption<String>(value: option, label: option),
      ],
      allowCustomValue: definition?.allowCustomValues ?? true,
      openPicker: ({required label, required selectedValue, required options}) {
        final db = ref.read(localDatabaseProvider);
        return showPickListSelectDialog(
          context: context,
          label: label,
          options: options,
          selectedValue: selectedValue,
          listName: definition?.key,
          mediaKind: widget.type.kind.apiValue,
          allowUserValues: definition?.allowCustomValues ?? true,
          db: definition == null ? null : db,
        );
      },
      onChanged: (value) {
        controller.text = value ?? '';
        _draft.recordPendingVocabularyValue(
          fieldId: '${definition?.key}:${identityHashCode(controller)}',
          listName: definition?.key,
          value: value,
          options: options,
          allowCustomValues: definition?.allowCustomValues ?? false,
          mediaKind: widget.type.kind.apiValue,
        );
        _markDirty();
      },
    );
  }

  Widget _buildUniversalVocabularyField({
    required String listName,
    required String label,
    required TextEditingController controller,
    required List<String> options,
  }) {
    return LibraryDropdownPickField<String>(
      label: label,
      value: controller.text.trim().isEmpty ? null : controller.text.trim(),
      options: [
        for (final option in options)
          LibraryFieldOption<String>(value: option, label: option),
      ],
      allowCustomValue: true,
      openPicker: ({required label, required selectedValue, required options}) {
        final db = ref.read(localDatabaseProvider);
        return showPickListSelectDialog(
          context: context,
          label: label,
          options: options,
          selectedValue: selectedValue,
          listName: listName,
          mediaKind: widget.type.kind.apiValue,
          allowUserValues: true,
          db: db,
        );
      },
      onChanged: (value) {
        controller.text = value ?? '';
        _draft.recordPendingVocabularyValue(
          fieldId: listName,
          listName: listName,
          value: value,
          options: options,
          allowCustomValues: true,
          mediaKind: widget.type.kind.apiValue,
        );
        _markDirty();
      },
    );
  }

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  Widget _tabViewFor(String id) {
    final customView = libraryEditPresentationForKind(widget.type.kind)
        .presentation
        .builderForTarget(widget.isEntryTarget)
        .buildCustomTabView(
          tabId: id,
          context: context,
          draft: _draft,
          accent: widget.accent,
          item: widget.kindItem,
          markDirty: _markDirty,
        );
    if (customView != null) {
      return customView;
    }

    return switch (id) {
      'details' => _detailsTab(),
      'main' => _mainTab(),
      'media' => _genericMediaTab(),
      'value' => _valueTab(),
      'personal' => _personalTab(),
      'read_history' || 'tracking' => _trackingTab(),
      'sold' => _soldTab(),
      'custom' => _customFieldsTab(),
      'photos' => _photosTab(),
      'cover' => _coverTab(),
      'synopsis' => _synopsisTab(),
      'links' => _linksTab(),
      _ => EditTabShell(
          children: [
            EditSectionStateMessage(
              icon: Icons.info_outline,
              message: 'Section $id',
            ),
          ],
        ),
    };
  }

  Widget _mainTab() {
    final fields = _draft.canonicalFormSchema.fieldsFor(
      LibraryEditFormSection.details,
    );
    if (fields.isEmpty) return const EditTabShell(children: []);
    final rows = <Widget>[];
    for (var index = 0; index < fields.length; index += 2) {
      if (index > 0) rows.add(const SizedBox(height: 10));
      rows.add(
        LibraryEditResponsiveRow(
          children: fields
              .skip(index)
              .take(2)
              .map(_canonicalField)
              .toList(growable: false),
        ),
      );
    }
    return EditTabShell(
      children: [
        EditSection(
          title: _draft.canonicalFormSchema.titleFor(
            LibraryEditFormSection.details,
          ),
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          ),
        ),
      ],
    );
  }

  Widget _canonicalField(LibraryEditFormFieldSpec field) =>
      LibraryEditTextField(
        key: ValueKey('library-edit-${field.id}'),
        controller: field.controller,
        label: field.label,
        validator: field.required ? _requiredValidator : null,
        maxLines: field.maxLines,
      );

  Widget _detailsTab() => _mainTab();

  Widget _genericMediaTab() => _mainTab();

  Widget _linksTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Links',
          accent: widget.accent,
          child: LibraryExternalLinksTable<_LinkEntry>(
            rows: [
              for (var index = 0; index < _links.length; index++)
                LibraryExternalLinkEditRow<_LinkEntry>(
                  identity: _links[index],
                  urlController: _links[index].urlController,
                  descriptionController: _links[index].descriptionController,
                  urlFieldKey: ValueKey('bookExternalLinkUrlField_$index'),
                  descriptionFieldKey:
                      ValueKey('bookExternalLinkDescriptionField_$index'),
                ),
            ],
            accent: widget.accent,
            addLabel: 'Add Link',
            emptyMessage: 'No links added.',
            onAdd: () {
              _linksEdited = true;
              setState(
                () => _links.add(
                  _LinkEntry(
                    urlController: TextEditingController(),
                    descriptionController: TextEditingController(),
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              _linksEdited = true;
              setState(() {
                final link = _links.removeAt(oldIndex);
                _links.insert(newIndex, link);
              });
            },
            onRemoveSelected: (selectedRows) {
              _linksEdited = true;
              setState(() {
                for (final row in selectedRows) {
                  final link = row.identity;
                  if (_links.remove(link)) link.dispose();
                }
              });
            },
            onChanged: () => _linksEdited = true,
          ),
        ),
      ],
    );
  }

  Widget _personalTab() {
    if (_draft.hasWishlistContext) {
      final wishlistRef = _draft.personal.selectedWishlistCatalogRef;
      final targetOptions = widget.wishlistTargetOptions;
      CatalogTargetOption? selectedTarget;
      for (final option in targetOptions) {
        if (option.ref == wishlistRef) {
          selectedTarget = option;
          break;
        }
      }
      selectedTarget ??= targetOptions.firstOrNull;
      return EditTabShell(
        children: [
          EditSection(
            title: 'Wishlist Reference',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (targetOptions.isNotEmpty) ...[
                  LibraryDropdownPickField<CatalogTargetOption>(
                    key: const Key('library-edit-wishlist-target-field'),
                    label: 'Wishlist target',
                    value: selectedTarget,
                    options: [
                      for (final option in targetOptions)
                        LibraryFieldOption<CatalogTargetOption>(
                          value: option,
                          label: option.label,
                        ),
                    ],
                    openPicker: (
                            {required label,
                            required selectedValue,
                            required options}) =>
                        showPickListSelectDialog(
                      context: context,
                      label: label,
                      options: options,
                      selectedValue: selectedValue,
                    ),
                    onChanged: (option) {
                      if (option == null) return;
                      setState(() {
                        _draft.personal.selectedWishlistCatalogRef = option.ref;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                LibraryEditResponsiveRow(children: [
                  LibraryEditTextField(
                    controller: _draft.personal.wishlistPriceController,
                    label: 'Target price',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  LibraryDropdownPickField<String>(
                    label: 'Currency',
                    value:
                        _draft.personal.wishlistCurrencyController.text.isEmpty
                            ? 'USD'
                            : _draft.personal.wishlistCurrencyController.text,
                    options: const [
                      LibraryFieldOption(value: 'USD', label: 'USD'),
                      LibraryFieldOption(value: 'EUR', label: 'EUR'),
                      LibraryFieldOption(value: 'GBP', label: 'GBP'),
                      LibraryFieldOption(value: 'RON', label: 'RON'),
                      LibraryFieldOption(value: 'JPY', label: 'JPY'),
                    ],
                    openPicker: (
                            {required label,
                            required selectedValue,
                            required options}) =>
                        showPickListSelectDialog(
                      context: context,
                      label: label,
                      options: options,
                      selectedValue: selectedValue,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _draft.personal.wishlistCurrencyController.text =
                            val ?? 'USD';
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 10),
                LibraryTextFormControl(
                  controller: _draft.personal.wishlistNotesController,
                  decoration:
                      const InputDecoration(labelText: 'Wishlist notes'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final fields = <Widget>[];
    final fullWidthFields = <Widget>[];
    if (_draft.isDigitalFormat) {
      fullWidthFields.add(
        Text(
          'Digital items do not expose physical storage fields.',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
      fullWidthFields.add(_buildLocationPickerField());
    } else {
      fields.addAll([
        _buildPersonalVocabularyField(
          suffix: 'condition',
          label: _personalFieldLabel('condition'),
          controller: _draft.personal.conditionController,
          fallback: _editCapability.conditions,
        ),
        _buildPersonalVocabularyField(
          suffix: 'grade',
          label: _personalFieldLabel('grade'),
          controller: _draft.personal.gradeController,
          fallback: _editCapability.collectionValueOptions,
        ),
        _buildLocationPickerField(),
        _buildUniversalVocabularyField(
          listName: UniversalVocabularies.owners.key,
          label: _personalFieldLabel('owner_label'),
          controller: _draft.personal.ownerLabelController,
          options: _draft.ownerOptions,
        ),
      ]);
    }
    fullWidthFields.addAll([
      LibraryVocabularyField(
        controller: _draft.personal.tagsController,
        options: _draft.tagOptions,
        label: _personalFieldLabel('tags'),
        multiSelect: true,
        onChanged: (_) => _markDirty(),
      ),
      LibraryNotesField(
        label: _personalFieldLabel('personal_notes'),
        controller: _draft.personal.notesController,
        onChanged: (_) => _markDirty(),
      ),
    ]);
    return EditTabShell(
      children: [
        EditSection(
          title: 'Personal',
          accent: widget.accent,
          child: LibraryPersonalFieldsLayout(
            fields: fields,
            fullWidthFields: fullWidthFields,
          ),
        ),
      ],
    );
  }

  Widget _valueTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Purchase & Value',
          accent: widget.accent,
          child: LibraryPersonalFieldsLayout(
            fields: [
              LibraryMoneyAmountField(
                label: _personalFieldLabel('price_paid_cents'),
                amountMinorUnits: parseMoneyCents(
                  _draft.personal.priceController.text,
                ),
                currency: _draft.personal.currencyController.text,
                controller: _draft.personal.priceController,
                onChanged: (_) => _markDirty(),
              ),
              LibraryCurrencyField(
                controller: _draft.personal.currencyController,
                onChanged: (_) => _markDirty(),
              ),
              LibraryMoneyAmountField(
                label: _personalFieldLabel('market_value_cents'),
                amountMinorUnits: parseMoneyCents(
                  _draft.personal.marketValueController.text,
                ),
                currency: _draft.personal.currencyController.text,
                controller: _draft.personal.marketValueController,
                onChanged: (_) => _markDirty(),
              ),
              _buildUniversalVocabularyField(
                listName: UniversalVocabularies.purchaseStore.key,
                controller: _draft.personal.purchaseStoreController,
                label: _personalFieldLabel('purchase_store'),
                options: _draft.purchaseStoreOptions,
              ),
              LibraryDateFieldButton(
                label: _personalFieldLabel('purchase_date'),
                value: _draft.personal.purchaseDateController.text.isEmpty
                    ? null
                    : DateTime.tryParse(
                        _draft.personal.purchaseDateController.text),
                onChanged: (date) {
                  _draft.personal.purchaseDateController.text =
                      date?.toIso8601String().split('T').first ?? '';
                  _markDirty();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _soldTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Sold Details',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.personal.sellPriceController,
                  label: _personalFieldLabel('sell_price_cents'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                LibraryEditTextField(
                  controller: _draft.personal.soldToController,
                  label: _personalFieldLabel('sold_to'),
                ),
              ]),
              const SizedBox(height: 10),
              LibraryDateFieldButton(
                label: _personalFieldLabel('sold_at'),
                value: _draft.personal.soldAt,
                onChanged: (date) =>
                    setState(() => _draft.personal.soldAt = date),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _trackingTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Tracking',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditResponsiveRow(children: [
                MediaTrackingStatusField(
                  label: _personalFieldLabel('read_status'),
                  value: _draft.tracking.trackingController.text.isEmpty
                      ? null
                      : _draft.tracking.trackingController.text,
                  profile: libraryTrackingProfileForKind(widget.type.kind),
                  onChanged: (val) {
                    _draft.tracking.trackingController.text = val ?? '';
                    _markDirty();
                  },
                ),
                MediaRatingField(
                  controller: _draft.tracking.ratingController,
                  label: _personalFieldLabel('rating'),
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditTextField(
                controller: _draft.tracking.trackingNotesController,
                label: _personalFieldLabel('notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customFieldsTab() {
    return EditTabShell(
      children: [
        CustomFieldsEditSection(
          definitions: _draft.customFieldDefinitions,
          values: _draft.customFieldEdits,
          accent: widget.accent,
          mediaKind: widget.type.kind.apiValue,
          onChanged: (vals) {
            _draft.customFieldEdits = vals;
            _markDirty();
          },
          onCustomValueChanged: (fieldId, value) {
            final definition = _draft.customFieldDefinitions
                .where((item) => item.id == fieldId)
                .firstOrNull;
            _draft.recordPendingVocabularyValue(
              fieldId: 'customField:$fieldId',
              listName: 'customField:$fieldId',
              value: value,
              options: definition?.optionValues ?? const [],
              allowCustomValues: true,
              mediaKind: definition?.mediaKind ?? widget.type.kind.apiValue,
            );
          },
        ),
      ],
    );
  }

  Widget _photosTab() {
    return EditTabShell(
      children: [
        ItemImagesEditSection(
          images: _draft.itemImages,
          accent: widget.accent,
          onChanged: (edits) {
            _draft.itemImageEdits = edits;
            _markDirty();
          },
        ),
      ],
    );
  }

  Widget _coverTab() {
    return _canonicalFormTab(
      section: LibraryEditFormSection.artwork,
    );
  }

  Widget _synopsisTab() {
    return _canonicalFormTab(
      section: LibraryEditFormSection.description,
    );
  }

  Widget _canonicalFormTab({
    required LibraryEditFormSection section,
  }) {
    final fields = _draft.canonicalFormSchema.fieldsFor(section);
    return EditTabShell(
      children: [
        if (fields.isNotEmpty)
          EditSection(
            title: _draft.canonicalFormSchema.titleFor(section),
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < fields.length; index++) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _canonicalField(fields[index]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocationPickerField() {
    return InkWell(
      mouseCursor: WidgetStateMouseCursor.clickable,
      onTap: () async {
        final db = ref.read(localDatabaseProvider);
        final locationId = await showLocationPickerDialog(
          context: context,
          db: db,
          currentLocationId: _draft.personal.selectedLocationId,
        );
        if (locationId != null) {
          setState(() {
            _draft.personal.selectedLocationId = locationId;
            _draft.personal.locationChanged = true;
          });
        }
      },
      child: LibraryFormField(
        label: _personalFieldLabel('location_id'),
        child: InputDecorator(
          decoration: const InputDecoration(
            constraints: BoxConstraints(minHeight: kLibraryFormControlHeight),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            prefixIcon: Icon(Icons.place),
          ),
          child: Text(
            _draft.personal.selectedLocationPath ?? 'Pick location...',
            style: TextStyle(
              color: _draft.personal.selectedLocationPath != null
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).hintColor,
            ),
          ),
        ),
      ),
    );
  }
}
