import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/inspector/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/library/inspector/inspector_custom_fields_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_item_images_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_loan_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_location_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_folder_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_reading_queue_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _kInspectorOuterGap = 8;

@immutable
class _InspectorConditionGradeOptionsRequest {
  const _InspectorConditionGradeOptionsRequest({
    required this.db,
    required this.mediaKind,
    required this.builtInConditions,
    required this.builtInGrades,
    required this.selectedCondition,
    required this.selectedGrade,
  });

  final LocalDatabase db;
  final String mediaKind;
  final List<String> builtInConditions;
  final List<String> builtInGrades;
  final String? selectedCondition;
  final String? selectedGrade;

  @override
  bool operator ==(Object other) {
    return other is _InspectorConditionGradeOptionsRequest &&
        identical(db, other.db) &&
        mediaKind == other.mediaKind &&
        listEquals(builtInConditions, other.builtInConditions) &&
        listEquals(builtInGrades, other.builtInGrades) &&
        selectedCondition == other.selectedCondition &&
        selectedGrade == other.selectedGrade;
  }

  @override
  int get hashCode => Object.hash(
        db,
        mediaKind,
        Object.hashAll(builtInConditions),
        Object.hashAll(builtInGrades),
        selectedCondition,
        selectedGrade,
      );
}

final _inspectorConditionGradeOptionsProvider = FutureProvider.autoDispose
    .family<PickListConditionGradeOptions, _InspectorConditionGradeOptionsRequest>(
  (ref, request) async {
    return loadConditionGradePickListOptions(
      request.db,
      mediaKind: request.mediaKind,
      builtInConditions: request.builtInConditions,
      builtInGrades: request.builtInGrades,
      selectedCondition: request.selectedCondition,
      selectedGrade: request.selectedGrade,
    );
  },
);

