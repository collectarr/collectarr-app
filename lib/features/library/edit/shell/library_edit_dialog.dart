import 'dart:async';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:collectarr_app/features/library/edit/vocabulary/library_edit_vocabulary_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/library/edit/library_edit_models.dart';

class LibraryEditRenderer extends ConsumerStatefulWidget {
  const LibraryEditRenderer({
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
    this.onPrevious,
    this.onNext,
    this.scope = LibraryEditScope.all,
  }) : draft = null;

  LibraryEditRenderer.fromDraft({
    super.key,
    required LibraryEditDraft draft,
    this.onPrevious,
    this.onNext,
    this.scope = LibraryEditScope.all,
  })  : draft = draft,
        type = draft.type,
        item = draft.item,
        ownedItem = draft.ownedItem,
        wishlistItem = draft.wishlistItem,
        trackingEntry = draft.trackingEntry,
        accent = draft.accent,
        availableBundleReleases = draft.availableBundleReleases,
        physicalFormats = draft.physicalFormats,
        customFieldDefinitions = draft.customFieldDefinitions,
        customFieldValues = draft.customFieldValues,
        itemImages = draft.itemImages;

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
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditScope scope;
  final LibraryEditDraft? draft;

  @override
  ConsumerState<LibraryEditRenderer> createState() =>
      _LibraryEditRendererState();
}

class _LinkEntry {
  _LinkEntry({
    required this.urlController,
    required this.descriptionController,
    this.original,
  });

  final TextEditingController urlController;
  final TextEditingController descriptionController;
  final TrailerLinkDto? original;

  void dispose() {
    urlController.dispose();
    descriptionController.dispose();
  }
}

