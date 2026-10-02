import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/collection_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:collectarr_app/features/library/inspector/inspector_custom_fields_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_item_images_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_loan_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_reading_queue_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_wiring.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_entity_action_capability.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryInspector extends ConsumerStatefulWidget {
  const LibraryInspector({
    super.key,
    required this.type,
    required this.projection,
    required this.item,
    required this.collectionItem,
    this.collectionItemDispatch,
    this.ownedCopies,
    this.detailsLayout = LibraryDetailsLayout.hidden,
    this.densityPreset = LibraryWorkspaceDensityPreset.compact,
    required this.accent,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
    this.onDetailsLayoutChanged,
    this.onFilterByValue,
    this.searchQuery,
    this.searchTarget = LibrarySearchTarget.all,
    this.db,
    this.contextLabel,
  });

  final LibraryKindRegistration type;
  final LibraryProjection projection;
  final LibraryProjectionView? item;
  final CollectionItemSummary? collectionItem;
  final LibraryCollectionItemDispatch? collectionItemDispatch;
  final List<CollectionItemSummary>? ownedCopies;
  final LibraryDetailsLayout detailsLayout;
  final LibraryWorkspaceDensityPreset densityPreset;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(CollectionItemSummary? collectionItem)? onEdit;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final ValueChanged<String>? onFilterByValue;
  final String? searchQuery;
  final LibrarySearchTarget searchTarget;
  final LocalDatabase? db;
  final String? contextLabel;

  @override
  ConsumerState<LibraryInspector> createState() => _LibraryInspectorState();
}

class _LibraryInspectorState extends ConsumerState<LibraryInspector> {
  CollectionItemRef? _selectedCollectionItemRef;
  bool _selectNewestCollectionItem = false;

  @override
  void initState() {
    super.initState();
    _selectedCollectionItemRef = widget.collectionItem?.ref;
  }

