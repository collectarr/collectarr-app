import 'dart:async';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
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

class _LibraryEditRendererState extends ConsumerState<LibraryEditRenderer>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final LibraryEditDraft _draft;
  late final TabController _tabController;
  late List<LibraryEditTabSpec> _tabSpecs;

  bool get _isOwned => _draft.isOwned;

  LibraryEditPresentationContext get _editPresentationContext =>
      LibraryEditPresentationContext(
        isOwned: _isOwned,
        isTrackingOnly: _draft.isTrackingOnly,
        hasTrackingContext: _draft.hasTrackingContext,
        hasWishlistContext: _draft.hasWishlistContext,
        isDigitalFormat: _draft.metadata.physicalFormatLabelController.text
                .trim()
                .toLowerCase() ==
            'digital',
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

    _tabSpecs = widget.type.editPresentation
        .builderForScope(widget.scope)
        .buildTabs(context: _editPresentationContext);

    _tabController = TabController(
      length: _tabSpecs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    var selection = _draft.toSelection(submitAction: action);
    selection = _draft.kindDetails?.applySelectionEdits(selection) ?? selection;
    Navigator.of(context).pop(selection);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.displayTitle ?? widget.item.title;
    final subtitle = widget.type.singularLabel;

    return LibraryEditDialogScaffold(
      formKey: _formKey,
      title: title,
      icon: widget.type.workspace.icon,
      badges: [
        Text(
          subtitle,
          style: TextStyle(
            color: widget.accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      accent: widget.accent,
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
      footerContent: _isOwned ? _ownedSharedFooterRow() : null,
      tabOrderKey: 'edit_tab_order_${widget.type.workspace.kind.apiValue}',
    );
  }

  static String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  Widget _tabViewFor(String id) {
    final customView = widget.type.editPresentation
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
      'release' => _releaseTab(),
      'value' => _valueTab(),
      'personal' => _personalTab(),
      'read_history' || 'tracking' => _trackingTab(),
      'sold' => _soldTab(),
      'custom' => _customFieldsTab(),
      'photos' => _photosTab(),
      'cover' => _coverTab(),
      'synopsis' => _synopsisTab(),
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
                  controller: _draft.metadata.originalTitleController,
                  label: 'Original title',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.metadata.seriesTitleController,
                  label: 'Series',
                ),
                LibraryEditTextField(
                  controller: _draft.metadata.numberController,
                  label: widget.type.mediaFields.numberLabel,
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.metadata.publisherController,
                  label: widget.type.mediaFields.publisherLabel,
                ),
                LibraryEditTextField(
                  controller: _draft.metadata.releaseDateController,
                  label: widget.type.mediaFields.releaseDateLabel,
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: _draft.metadata.barcodeController,
                  label: widget.type.releaseFields.barcodeLabel,
                ),
                LibraryEditTextField(
                  controller: _draft.metadata.physicalFormatLabelController,
                  label: widget.type.releaseFields.variantLabel,
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

  Widget _releaseTab() => _mainTab();

  Widget _personalTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Personal',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
        decoration: const InputDecoration(labelText: 'Location'),
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