class LibraryInspector extends ConsumerStatefulWidget {
  const LibraryInspector({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
    this.onDetailsLayoutChanged,
    this.onFilterByValue,
    this.db,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry? entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(OwnedItem? ownedItem)? onEdit;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final ValueChanged<String>? onFilterByValue;
  final LocalDatabase? db;

  @override
  ConsumerState<LibraryInspector> createState() => _LibraryInspectorState();
}

class _LibraryInspectorState extends ConsumerState<LibraryInspector> {
  String? _selectedOwnedItemId;
  bool _selectNewestOwnedItem = false;

  @override
  void initState() {
    super.initState();
    _selectedOwnedItemId = widget.ownedItem?.id;
  }

  @override
  void didUpdateWidget(covariant LibraryInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry?.id != oldWidget.entry?.id) {
      _selectedOwnedItemId = widget.ownedItem?.id;
      _selectNewestOwnedItem = false;
      return;
    }
    if (widget.ownedItem?.id != oldWidget.ownedItem?.id &&
        widget.ownedItem != null &&
        _selectedOwnedItemId == null) {
      _selectedOwnedItemId = widget.ownedItem!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.entry;
    if (selected == null) {
      return EmptyInspector(type: widget.type, accent: widget.accent);
    }
    final usesCustomInspectorPanel = widget.type.inspectorPanelBuilder != null;
    final ownedCopies = ref.watch(collectionProvider).maybeWhen(
          data: (items) {
            final matches = items
                .where((item) => !item.isDeleted && item.itemId == selected.id)
                .toList(growable: false)
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            return matches;
          },
          orElse: () => widget.ownedItem == null
              ? const <OwnedItem>[]
              : <OwnedItem>[widget.ownedItem!],
        );
    final ownedResolution = resolveActiveOwnedItem(
      ownedCopies,
      fallback: widget.ownedItem,
      selectedOwnedItemId: _selectedOwnedItemId,
      selectNewest: _selectNewestOwnedItem,
    );
    final activeOwnedItem = ownedResolution.ownedItem;
    if (ownedResolution.shouldScheduleSelection(
      _selectedOwnedItemId,
      _selectNewestOwnedItem,
    )) {
      _scheduleOwnedCopySelection(
        ownedResolution.nextSelectedOwnedItemId!,
        clearNewest: ownedResolution.clearNewest,
      );
    }
    final trackingEntries =
        ref.watch(trackingEntriesByCatalogItemProvider)[selected.id] ??
            const <TrackingEntry>[];
    final activeTrackingEntry = resolveActiveTrackingEntry(
      trackingEntries,
      activeOwnedItem,
    );
    final inspectorRequest = LibraryInspectorRequest(
      type: widget.type,
      entry: selected,
      ownedItem: activeOwnedItem,
      ownedCopies: ownedCopies,
      trackingEntry: activeTrackingEntry,
      accent: widget.accent,
      onFilterByValue: widget.onFilterByValue,
    );
    final activeBundleReleaseId =
        activeOwnedItem?.bundleReleaseId ?? selected.referenceBundleReleaseId;
    final extraActions = <Widget>[
      if (selected.isOwned)
        _InspectorDialogActionButton(
          tooltip: 'Add another copy',
          icon: Icons.copy_all_outlined,
          onPressed: () => _addOwnedCopy(selected, ownedItem: activeOwnedItem),
        ),
      if (activeOwnedItem != null && widget.db != null)
        _InspectorDialogActionButton(
          tooltip: 'Manage location',
          icon: Icons.place_outlined,
          onPressed: () => _showOwnedSectionDialog(
            context,
            title: 'Location',
            child: InspectorLocationSection(
              ownedItemId: activeOwnedItem.id,
              db: widget.db!,
              accent: widget.accent,
            ),
          ),
        ),
      if (activeOwnedItem != null && widget.db != null)
        _InspectorDialogActionButton(
          tooltip: 'Manage folders',
          icon: Icons.folder_open_outlined,
          onPressed: () => _showOwnedSectionDialog(
            context,
            title: 'Folders',
            child: InspectorFolderSection(
              ownedItemId: activeOwnedItem.id,
              db: widget.db!,
              accent: widget.accent,
            ),
          ),
        ),
      if (activeOwnedItem != null && widget.db != null)
        _InspectorDialogActionButton(
          tooltip: 'Manage loans',
          icon: Icons.handshake_outlined,
          onPressed: () => _showOwnedSectionDialog(
            context,
            title: 'Loans',
            child: InspectorLoanSection(
              ownedItemId: activeOwnedItem.id,
              db: widget.db!,
              accent: widget.accent,
            ),
          ),
        ),
      if (activeOwnedItem != null &&
          widget.db != null &&
          libraryShowsReadingQueue(widget.type.workspace.kind))
        _InspectorReadingQueueActionButton(
          ownedItemId: activeOwnedItem.id,
          db: widget.db!,
          accent: widget.accent,
        ),
    ];
    final onToggleOwned = selected.isOwned
        ? activeOwnedItem == null
            ? widget.onRemoveOwned
            : () => _removeOwnedCopy(activeOwnedItem)
        : widget.onAddOwned;
    final onToggleWishlist =
        selected.isWishlisted ? widget.onRemoveWishlist : widget.onAddWishlist;
    final onEdit = widget.onEdit == null
        ? null
        : () => widget.onEdit!(activeOwnedItem);
    final onCorrectMetadata = widget.type.supportedMetadataProviders.isNotEmpty
        ? () => showMetadataCorrectionDialog(
              context: context,
              ref: ref,
              item: CatalogItem(
                id: selected.id,
                kind: widget.type.workspace.kind.apiValue,
                title: selected.title,
                itemNumber: selected.itemNumber,
                publisher: selected.publisher,
                releaseYear: selected.releaseYear,
                barcode: selected.barcode,
                variant: selected.variant,
              ),
              type: widget.type,
            )
        : null;
    void onOpenDetails() {
      showLibraryDetailPage(
        context: context,
        request: LibraryDetailPageRequest(
          type: widget.type,
          entry: selected,
          ownedItem: activeOwnedItem,
          accent: widget.accent,
          onAddOwned: selected.isOwned
              ? () => _addOwnedCopy(
                    selected,
                    ownedItem: activeOwnedItem,
                  )
              : widget.onAddOwned,
          onRemoveOwned: activeOwnedItem == null
              ? widget.onRemoveOwned
              : () => _removeOwnedCopy(activeOwnedItem),
          onAddWishlist: widget.onAddWishlist,
          onRemoveWishlist: widget.onRemoveWishlist,
          onEdit: widget.onEdit,
          onFilterByValue: widget.onFilterByValue,
        ),
      );
    }
    final hero = widget.type.inspectorHeroBuilder?.call(
          context,
          inspectorRequest,
        ) ??
        InspectorHero(
          type: widget.type,
          entry: selected,
          ownedItem: activeOwnedItem,
          accent: widget.accent,
        );
    final primarySections = widget.type.inspectorSectionsBuilder?.call(
          context,
          inspectorRequest,
        ) ??
        <Widget>[
          InspectorMetadataSection(
            type: widget.type,
            entry: selected,
            accent: widget.accent,
            onFilterByValue: widget.onFilterByValue,
          ),
        ];
    Widget? ownedCopiesSection;
    if (ownedCopies.isNotEmpty) {
      ownedCopiesSection = _InspectorOwnedCopiesSection(
        copies: ownedCopies,
        editions: selected.editions,
        selectedOwnedItemId: activeOwnedItem?.id,
        accent: widget.accent,
        onAddCopy: () => _addOwnedCopy(
          selected,
          ownedItem: activeOwnedItem,
        ),
        onSelected: ownedCopies.length < 2
            ? null
            : (value) => setState(() => _selectedOwnedItemId = value),
      );
    }
    final bundleSection = activeBundleReleaseId == null
        ? null
        : BundleReleaseContentsSection(
            bundleReleaseId: activeBundleReleaseId,
            accent: widget.accent,
          );
    Widget? conditionGradeSection;
    if (!usesCustomInspectorPanel &&
      activeOwnedItem != null &&
        (widget.type.conditions.isNotEmpty || widget.type.grades.isNotEmpty) &&
        resolveOwnedDigitalFlag(
              activeOwnedItem,
              selected.editions,
              fallbackLabel: selected.variant,
            ) !=
            true) {
      conditionGradeSection = Builder(
        builder: (context) {
          final options = ref
              .watch(
                _inspectorConditionGradeOptionsProvider(
                  _InspectorConditionGradeOptionsRequest(
                    db: widget.db ?? ref.read(localDatabaseProvider),
                    mediaKind: widget.type.workspace.kind.apiValue,
                    builtInConditions: widget.type.conditions,
                    builtInGrades: widget.type.grades,
                    selectedCondition: activeOwnedItem.condition,
                    selectedGrade: activeOwnedItem.grade,
                  ),
                ),
              )
              .value;
          return InspectorCollectionFields(
            enabled: true,
            condition: activeOwnedItem.condition,
            grade: activeOwnedItem.grade,
            conditions: options?.conditions ??
                mergePickListValues(
                  builtInValues: widget.type.conditions,
                  selectedValues: [activeOwnedItem.condition],
                ),
            grades: options?.grades ??
                mergePickListValues(
                  builtInValues: widget.type.grades,
                  selectedValues: [activeOwnedItem.grade],
                ),
            accent: widget.accent,
            onConditionChanged: (value) => _updateConditionGrade(
              context,
              activeOwnedItem,
              condition: value,
              grade: activeOwnedItem.grade,
            ),
            onGradeChanged: (value) => _updateConditionGrade(
              context,
              activeOwnedItem,
              condition: activeOwnedItem.condition,
              grade: value,
            ),
          );
        },
      );
    }
    final trailingSections = <Widget>[
      if (widget.type.showsDefaultInspectorPersonalSection)
        InspectorPersonalSection(
          entry: selected,
          ownedItem: activeOwnedItem,
          trackingEntry: activeTrackingEntry,
          accent: widget.accent,
        ),
      if (!usesCustomInspectorPanel && activeOwnedItem != null)
        InspectorPersonalDetailsEditor(
          ownedItem: activeOwnedItem,
          accent: widget.accent,
        ),
      if (!usesCustomInspectorPanel && activeTrackingEntry != null)
        InspectorTrackingDetailsEditor(
          itemId: selected.id,
          trackingEntry: activeTrackingEntry,
          profile: widget.type.trackingProfile,
          editions: selected.editions,
          accent: widget.accent,
        ),
      if (activeOwnedItem != null && widget.db != null)
        InspectorCustomFieldsSection(
          ownedItemId: activeOwnedItem.id,
          mediaKind: widget.type.workspace.kind.apiValue,
          db: widget.db!,
          accent: widget.accent,
        ),
      if (activeOwnedItem != null &&
          widget.db != null &&
          widget.type.capabilities.supportsOwnedItemImages)
        InspectorItemImagesSection(
          ownedItemId: activeOwnedItem.id,
          db: widget.db!,
          accent: widget.accent,
        ),
      ...widget.type.presentation.builder.buildInspectorSections(
        context: context,
        entry: selected,
        accent: widget.accent,
      ),
    ];
    if (widget.type.inspectorPanelBuilder != null) {
      return widget.type.inspectorPanelBuilder!(
        context,
        LibraryInspectorPanelRequest(
          inspector: inspectorRequest,
          hero: hero,
          primarySections: primarySections,
          trailingSections: trailingSections,
          ownedCopies: ownedCopies,
          selectedOwnedItemId: activeOwnedItem?.id,
          extraActions: extraActions,
          onAddCopy: () => _addOwnedCopy(
            selected,
            ownedItem: activeOwnedItem,
          ),
          onOpenDetails: onOpenDetails,
          onDetailsLayoutChanged: widget.onDetailsLayoutChanged,
          ownedCopiesSection: ownedCopiesSection,
          bundleSection: bundleSection,
          conditionGradeSection: conditionGradeSection,
          onSelectOwnedItem: ownedCopies.length < 2
              ? null
              : (value) => setState(() => _selectedOwnedItemId = value),
          onToggleOwned: onToggleOwned,
          onToggleWishlist: onToggleWishlist,
          onEdit: onEdit,
          onCorrectMetadata: onCorrectMetadata,
        ),
      );
    }
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          left: BorderSide(color: palette.divider),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  hero,
                  const SizedBox(height: 6),
                  InspectorActionBar(
                    type: widget.type,
                    entry: selected,
                    onToggleOwned: onToggleOwned,
                    onToggleWishlist: onToggleWishlist,
                    onEdit: onEdit,
                    onCorrectMetadata: onCorrectMetadata,
                    extraActions: extraActions,
                    onOpenDetails: onOpenDetails,
                  ),
                ],
              ),
            ),
          ),
              if (ownedCopies.isNotEmpty) ...[
                const SizedBox(height: _kInspectorOuterGap),
                ownedCopiesSection!,
              ],
              if (activeBundleReleaseId != null) ...[
                const SizedBox(height: _kInspectorOuterGap),
                bundleSection!,
              ],
              if (activeOwnedItem != null &&
                  (widget.type.conditions.isNotEmpty || widget.type.grades.isNotEmpty) &&
                  resolveOwnedDigitalFlag(
                        activeOwnedItem,
                        selected.editions,
                        fallbackLabel: selected.variant,
                      ) !=
                      true) ...[
                        const SizedBox(height: _kInspectorOuterGap),
                conditionGradeSection!,
              ],
              const SizedBox(height: _kInspectorOuterGap),
              ...primarySections,
              ...trailingSections,
        ],
      ),
    );
  }

  Future<void> _updateConditionGrade(
    BuildContext context,
    OwnedItem item, {
    required String? condition,
    required String? grade,
  }) async {
    await ref.read(collectionMutationsProvider).updateItem(
          item,
          condition: condition,
          grade: grade,
          purchaseDate: item.purchaseDate,
          pricePaidCents: item.pricePaidCents,
          currency: item.currency,
          personalNotes: item.personalNotes,
          quantity: item.quantity,
          indexNumber: item.indexNumber,
          coverPriceCents: item.coverPriceCents,
          rawOrSlabbed: item.rawOrSlabbed,
          gradingCompany: item.gradingCompany,
          graderNotes: item.graderNotes,
          signedBy: item.signedBy,
          labelType: item.labelType,
          certificationNumber: item.certificationNumber,
          keyComic: item.keyComic,
          keyReason: item.keyReason,
          rating: item.rating,
          readStatus: item.readStatus,
          tags: item.tags,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection details updated')),
      );
    }
  }

  Future<void> _showOwnedSectionDialog(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scheduleOwnedCopySelection(
    String ownedItemId, {
    bool clearNewest = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedOwnedItemId = ownedItemId;
        if (clearNewest) {
          _selectNewestOwnedItem = false;
        }
      });
    });
  }

  Future<void> _addOwnedCopy(
    LibraryWorkspaceEntry entry, {
    OwnedItem? ownedItem,
  }) async {
    final anchor = resolveLibraryMutationAnchor(
      entry: entry,
      ownedItem: ownedItem,
    );
    await ref.read(collectionMutationsProvider).addItem(
          entry.id,
          anchorType: anchor.anchorType,
          editionId: anchor.editionId,
          variantId: anchor.variantId,
          bundleReleaseId: anchor.bundleReleaseId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedOwnedItemId = null;
      _selectNewestOwnedItem = true;
    });
  }

  Future<void> _removeOwnedCopy(OwnedItem item) async {
    await ref.read(collectionMutationsProvider).removeItem(item);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedOwnedItemId == item.id) {
        _selectedOwnedItemId = null;
      }
      _selectNewestOwnedItem = false;
    });
  }
}