  @override
  void didUpdateWidget(covariant LibraryInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item?.node.id != oldWidget.item?.node.id) {
      _selectedCollectionItemRef = widget.collectionItem?.ref;
      _selectNewestCollectionItem = false;
      return;
    }
    if (widget.collectionItem?.ref != oldWidget.collectionItem?.ref &&
        widget.collectionItem != null &&
        _selectedCollectionItemRef == null) {
      _selectedCollectionItemRef = widget.collectionItem!.ref;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.item;
    if (selected == null) {
      return EmptyInspector(type: widget.type, accent: widget.accent);
    }
    final collectionItemDispatch =
        widget.collectionItemDispatch ?? selected.source.collectionItemDispatch;
    // Mixed inspector state carries only the structural summary. Concrete
    // kind-owned data remains available through collectionItemDispatch after dispatch.
    final ownedCopies = widget.ownedCopies ??
        (widget.collectionItem == null
            ? const <CollectionItemSummary>[]
            : <CollectionItemSummary>[widget.collectionItem!]);
    final collectionItemSummaryResolution = resolveActiveCollectionItemSummary(
      ownedCopies,
      fallback: widget.collectionItem,
      selectedCollectionItemRef: _selectedCollectionItemRef,
      selectNewest: _selectNewestCollectionItem,
    );
    final activeCollectionItem = collectionItemSummaryResolution.collectionItem;
    if (collectionItemSummaryResolution.nextSelectedCollectionItemRef != null &&
        (collectionItemSummaryResolution.nextSelectedCollectionItemRef !=
                _selectedCollectionItemRef ||
            (collectionItemSummaryResolution.clearNewest &&
                _selectNewestCollectionItem))) {
      _scheduleCollectionItemSelection(
        collectionItemSummaryResolution.nextSelectedCollectionItemRef!,
        clearNewest: collectionItemSummaryResolution.clearNewest,
      );
    }
    final activeTrackingSummary = resolveActiveTrackingSummary(
      libraryTrackingSummariesForItem(
        widget.type,
        selected,
        ref.watch(trackingSummariesByCatalogRefProvider),
        collectionItem: activeCollectionItem,
      ),
      activeCollectionItem,
    );
    final canCreateCopy = libraryOwnershipForKind(widget.type.kind)
        .canCreateCopyAt(selected.node);
    final onToggleOwned = selected.source.isOwned
        ? activeCollectionItem == null
            ? widget.onRemoveOwned
            : () => _removeCollectionItem(activeCollectionItem)
        : !canCreateCopy
            ? null
            : widget.onAddOwned;
    final onToggleWishlist = selected.source.isWishlisted
        ? widget.onRemoveWishlist
        : widget.onAddWishlist;
    final onEdit = widget.onEdit == null
        ? null
        : () => widget.onEdit!(activeCollectionItem);
    final onDuplicate = activeCollectionItem == null
        ? null
        : () => _duplicateCollectionItem(selected, activeCollectionItem);
    final onLoan = activeCollectionItem == null || widget.db == null
        ? null
        : () => _showOwnedSectionDialog(
              context,
              title: 'Loans',
              child: InspectorLoanSection(
                collectionItemRef: activeCollectionItem.ref,
                db: widget.db!,
                accent: widget.accent,
              ),
            );
    void onRefreshMetadata() => _refreshSelectedEntryMetadata(selected);
    void onShare() => _shareInspectorEntry(selected);
    late final LibraryItemActions scopedActions;
    void onOpenDetails() {
      showLibraryDetailPage(
        context: context,
        request: LibraryDetailPageRequest(
          type: widget.type,
          item: selected,
          collectionItemSummary: collectionItemSummaryResolution.collectionItem,
          collectionItemDispatch: collectionItemDispatch,
          accent: widget.accent,
          actions: scopedActions,
          onFilterByValue: widget.onFilterByValue,
        ),
      );
    }

    final addCopy = !canCreateCopy
        ? null
        : () => _addCollectionItem(
              selected,
            );
    final actionRegistry = libraryEntityActionsForKind(widget.type.kind).build(
      LibraryEntityActionContext(
        type: widget.type,
        buildContext: context,
        projection: widget.projection,
        item: selected,
        collectionItem: activeCollectionItem,
        ownedCopies: ownedCopies,
        onAddCopy: addCopy,
        onOpenDetails: onOpenDetails,
        onSelectCollectionItem: (ref) =>
            setState(() => _selectedCollectionItemRef = ref),
        onToggleOwned: onToggleOwned,
        onToggleWishlist: onToggleWishlist,
        onEdit: onEdit,
        onDuplicate: onDuplicate,
        onLoan: onLoan,
        onRefreshMetadata: onRefreshMetadata,
        onShare: onShare,
        onUnlinkFromCore: null,
        accent: widget.accent,
      ),
    );
    final resolvedActions = actionRegistry.actionsForScope(selected.node.scope);
    scopedActions = resolvedActions;

    return _buildContent(
      context,
      ref,
      selected,
      activeCollectionItem,
      ownedCopies,
      activeTrackingSummary,
      LibraryInspectorRequest(
        type: widget.type,
        item: selected,
        collectionItem: activeCollectionItem,
        collectionItemDispatch: collectionItemDispatch,
        onEdit: scopedActions.onEdit,
        ownedCopies: ownedCopies,
        trackingSummary: activeTrackingSummary,
        accent: widget.accent,
        detailsLayout: widget.detailsLayout,
        onFilterByValue: widget.onFilterByValue,
        searchQuery: widget.searchQuery,
        searchTarget: widget.searchTarget,
      ),
      usesCustomInspectorPanel: false,
      activeBundleReleaseId: null,
      entityActions: scopedActions,
      density: widget.densityPreset,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    LibraryProjectionView selected,
    CollectionItemSummary? activeCollectionItem,
    List<CollectionItemSummary> ownedCopies,
    TrackingSummary? activeTrackingSummary,
    LibraryInspectorRequest inspectorRequest, {
    required bool usesCustomInspectorPanel,
    required String? activeBundleReleaseId,
    required LibraryItemActions entityActions,
    required LibraryWorkspaceDensityPreset density,
  }) {
    final registration = widget.type;
    final inspectorCapability = libraryInspectorForKind(registration.kind);
    final hero =
        inspectorCapability.heroBuilderForScope(selected.node.scope)?.call(
                  context,
                  inspectorRequest,
                ) ??
            InspectorHero(
              type: widget.type,
              item: selected,
              collectionItem: activeCollectionItem,
              accent: widget.accent,
              contextLabel: widget.contextLabel,
            );
    final primarySections = inspectorCapability.buildSections(
      context,
      inspectorRequest,
    );
    final effectivePrimarySections = primarySections.isNotEmpty
        ? primarySections
        : <Widget>[
            InspectorMetadataSection(
              type: widget.type,
              item: selected,
              accent: widget.accent,
              onFilterByValue: widget.onFilterByValue,
            ),
          ];
    Widget? ownedCopiesSection;
    if (ownedCopies.isNotEmpty) {
      ownedCopiesSection = _InspectorOwnedCopiesSection(
        copies: ownedCopies,
        collectionValueReader:
            libraryOwnedEditForKind(widget.type.kind).readOwnedCollectionValue,
        collectionItemDispatch: inspectorRequest.collectionItemDispatch,
        selectedCollectionItemRef: activeCollectionItem?.ref,
        accent: widget.accent,
        onAddCopy: entityActions.onAddCopy,
        onSelected: ownedCopies.length < 2 ||
                entityActions.onSelectCollectionItem == null
            ? null
            : (ref) {
                if (ref != null) {
                  entityActions.onSelectCollectionItem!(ref);
                }
              },
      );
    }
    final bundleSection = activeBundleReleaseId == null
        ? null
        : BundleReleaseContentsSection(
            bundleReleaseId: activeBundleReleaseId,
            accent: widget.accent,
          );
    final trailingSections = <Widget>[
      if (activeCollectionItem != null && widget.db != null)
        InspectorCustomFieldsSection(
          collectionItemRef: activeCollectionItem.ref,
          db: widget.db!,
          accent: widget.accent,
          onFilterByValue: widget.onFilterByValue,
        ),
      if (inspectorCapability.showsDefaultPersonalSection)
        InspectorPersonalSection(
          type: widget.type,
          item: selected,
          collectionItem: activeCollectionItem,
          collectionItemDispatch: inspectorRequest.collectionItemDispatch,
          trackingSummary: activeTrackingSummary,
          accent: widget.accent,
          onFilterByValue: widget.onFilterByValue,
        ),
      if (activeCollectionItem != null &&
          widget.db != null &&
          libraryInspectorForKind(widget.type.kind)
              .supportsCollectionItemImages)
        InspectorItemImagesSection(
          collectionItemRef: activeCollectionItem.ref,
          db: widget.db!,
          accent: widget.accent,
        ),
      ...?(!usesCustomInspectorPanel
          ? buildLibraryInspectorEditorSections(
              type: widget.type,
              item: selected,
              accent: widget.accent,
              collectionItem: activeCollectionItem,
              trackingSummary: activeTrackingSummary,
            )
          : null),
    ];
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          left: BorderSide(color: palette.divider),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        children: [
          InspectorUnifiedToolbar(
            item: selected,
            onEdit: entityActions.onEdit,
            onShare: entityActions.onShare,
            onDuplicate: entityActions.onDuplicate,
            onToggleOwned: entityActions.onToggleOwned,
            onLoan: entityActions.onLoan,
            onRefreshMetadata: entityActions.onRefreshMetadata,
            onDetailsLayoutChanged: widget.onDetailsLayoutChanged,
            detailsLayout: widget.detailsLayout,
          ),
          SizedBox(height: density.inspectorOuterGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                hero,
                SizedBox(height: density.inspectorOuterGap),
                if (!usesCustomInspectorPanel)
                  InspectorActionBar(
                    type: widget.type,
                    item: selected,
                    onToggleOwned: entityActions.onToggleOwned,
                    onToggleWishlist: entityActions.onToggleWishlist,
                    onEdit: entityActions.onEdit,
                    onOpenDetails: entityActions.onOpenDetails ?? () {},
                    semanticActions: entityActions.semanticActions,
                  ),
              ],
            ),
          ),
          if (ownedCopies.isNotEmpty) ...[
            SizedBox(height: density.inspectorOuterGap),
            ownedCopiesSection!,
          ],
          if (activeBundleReleaseId != null) ...[
            SizedBox(height: density.inspectorOuterGap),
            bundleSection!,
          ],
          SizedBox(height: density.inspectorOuterGap),
          ...effectivePrimarySections,
          ...trailingSections,
        ],
      ),
    );
  }

  Future<void> _showOwnedSectionDialog(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => LibraryDialogScaffold(
        title: Text(
          title,
        ),
        onClose: () => Navigator.of(context).pop(),
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  void _scheduleCollectionItemSelection(
    CollectionItemRef collectionItemRef, {
    bool clearNewest = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedCollectionItemRef = collectionItemRef;
        if (clearNewest) {
          _selectNewestCollectionItem = false;
        }
      });
    });
  }

  Future<void> _addCollectionItem(
    LibraryProjectionView item,
  ) async {
    if (!libraryOwnershipForKind(widget.type.kind).canCreateCopyAt(item.node)) {
      return;
    }
    final catalogRef = item.source.catalogRef;
    if (catalogRef == null) {
      return;
    }
    final catalogItem = await CatalogSnapshotRepository(
      widget.db ?? ref.read(localDatabaseProvider),
    ).findCandidateByRef(catalogRef.rootScope);
    if (catalogItem == null) {
      return;
    }
    await ref.read(collectionCommandCoordinatorProvider).addCollectionItem(
          libraryAddForKind(widget.type.kind).buildCommand(
            catalogItem,
            const LibraryAddCommonDraft(),
            libraryAddForKind(widget.type.kind).createInitialDraft(),
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedCollectionItemRef = null;
      _selectNewestCollectionItem = true;
    });
  }

  Future<void> _removeCollectionItem(CollectionItemSummary item) async {
    await ref.read(collectionItemMutationsProvider).removeItem(item.ref);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedCollectionItemRef == item.ref) {
        _selectedCollectionItemRef = null;
      }
      _selectNewestCollectionItem = false;
    });
  }

  Future<void> _duplicateCollectionItem(
    LibraryProjectionView item,
    CollectionItemSummary collectionItem,
  ) async {
    final duplicated =
        await ref.read(collectionItemMutationsProvider).duplicateItem(
              collectionItem.ref,
              tracking: CollectionItemTrackingDraft(
                status: item.source.trackingSummary?.status,
                rating: item.source.trackingSummary?.rating,
                startedAt: item.source.trackingSummary?.startedAt,
                finishedAt: item.source.trackingSummary?.completedAt,
                notes: item.source.trackingSummary?.notes,
              ),
            );
    if (duplicated == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedCollectionItemRef = null;
      _selectNewestCollectionItem = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated "${item.dto.primaryLabel}"')),
    );
  }

  Future<void> _refreshSelectedEntryMetadata(LibraryProjectionView item) async {
    final result = await showLibraryMetadataRefreshDialog(
      context: context,
      type: widget.type,
      accent: widget.accent,
      allEntries: [item],
      shownEntries: [item],
      selectedEntry: item,
    );
    if (result == null || !mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Metadata refresh finished: ${result.matched}/${result.targets} matched, ${result.cached} cached, ${result.failed} failed.',
        ),
      ),
    );
  }

  void _shareInspectorEntry(LibraryProjectionView item) {
    showCollectionShareDialog(
      context: context,
      title: item.dto.primaryLabel,
      items: <LibraryProjectionView>[item],
    );
  }
}

