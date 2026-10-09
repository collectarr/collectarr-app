import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
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
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/config/library_target_action_capability.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryInspector extends ConsumerStatefulWidget {
  const LibraryInspector({
    super.key,
    required this.type,
    required this.projection,
    required this.item,
    required this.libraryEntry,
    this.libraryEntryDispatch,
    this.detailsLayout = LibraryDetailsLayout.hidden,
    this.densityPreset = LibraryWorkspaceDensityPreset.compact,
    required this.accent,
    required this.onAddEntry,
    required this.onRemoveEntry,
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
  final LibraryEntrySummary? libraryEntry;
  final LibraryEntryDispatch? libraryEntryDispatch;
  final LibraryDetailsLayout detailsLayout;
  final LibraryWorkspaceDensityPreset densityPreset;
  final Color accent;
  final VoidCallback? onAddEntry;
  final VoidCallback? onRemoveEntry;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(LibraryEntrySummary? libraryEntry)? onEdit;
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
  @override
  Widget build(BuildContext context) {
    final selected = widget.item;
    if (selected == null) {
      return EmptyInspector(type: widget.type, accent: widget.accent);
    }
    final libraryEntryDispatch =
        widget.libraryEntryDispatch ?? selected.source.libraryEntryDispatch;
    // Mixed inspector state carries only the structural summary. Concrete
    // kind-entry data remains available through libraryEntryDispatch after dispatch.
    final activeLibraryEntry = widget.libraryEntry;
    final libraryEntries = activeLibraryEntry == null
        ? const <LibraryEntrySummary>[]
        : <LibraryEntrySummary>[activeLibraryEntry];
    final activeTrackingSummary = resolveActiveTrackingSummary(
      libraryTrackingSummariesForItem(
        selected,
        ref.watch(trackingSummariesByLibraryEntryRefProvider),
        libraryEntry: activeLibraryEntry,
      ),
      activeLibraryEntry,
    );
    final canAddEntry = libraryEntryPolicyForKind(widget.type.kind)
        .canCreateCopyAt(selected.target);
    final onToggleEntry = selected.source.isEntry
        ? activeLibraryEntry == null
            ? widget.onRemoveEntry
            : () => _removeLibraryEntry(activeLibraryEntry)
        : !canAddEntry
            ? null
            : widget.onAddEntry;
    final onToggleWishlist = selected.source.isWishlisted
        ? widget.onRemoveWishlist
        : widget.onAddWishlist;
    final onEdit =
        widget.onEdit == null ? null : () => widget.onEdit!(activeLibraryEntry);
    final onDuplicate = activeLibraryEntry == null
        ? null
        : () => _duplicateLibraryEntry(selected, activeLibraryEntry);
    final onLoan = activeLibraryEntry == null || widget.db == null
        ? null
        : () => _showEntrySectionDialog(
              context,
              title: 'Loans',
              child: InspectorLoanSection(
                libraryEntryRef: activeLibraryEntry.ref,
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
          libraryEntrySummary: activeLibraryEntry,
          libraryEntryDispatch: libraryEntryDispatch,
          accent: widget.accent,
          actions: scopedActions,
          onFilterByValue: widget.onFilterByValue,
        ),
      );
    }

    scopedActions = libraryEntityActionsForKind(widget.type.kind).build(
      LibraryTargetActionContext(
        type: widget.type,
        buildContext: context,
        projection: widget.projection,
        item: selected,
        libraryEntry: activeLibraryEntry,
        onOpenDetails: onOpenDetails,
        onToggleEntry: onToggleEntry,
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
    return _buildContent(
      context,
      ref,
      selected,
      activeLibraryEntry,
      libraryEntries,
      activeTrackingSummary,
      LibraryInspectorRequest(
        type: widget.type,
        item: selected,
        libraryEntry: activeLibraryEntry,
        libraryEntryDispatch: libraryEntryDispatch,
        onEdit: scopedActions.onEdit,
        libraryEntries: libraryEntries,
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
    LibraryEntrySummary? activeLibraryEntry,
    List<LibraryEntrySummary> libraryEntries,
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
        inspectorCapability.heroBuilderForTarget(selected.target)?.call(
                  context,
                  inspectorRequest,
                ) ??
            InspectorHero(
              type: widget.type,
              item: selected,
              libraryEntry: activeLibraryEntry,
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
    final bundleSection = activeBundleReleaseId == null
        ? null
        : BundleReleaseContentsSection(
            bundleReleaseId: activeBundleReleaseId,
            accent: widget.accent,
          );
    final trailingSections = <Widget>[
      if (activeLibraryEntry != null && widget.db != null)
        InspectorCustomFieldsSection(
          libraryEntryRef: activeLibraryEntry.ref,
          db: widget.db!,
          accent: widget.accent,
          onFilterByValue: widget.onFilterByValue,
        ),
      if (inspectorCapability.showsDefaultPersonalSection)
        InspectorPersonalSection(
          type: widget.type,
          item: selected,
          libraryEntry: activeLibraryEntry,
          libraryEntryDispatch: inspectorRequest.libraryEntryDispatch,
          trackingSummary: activeTrackingSummary,
          accent: widget.accent,
          onFilterByValue: widget.onFilterByValue,
        ),
      if (activeLibraryEntry != null &&
          widget.db != null &&
          libraryInspectorForKind(widget.type.kind).supportsLibraryEntryImages)
        InspectorItemImagesSection(
          libraryEntryRef: activeLibraryEntry.ref,
          db: widget.db!,
          accent: widget.accent,
        ),
      ...?(!usesCustomInspectorPanel
          ? buildLibraryInspectorEditorSections(
              type: widget.type,
              item: selected,
              accent: widget.accent,
              libraryEntry: activeLibraryEntry,
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
            onToggleEntry: entityActions.onToggleEntry,
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
                    onToggleEntry: entityActions.onToggleEntry,
                    onToggleWishlist: entityActions.onToggleWishlist,
                    onEdit: entityActions.onEdit,
                    onOpenDetails: entityActions.onOpenDetails ?? () {},
                    semanticActions: entityActions.semanticActions,
                  ),
              ],
            ),
          ),
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

  Future<void> _showEntrySectionDialog(
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

  Future<void> _removeLibraryEntry(LibraryEntrySummary item) async {
    await ref.read(libraryEntryMutationsProvider).removeItem(item.ref);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _duplicateLibraryEntry(
    LibraryProjectionView item,
    LibraryEntrySummary libraryEntry,
  ) async {
    final trackingSummary = item.source.trackingSummary;
    final duplicated =
        await ref.read(libraryEntryMutationsProvider).duplicateItem(
              libraryEntry.ref,
              tracking: trackingSummary == null
                  ? null
                  : LibraryEntryTrackingDraft(
                      status: trackingSummary.status,
                      sourceType: trackingSummary.sourceType,
                      rating: trackingSummary.rating,
                      startedAt: trackingSummary.startedAt,
                      finishedAt: trackingSummary.completedAt,
                      notes: trackingSummary.notes,
                      progressCurrent: trackingSummary.progress.current,
                      progressTotal: trackingSummary.progress.total,
                      timesCompleted: trackingSummary.progress.timesCompleted,
                    ),
            );
    if (duplicated == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {});
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

class _InspectorReadingQueueActionButton extends StatefulWidget {
  const _InspectorReadingQueueActionButton({
    required this.libraryEntryRef,
    required this.db,
    required this.accent,
  });

  final LibraryEntryRef libraryEntryRef;
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
    final index = queue.indexOf(widget.libraryEntryRef);
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
            libraryEntryRef: widget.libraryEntryRef,
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