class _InspectorOwnedCopiesSection extends StatelessWidget {
  const _InspectorOwnedCopiesSection({
    required this.copies,
    required this.editions,
    required this.selectedOwnedItemId,
    required this.accent,
    required this.onAddCopy,
    this.onSelected,
  });

  final List<OwnedItem> copies;
  final List<CatalogEdition> editions;
  final String? selectedOwnedItemId;
  final Color accent;
  final VoidCallback onAddCopy;
  final ValueChanged<String?>? onSelected;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: copies.length == 1 ? 'Copy' : 'Copies',
      accentColor: accent,
      children: [
        Row(
          children: [
            Expanded(
              child: copies.length < 2
                  ? Text(
                      '1 copy in collection',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    )
                  : DropdownButtonFormField<String>(
                      initialValue: selectedOwnedItemId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Active copy',
                      ),
                      items: [
                        for (var index = 0; index < copies.length; index += 1)
                          DropdownMenuItem<String>(
                            value: copies[index].id,
                            child: Text(
                              buildOwnedCopyLabel(
                                copies[index],
                                editions,
                                index,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: onSelected,
                    ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onAddCopy,
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Add copy'),
            ),
          ],
        ),
        if (copies.length > 1) ...[
          const SizedBox(height: 8),
          Text(
            '${copies.length} copies in collection',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

class _InspectorDialogActionButton extends StatelessWidget {
  const _InspectorDialogActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InspectorToolIconButton(
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed,
    );
  }
}

class _InspectorReadingQueueActionButton extends StatefulWidget {
  const _InspectorReadingQueueActionButton({
    required this.ownedItemId,
    required this.db,
    required this.accent,
  });

  final String ownedItemId;
  final LocalDatabase db;
  final Color accent;

  @override
  State<_InspectorReadingQueueActionButton> createState() =>
      _InspectorReadingQueueActionButtonState();
}

class _InspectorReadingQueueActionButtonState
    extends State<_InspectorReadingQueueActionButton> {
  bool _loading = true;
  bool _inQueue = false;
  int? _position;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final queue = await ReadingQueueRepository(widget.db).getQueue();
    final index = queue.indexOf(widget.ownedItemId);
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _inQueue = index >= 0;
      _position = index >= 0 ? index + 1 : null;
    });
  }

  Future<void> _openDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: InspectorReadingQueueSection(
              ownedItemId: widget.ownedItemId,
              db: widget.db,
              accent: widget.accent,
            ),
          ),
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _loading
        ? 'Reading queue'
        : _inQueue
            ? 'Reading queue · position #$_position'
            : 'Add to reading queue';
    return InspectorToolIconButton(
      tooltip: tooltip,
      onPressed: _openDialog,
      icon: _inQueue ? Icons.bookmark : Icons.bookmark_border,
    );
  }
}