class _LibraryEditRendererState extends ConsumerState<LibraryEditRenderer>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final LibraryEditDraft _draft;
  late final TabController _tabController;
  late List<LibraryEditTabSpec> _tabSpecs;
  late final List<_LinkEntry> _links;

  bool get _isOwned => _draft.isOwned;

  LibraryEditPresentationContext get _editPresentationContext =>
      LibraryEditPresentationContext(
        isOwned: _isOwned,
        isTrackingOnly: _draft.isTrackingOnly,
        hasTrackingContext: _draft.hasTrackingContext,
        hasWishlistContext: _draft.hasWishlistContext,
        isDigitalFormat: _draft.isDigitalFormat,
        hasPhysicalFormats: widget.physicalFormats.isNotEmpty,
        hasEditionAnchors: false,
        hasBundleReleaseAnchors: widget.availableBundleReleases.isNotEmpty,
        hasCustomFields: widget.customFieldDefinitions.isNotEmpty,
        scope: widget.scope,
      );

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ??
        LibraryEditDraft.fromItem(
          type: widget.type,
          item: widget.item,
          ownedItem: widget.ownedItem,
          wishlistItem: widget.wishlistItem,
          trackingEntry: widget.trackingEntry,
          accent: widget.accent,
          availableBundleReleases: widget.availableBundleReleases,
          physicalFormats: widget.physicalFormats,
          customFieldDefinitions: widget.customFieldDefinitions,
          customFieldValues: widget.customFieldValues,
          itemImages: widget.itemImages,
        );

    final initialLinks = widget.item.trailerUrls;
    _links = [
      for (final link in initialLinks)
        _LinkEntry(
          urlController: TextEditingController(text: link.url),
          descriptionController:
              TextEditingController(text: link.title ?? link.description ?? ''),
          original: link,
        ),
    ];

    _tabSpecs = libraryKindRuntimeForType(widget.type)
        .edit
        .presentation
        .builderForScope(widget.scope)
        .buildTabs(context: _editPresentationContext);

    _tabController = TabController(
      length: _tabSpecs.length,
      vsync: this,
    );

    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    final db = ref.read(localDatabaseProvider);
    final vocab =
        await const LibraryEditVocabularyController().loadVocabularyOptions(
      LibraryEditVocabularyRequest(
        db: db,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedPublisher: '',
        selectedImprint: null,
        selectedSeriesGroup: null,
        selectedPhysicalFormat: '',
        selectedCondition: _draft.personal.conditionController.text,
        selectedGrade: _draft.personal.gradeController.text,
        selectedCountry: '',
        selectedLanguage: '',
        selectedAgeRating: null,
        selectedAudienceRating: null,
        selectedRegion: null,
        selectedPackaging: null,
        selectedDistributor: null,
        selectedScreenRatio: null,
        selectedAudioTracks: null,
        selectedSubtitles: null,
        selectedLayers: null,
        selectedColor: null,
        selectedGamePlatforms: null,
        selectedCrossover: null,
        selectedStoryArc: null,
        selectedPageQuality: null,
        selectedKeyCategory: null,
        selectedGenreValues: null,
        selectedTagValues: _draft.personal.tagsController.text,
        selectedSeriesTitle: '',
        selectedSeriesId: null,
        builtInPhysicalFormats: widget.physicalFormats,
      ),
    );
    if (mounted) {
      setState(() {
        _draft.vocabulary = vocab;
        _draft.seriesEntries = vocab.seriesEntries;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final link in _links) {
      link.dispose();
    }
    if (widget.draft == null) {
      _draft.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (mounted) setState(() {});
  }

  void _submit(LibraryEditSubmitAction action) {
    if (_formKey.currentState?.validate() == false) return;
    if (_links.isNotEmpty) {
      final updatedLinks = <TrailerLinkDto>[
        for (final l in _links)
          if (l.urlController.text.trim().isNotEmpty)
            TrailerLinkDto(
              url: l.urlController.text.trim(),
              title: emptyToNull(l.descriptionController.text.trim()),
              description: emptyToNull(l.descriptionController.text.trim()),
              source: l.original?.source ?? 'manual',
              isAutomatic: l.original?.isAutomatic ?? false,
              kind: l.original?.kind ?? 'external',
            ),
      ];
      _draft.setExternalLinks(updatedLinks);
    }
    final selection = _draft.toSelection(submitAction: action);
    Navigator.of(context).pop(selection);
  }

  @override
  Widget build(BuildContext context) {
    final firstCreator = widget.item.common.creatorsSummary;
    final yearSuffix =
        widget.item.releaseYear != null ? ' (${widget.item.releaseYear})' : '';
    final title = widget.item.displayTitle ??
        (firstCreator != null && firstCreator.isNotEmpty
            ? '${widget.item.title} / $firstCreator'
            : '${widget.item.title}$yearSuffix');

    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: widget.accent,
      icon: widget.type.workspace.icon,
      title: title,
      badges: const <Widget>[],
      tabController: _tabController,
      tabs: [
        for (final tab in _tabSpecs) EditTab(icon: tab.icon, label: tab.label)
      ],
      views: _tabViews(),
      onClose: () => Navigator.of(context).pop(),
      onCancel: () => Navigator.of(context).pop(),
      onSave: () => _submit(LibraryEditSubmitAction.save),
      onPrevious: widget.onPrevious,
      onNext: widget.onNext,
    );
  }

  static String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  Widget _tabViewFor(String id) {
    final customView = libraryKindRuntimeForType(widget.type)
        .edit
        .presentation
        .builderForScope(widget.scope)
        .buildCustomTabView(
          tabId: id,
          context: context,
          draft: _draft,
          accent: widget.accent,
          scope: widget.scope,
          item: widget.item,
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
    return EditTabShell(
      children: [
        EditSection(
          title: 'Details',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.metadata.titleController,
                  label: 'Title',
                  validator: _requiredValidator,
                ),
                LibraryEditTextField(
                  controller: _draft.metadata.sortKeyController,
                  label: 'Sort title',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.metadata.originalTitleController,
                  label: 'Original title',
                ),
                LibraryEditTextField(
                  controller: _draft.metadata.localizedTitleController,
                  label: 'Localized title',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.metadata.displayTitleController,
                  label: 'Display title',
                ),
                LibraryEditTextField(
                  controller: _draft.metadata.releaseDateController,
                  label: libraryKindRuntimeForType(widget.type)
                      .edit
                      .mediaFields
                      .releaseDateLabel,
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailsTab() => _mainTab();

  Widget _genericMediaTab() => _mainTab();

  Widget _linksTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Links',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _links.add(_LinkEntry(
                        urlController: TextEditingController(),
                        descriptionController: TextEditingController(),
                      ));
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Link'),
                ),
              ),
              const SizedBox(height: 10),
              if (_links.isEmpty)
                Text(
                  'No links added.',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              for (var i = 0; i < _links.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: LibraryEditTextField(
                        key: ValueKey('bookExternalLinkUrlField_$i'),
                        controller: _links[i].urlController,
                        label: 'URL',
                        hint: 'https://',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: LibraryEditTextField(
                        key: ValueKey('bookExternalLinkDescriptionField_$i'),
                        controller: _links[i].descriptionController,
                        label: 'Link title',
                        hint: 'Description',
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () {
                        setState(() {
                          _links.removeAt(i).dispose();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _personalTab() {
    if (_draft.hasWishlistContext) {
      return EditTabShell(
        children: [
          EditSection(
            title: 'Wishlist Reference',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<PersonalItemAnchorType>(
                  key: const Key('library-edit-wishlist-anchor-field'),
                  initialValue: _draft.personal.selectedWishlistAnchorType,
                  decoration:
                      const InputDecoration(labelText: 'Wishlist target'),
                  items: [
                    const DropdownMenuItem(
                      value: PersonalItemAnchorType.item,
                      child: Text('Item / Work'),
                    ),
                    if (widget.availableBundleReleases.isNotEmpty)
                      const DropdownMenuItem(
                        value: PersonalItemAnchorType.bundleRelease,
                        child: Text('Bundle release'),
                      ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _draft.personal.selectedWishlistAnchorType =
                          val ?? PersonalItemAnchorType.item;
                      if (val == PersonalItemAnchorType.bundleRelease &&
                          widget.availableBundleReleases.isNotEmpty) {
                        _draft.personal.selectedWishlistBundleReleaseId =
                            widget.availableBundleReleases.first.id;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                LibraryEditResponsiveRow(children: [
                  LibraryEditTextField(
                    controller: _draft.personal.wishlistPriceController,
                    label: 'Target price',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Currency'),
                    value:
                        _draft.personal.wishlistCurrencyController.text.isEmpty
                            ? 'USD'
                            : _draft.personal.wishlistCurrencyController.text,
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                      DropdownMenuItem(value: 'RON', child: Text('RON')),
                      DropdownMenuItem(value: 'JPY', child: Text('JPY')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _draft.personal.wishlistCurrencyController.text =
                            val ?? 'USD';
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 10),
                TextFormField(
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

    return EditTabShell(
      children: [
        EditSection(
          title: 'Personal',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_draft.isDigitalFormat) ...[
                Text(
                  'Digital copies do not expose physical storage fields.',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 10),
                _buildLocationPickerField(),
              ] else ...[
                LibraryEditResponsiveRow(children: [
                  SingleValuePickField(
                    controller: _draft.personal.conditionController,
                    label: 'Condition',
                    options: widget.type.conditions,
                  ),
                  SingleValuePickField(
                    controller: _draft.personal.gradeController,
                    label: 'Grade',
                    options: widget.type.grades,
                  ),
                ]),
                const SizedBox(height: 10),
                LibraryEditResponsiveRow(children: [
                  _buildLocationPickerField(),
                  LibraryEditTextField(
                    controller: _draft.personal.ownerLabelController,
                    label: 'Owner',
                  ),
                ]),
              ],
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                TagPickListField(
                  controller: _draft.personal.tagsController,
                  options: const [],
                  label: 'Tags',
                ),
                LibraryEditTextField(
                  controller: _draft.personal.notesController,
                  label: 'Notes',
                ),
              ]),
            ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.personal.priceController,
                  label: 'Purchase Price',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                LibraryEditTextField(
                  controller: _draft.personal.currencyController,
                  label: 'Currency',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.personal.marketValueController,
                  label: 'Market Value',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                LibraryEditTextField(
                  controller: _draft.personal.purchaseStoreController,
                  label: 'Store / Source',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryDateFieldButton(
                label: 'Purchase Date',
                value: _draft.personal.purchaseDateController.text.isEmpty
                    ? null
                    : DateTime.tryParse(
                        _draft.personal.purchaseDateController.text),
                onChanged: (date) {
                  setState(() {
                    _draft.personal.purchaseDateController.text =
                        date?.toIso8601String().split('T').first ?? '';
                  });
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
                  label: 'Sale Price',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                LibraryEditTextField(
                  controller: _draft.personal.soldToController,
                  label: 'Sold To',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryDateFieldButton(
                label: 'Sale Date',
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
                  label: 'Tracking status',
                  value: _draft.tracking.trackingController.text.isEmpty
                      ? null
                      : _draft.tracking.trackingController.text,
                  profile: widget.type.trackingProfile,
                  onChanged: (val) {
                    _draft.tracking.trackingController.text = val ?? '';
                    _markDirty();
                  },
                ),
                MediaRatingField(
                  controller: _draft.tracking.ratingController,
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditTextField(
                controller: _draft.tracking.trackingNotesController,
                label: 'Progress / Tracking Notes',
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
          onChanged: (vals) {
            _draft.customFieldEdits = vals;
            _markDirty();
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
    return EditTabShell(
      children: [
        EditSection(
          title: 'Cover Image',
          accent: widget.accent,
          child: LibraryEditTextField(
            controller: _draft.metadata.coverController,
            label: 'Cover Image URL',
          ),
        ),
      ],
    );
  }

  Widget _synopsisTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: widget.type.editChrome.synopsisLabel,
          accent: widget.accent,
          child: LibraryEditTextField(
            controller: _draft.metadata.synopsisController,
            label: widget.type.editChrome.synopsisLabel,
            maxLines: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPickerField() {
    return InkWell(
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
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Location',
          prefixIcon: Icon(Icons.place),
        ),
        child: Text(
          _draft.personal.selectedLocationName ?? 'Pick location...',
          style: TextStyle(
            color: _draft.personal.selectedLocationName != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _ownedSharedFooterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isOwned ? 'Owned copy' : 'Wishlist item',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