class _InspectorOwnedCopiesSection extends StatelessWidget {
  const _InspectorOwnedCopiesSection({
    required this.copies,
    required this.collectionValueReader,
    required this.collectionItemDispatch,
    required this.selectedCollectionItemRef,
    required this.accent,
    required this.onAddCopy,
    this.onSelected,
  });

  final List<CollectionItemSummary> copies;
  final String? Function(LibraryCollectionItemDispatch?) collectionValueReader;
  final LibraryCollectionItemDispatch? collectionItemDispatch;
  final CollectionItemRef? selectedCollectionItemRef;
  final Color accent;
  final VoidCallback? onAddCopy;
  final ValueChanged<CollectionItemRef?>? onSelected;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailSection(
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
                  : CompactSearchDropdownFormField<CollectionItemRef>(
                      initialValue: selectedCollectionItemRef,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Active copy',
                      ),
                      items: [
                        for (var index = 0; index < copies.length; index += 1)
                          DropdownMenuItem<CollectionItemRef>(
                            value: copies[index].ref,
                            child: Text(
                              buildCollectionItemLabel(
                                    copies[index],
                                    index,
                                    collectionValue: collectionValueReader(
                                        collectionItemDispatch),
                                  ) ??
                                  'Copy ${index + 1}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: onSelected,
                    ),
            ),
            if (onAddCopy != null) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onAddCopy,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Add copy'),
              ),
            ],
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

class _InspectorReadingQueueActionButton extends StatefulWidget {
  const _InspectorReadingQueueActionButton({
    required this.collectionItemRef,
    required this.db,
    required this.accent,
  });

  final CollectionItemRef collectionItemRef;
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
    final index = queue.indexOf(widget.collectionItemRef);
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
      builder: (context) => AccentAlertDialog(
        title: const Text('Reading Queue'),
        content: SizedBox(
          width: 360,
          child: InspectorReadingQueueSection(
            collectionItemRef: widget.collectionItemRef,
            db: widget.db,
            accent: widget.accent,
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

class EmptyInspector extends StatelessWidget {
  const EmptyInspector({
    required this.type,
    required this.accent,
    super.key,
  });

  final LibraryKindRegistration type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('No ${type.identity.singularLabel.toLowerCase()} selected'),
    );
  }
}
