import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:collectarr_app/features/library/inspector/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/library/inspector/inspector_custom_fields_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_item_images_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_loan_section.dart';
import 'package:collectarr_app/features/library/inspector/inspector_reading_queue_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_wiring.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_bundle.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_providers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryInspector extends ConsumerStatefulWidget {
  const LibraryInspector({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
    this.ownedItemDispatch,
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
  final LibraryProjectionView? item;
  final OwnedItemSummary? ownedItem;
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final List<OwnedItemSummary>? ownedCopies;
  final LibraryDetailsLayout detailsLayout;
  final LibraryWorkspaceDensityPreset densityPreset;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(OwnedItemSummary? ownedItem)? onEdit;
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
  OwnedItemRef? _selectedOwnedItemRef;
  bool _selectNewestOwnedItem = false;

  @override
  void initState() {
    super.initState();
    _selectedOwnedItemRef = widget.ownedItem?.ref;
  }

  @override
  void didUpdateWidget(covariant LibraryInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item?.node.id != oldWidget.item?.node.id) {
      _selectedOwnedItemRef = widget.ownedItem?.ref;
      _selectNewestOwnedItem = false;
      return;
    }
    if (widget.ownedItem?.ref != oldWidget.ownedItem?.ref &&
        widget.ownedItem != null &&
        _selectedOwnedItemRef == null) {
      _selectedOwnedItemRef = widget.ownedItem!.ref;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.item;
    if (selected == null) {
      return EmptyInspector(type: widget.type, accent: widget.accent);
    }
    final ownedItemDispatch =
        widget.ownedItemDispatch ?? selected.source.ownedItemDispatch;
    // Mixed inspector state carries only the structural summary. Concrete
    // kind-owned data remains available through ownedItemDispatch after dispatch.
    final ownedCopies = widget.ownedCopies ??
        (widget.ownedItem == null
            ? const <OwnedItemSummary>[]
            : <OwnedItemSummary>[widget.ownedItem!]);
    final ownedSummaryResolution = resolveActiveOwnedSummary(
      ownedCopies,
      fallback: widget.ownedItem,
      selectedOwnedItemRef: _selectedOwnedItemRef,
      selectNewest: _selectNewestOwnedItem,
    );
    final activeOwnedItem = ownedSummaryResolution.ownedItem;
    if (ownedSummaryResolution.nextSelectedOwnedItemRef != null &&
        (ownedSummaryResolution.nextSelectedOwnedItemRef !=
                _selectedOwnedItemRef ||
            (ownedSummaryResolution.clearNewest && _selectNewestOwnedItem))) {
      _scheduleOwnedCopySelection(
        ownedSummaryResolution.nextSelectedOwnedItemRef!,
        clearNewest: ownedSummaryResolution.clearNewest,
      );
    }
    final trackingSummaries = switch (selected.source.catalogRef) {
      final catalogRef? =>
        ref.watch(trackingSummariesByCatalogRefProvider)[catalogRef] ??
            const <TrackingSummary>[],
      _ => const <TrackingSummary>[],
    };
    final activeTrackingSummary = resolveActiveTrackingSummary(
      trackingSummaries,
      activeOwnedItem,
    );
    final trackingLifecycles = switch (selected.source.catalogRef) {
      final catalogRef? =>
        ref.watch(trackingPersistenceEntriesByCatalogRefProvider)[catalogRef] ??
            const <TrackingRecord>[],
      _ => const <TrackingRecord>[],
    };
    final activeTrackingLifecycle = resolveActiveTrackingLifecycle(
      trackingLifecycles,
      activeOwnedItem,
    );
    final onToggleOwned = selected.source.isOwned
        ? activeOwnedItem == null
            ? widget.onRemoveOwned
            : () => _removeOwnedCopy(activeOwnedItem)
        : widget.onAddOwned;
    final onToggleWishlist = selected.source.isWishlisted
        ? widget.onRemoveWishlist
        : widget.onAddWishlist;
    final onEdit =
        widget.onEdit == null ? null : () => widget.onEdit!(activeOwnedItem);
    final onCorrectMetadata = widget.type.metadata
                .supportedProvidersForKind(widget.type.kind)
                .isNotEmpty &&
            selected.source.catalogRef != null
        ? () => _showMetadataCorrection(context, selected)
        : null;
    final onDuplicate = activeOwnedItem == null
        ? null
        : () => _duplicateOwnedCopy(selected, activeOwnedItem);
    final onLoan = activeOwnedItem == null || widget.db == null
        ? null
        : () => _showOwnedSectionDialog(
              context,
              title: 'Loans',
              child: InspectorLoanSection(
                ownedRef: activeOwnedItem.ref,
                db: widget.db!,
                accent: widget.accent,
              ),
            );
    final onRefreshMetadata =
        widget.type.metadata.supportedProvidersForKind(widget.type.kind).isEmpty
            ? null
            : () => _refreshSelectedEntryMetadata(selected);
    void onShare() => _shareInspectorEntry(selected);
    void onOpenDetails() {
      showLibraryDetailPage(
        context: context,
        request: LibraryDetailPageRequest(
          type: widget.type,
          item: selected,
          ownedSummary: ownedSummaryResolution.ownedItem,
          ownedItemDispatch: ownedItemDispatch,
          accent: widget.accent,
          onAddOwned: selected.source.isOwned
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
          onEdit: widget.onEdit == null
              ? null
              : (_) => widget.onEdit!(activeOwnedItem),
          onFilterByValue: widget.onFilterByValue,
        ),
      );
    }

    return _buildContent(
      context,
      ref,
      selected,
      activeOwnedItem,
      ownedCopies,
      activeTrackingSummary,
      activeTrackingLifecycle,
      LibraryInspectorRequest(
        type: widget.type,
        item: selected,
        ownedItem: activeOwnedItem,
        ownedItemDispatch: ownedItemDispatch,
        onEdit: widget.onEdit == null
            ? null
            : () => widget.onEdit!(activeOwnedItem),
        ownedCopies: ownedCopies,
        trackingSummary: activeTrackingSummary,
        trackingLifecycle: activeTrackingLifecycle,
        accent: widget.accent,
        detailsLayout: widget.detailsLayout,
        onFilterByValue: widget.onFilterByValue,
        searchQuery: widget.searchQuery,
        searchTarget: widget.searchTarget,
      ),
      usesCustomInspectorPanel: false,
      activeBundleReleaseId: null,
      onToggleOwned: onToggleOwned,
      onToggleWishlist: onToggleWishlist,
      onEdit: onEdit,
      onCorrectMetadata: onCorrectMetadata,
      onDuplicate: onDuplicate,
      onLoan: onLoan,
      onRefreshMetadata: onRefreshMetadata,
      onShare: onShare,
      onOpenDetails: onOpenDetails,
      density: widget.densityPreset,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    LibraryProjectionView selected,
    OwnedItemSummary? activeOwnedItem,
    List<OwnedItemSummary> ownedCopies,
    TrackingSummary? activeTrackingSummary,
    TrackingRecord? activeTrackingLifecycle,
    LibraryInspectorRequest inspectorRequest, {
    required bool usesCustomInspectorPanel,
    required String? activeBundleReleaseId,
    required VoidCallback? onToggleOwned,
    required VoidCallback? onToggleWishlist,
    required VoidCallback? onEdit,
    required VoidCallback? onCorrectMetadata,
    required VoidCallback? onDuplicate,
    required VoidCallback? onLoan,
    required VoidCallback? onRefreshMetadata,
    required VoidCallback onShare,
    required VoidCallback onOpenDetails,
    required LibraryWorkspaceDensityPreset density,
  }) {
    final kindModule = widget.type;
    final inspectorCapability = kindModule.inspector;
    final hero = inspectorCapability.heroBuilder?.call(
          context,
          inspectorRequest,
        ) ??
        InspectorHero(
          type: widget.type,
          item: selected,
          ownedItem: activeOwnedItem,
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
        releases: widget.type.presentation.builder.buildWorkspaceReleases(
          selected.source,
        ),
        collectionValueReader: widget.type.ownedEdit.readOwnedCollectionValue,
        ownedItemDispatch: inspectorRequest.ownedItemDispatch,
        selectedOwnedItemRef: activeOwnedItem?.ref,
        accent: widget.accent,
        onAddCopy: () => _addOwnedCopy(
          selected,
          ownedItem: activeOwnedItem,
        ),
        onSelected: ownedCopies.length < 2
            ? null
            : (value) => setState(() => _selectedOwnedItemRef = value),
      );
    }
    final bundleSection = activeBundleReleaseId == null
        ? null
        : BundleReleaseContentsSection(
            bundleReleaseId: activeBundleReleaseId,
            accent: widget.accent,
          );
    final trailingSections = <Widget>[
      if (activeOwnedItem != null && widget.db != null)
        InspectorCustomFieldsSection(
          ownedRef: activeOwnedItem.ref,
          db: widget.db!,
          accent: widget.accent,
          onFilterByValue: widget.onFilterByValue,
        ),
      if (inspectorCapability.showsDefaultPersonalSection)
        InspectorPersonalSection(
          type: widget.type,
          item: selected,
          ownedItem: activeOwnedItem,
          ownedItemDispatch: inspectorRequest.ownedItemDispatch,
          trackingSummary: activeTrackingSummary,
          accent: widget.accent,
          onFilterByValue: widget.onFilterByValue,
        ),
      if (activeOwnedItem != null &&
          widget.db != null &&
          widget.type.inspector.supportsOwnedItemImages)
        InspectorItemImagesSection(
          ownedRef: activeOwnedItem.ref,
          db: widget.db!,
          accent: widget.accent,
        ),
      ...?(!usesCustomInspectorPanel
          ? buildLibraryInspectorEditorSections(
              type: widget.type,
              item: selected,
              accent: widget.accent,
              ownedItem: activeOwnedItem,
              trackingSummary: activeTrackingSummary,
              trackingLifecycle: activeTrackingLifecycle,
            )
          : null),
      ...?(!usesCustomInspectorPanel
          ? buildLibraryInspectorKindSections(
              context: context,
              type: widget.type,
              item: selected,
              accent: widget.accent,
              onFilterByValue: widget.onFilterByValue,
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
            onEdit: onEdit,
            onShare: onShare,
            onDuplicate: onDuplicate,
            onToggleOwned: onToggleOwned,
            onLoan: onLoan,
            onRefreshMetadata: onRefreshMetadata,
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
                    onToggleOwned: onToggleOwned,
                    onToggleWishlist: onToggleWishlist,
                    onEdit: onEdit,
                    onCorrectMetadata: onCorrectMetadata,
                    onOpenDetails: onOpenDetails,
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onClose: () => Navigator.of(context).pop(),
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  void _scheduleOwnedCopySelection(
    OwnedItemRef ownedItemRef, {
    bool clearNewest = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedOwnedItemRef = ownedItemRef;
        if (clearNewest) {
          _selectNewestOwnedItem = false;
        }
      });
    });
  }

  Future<void> _addOwnedCopy(
    LibraryProjectionView item, {
    OwnedItemSummary? ownedItem,
  }) async {
    final catalogRef = item.source.catalogRef;
    if (catalogRef == null) {
      return;
    }
    final catalogItem = await CatalogSnapshotRepository(
      widget.db ?? ref.read(localDatabaseProvider),
    ).findByRef(catalogRef.rootScope);
    if (catalogItem == null) {
      return;
    }
    await ref.read(collectionCommandCoordinatorProvider).addOwnedItem(
          widget.type.add.buildCommand(
            CatalogSearchCandidate.fromItem(catalogItem),
            const LibraryAddCommonDraft(),
            widget.type.add.createInitialDraft(),
            targetRef: ownedItem?.targetRef ??
                ownedItem?.catalogRef ??
                catalogItem.catalogRef,
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedOwnedItemRef = null;
      _selectNewestOwnedItem = true;
    });
  }

  Future<void> _showMetadataCorrection(
    BuildContext context,
    LibraryProjectionView selected,
  ) async {
    final catalogRef = selected.source.catalogRef;
    if (catalogRef == null) return;
    final catalogItem = await CatalogSnapshotRepository(
      widget.db ?? ref.read(localDatabaseProvider),
    ).findByRef(catalogRef.rootScope);
    if (!context.mounted || catalogItem == null) return;
    await showMetadataCorrectionDialog(
      context: context,
      ref: ref,
      source: LibraryMetadataCorrectionSource(
        title: catalogItem.title,
        values: LibraryMetadataCorrectionValues.fromSerialized(
          catalogItem.toSyncPayload(),
        ),
      ),
      type: widget.type,
    );
  }

  Future<void> _removeOwnedCopy(OwnedItemSummary item) async {
    await ref.read(ownedItemMutationsProvider).removeItem(item.ref);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedOwnedItemRef == item.ref) {
        _selectedOwnedItemRef = null;
      }
      _selectNewestOwnedItem = false;
    });
  }

  Future<void> _duplicateOwnedCopy(
    LibraryProjectionView item,
    OwnedItemSummary ownedItem,
  ) async {
    final duplicated = await ref.read(ownedItemMutationsProvider).duplicateItem(
          ownedItem.ref,
          targetRef: ownedItem.catalogRef,
          tracking: OwnedItemTrackingDraft(
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
      _selectedOwnedItemRef = null;
      _selectNewestOwnedItem = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated "${item.dto.title}"')),
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
      title: item.dto.title,
      items: <LibraryProjectionView>[item],
    );
  }
}

class _InspectorOwnedCopiesSection extends StatelessWidget {
  const _InspectorOwnedCopiesSection({
    required this.copies,
    required this.releases,
    required this.collectionValueReader,
    required this.ownedItemDispatch,
    required this.selectedOwnedItemRef,
    required this.accent,
    required this.onAddCopy,
    this.onSelected,
  });

  final List<OwnedItemSummary> copies;
  final List<LibraryWorkspaceReleaseSummary> releases;
  final String? Function(LibraryOwnedItemDispatch?) collectionValueReader;
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final OwnedItemRef? selectedOwnedItemRef;
  final Color accent;
  final VoidCallback onAddCopy;
  final ValueChanged<OwnedItemRef?>? onSelected;

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
                  : DropdownButtonFormField<OwnedItemRef>(
                      initialValue: selectedOwnedItemRef,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Active copy',
                      ),
                      items: [
                        for (var index = 0; index < copies.length; index += 1)
                          DropdownMenuItem<OwnedItemRef>(
                            value: copies[index].ref,
                            child: Text(
                              buildOwnedCopyLabelFromWorkspaceReleases(
                                    copies[index],
                                    releases,
                                    index,
                                    collectionValue: collectionValueReader(
                                        ownedItemDispatch),
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

class _InspectorReadingQueueActionButton extends StatefulWidget {
  const _InspectorReadingQueueActionButton({
    required this.ownedRef,
    required this.db,
    required this.accent,
  });

  final OwnedItemRef ownedRef;
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
    final index = queue.indexOf(widget.ownedRef);
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
              ownedRef: widget.ownedRef,
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
            ? 'Reading queue Ãƒâ€šÃ‚Â· position #$_position'
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
