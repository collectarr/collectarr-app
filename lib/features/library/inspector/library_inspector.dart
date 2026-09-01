import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
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
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/details/library_detail_wiring.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class _InspectorConditionGradeOptionsRequest {
  const _InspectorConditionGradeOptionsRequest({
    required this.db,
    required this.mediaKind,
    required this.builtInConditions,
    required this.builtInGrades,
    this.conditionListName,
    this.gradeListName,
    required this.selectedCondition,
    required this.selectedGrade,
  });

  final LocalDatabase db;
  final String mediaKind;
  final List<String> builtInConditions;
  final List<String> builtInGrades;
  final String? conditionListName;
  final String? gradeListName;
  final String? selectedCondition;
  final String? selectedGrade;

  @override
  bool operator ==(Object other) {
    return other is _InspectorConditionGradeOptionsRequest &&
        identical(db, other.db) &&
        mediaKind == other.mediaKind &&
        listEquals(builtInConditions, other.builtInConditions) &&
        listEquals(builtInGrades, other.builtInGrades) &&
        conditionListName == other.conditionListName &&
        gradeListName == other.gradeListName &&
        selectedCondition == other.selectedCondition &&
        selectedGrade == other.selectedGrade;
  }

  @override
  int get hashCode => Object.hash(
        db,
        mediaKind,
        Object.hashAll(builtInConditions),
        Object.hashAll(builtInGrades),
        conditionListName,
        gradeListName,
        selectedCondition,
        selectedGrade,
      );
}

final _inspectorConditionGradeOptionsProvider = FutureProvider.autoDispose
    .family<PickListConditionGradeOptions,
        _InspectorConditionGradeOptionsRequest>(
  (ref, request) async {
    return loadConditionGradePickListOptions(
      request.db,
      mediaKind: request.mediaKind,
      builtInConditions: request.builtInConditions,
      builtInGrades: request.builtInGrades,
      conditionListName: request.conditionListName,
      gradeListName: request.gradeListName,
      selectedCondition: request.selectedCondition,
      selectedGrade: request.selectedGrade,
    );
  },
);

class LibraryInspector extends ConsumerStatefulWidget {
  const LibraryInspector({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
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

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime? item;
  final OwnedItem? ownedItem;
  final LibraryDetailsLayout detailsLayout;
  final LibraryWorkspaceDensityPreset densityPreset;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(OwnedItem? ownedItem)? onEdit;
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
    if (widget.item?.node.id != oldWidget.item?.node.id) {
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
    final selected = widget.item;
    if (selected == null) {
      return EmptyInspector(type: widget.type, accent: widget.accent);
    }
    final ownedCopies = ref.watch(collectionProvider).maybeWhen(
          data: (items) {
            final matches = items
                .where((item) =>
                    !item.isDeleted &&
                    item.itemId == selected.source.catalogItem?.id)
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
    final trackingEntries = ref.watch(trackingEntriesByCatalogItemProvider)[
            selected.source.catalogItem?.id] ??
        const <TrackingEntry>[];
    final activeTrackingEntry = resolveActiveTrackingEntry(
      trackingEntries,
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
            selected.source.catalogItem != null
        ? () => showMetadataCorrectionDialog(
              context: context,
              ref: ref,
              item: selected.source.catalogItem!,
              type: widget.type,
            )
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
                ownedItemId: activeOwnedItem.id,
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
          ownedItem: activeOwnedItem,
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
          onEdit: widget.onEdit,
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
      activeTrackingEntry,
      LibraryInspectorRequest(
        type: widget.type,
        item: selected,
        ownedItem: activeOwnedItem,
        onEdit: widget.onEdit == null
            ? null
            : () => widget.onEdit!(activeOwnedItem),
        ownedCopies: ownedCopies,
        trackingEntry: activeTrackingEntry,
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
    LibraryProjectionRuntime selected,
    OwnedItem? activeOwnedItem,
    List<OwnedItem> ownedCopies,
    TrackingEntry? activeTrackingEntry,
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
    final runtime = widget.type;
    final editCapability = runtime.edit;
    final inspectorCapability = runtime.inspector;
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
        editions: selected.source.catalogItem?.editions ?? const [],
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
        (editCapability.conditions.isNotEmpty ||
            editCapability.grades.isNotEmpty) &&
        resolveOwnedDigitalFlag(
              activeOwnedItem,
              selected.source.catalogItem?.editions ?? const [],
              fallbackLabel: selected.dto is WorkspaceDtoAdapter
                  ? (selected.dto as WorkspaceDtoAdapter).variant
                  : null,
            ) !=
            true) {
      conditionGradeSection = Builder(
        builder: (context) {
          final editCapability = widget.type.edit;
          final conditionDefinition =
              editCapability.vocabularies?.definitionForSuffix('condition');
          final gradeDefinition =
              editCapability.vocabularies?.definitionForSuffix('grade');
          final builtInConditions = conditionDefinition == null
              ? editCapability.conditions
              : [
                  for (final value in conditionDefinition.builtIns)
                    value.toString()
                ];
          final builtInGrades = gradeDefinition == null
              ? editCapability.grades
              : [
                  for (final value in gradeDefinition.builtIns) value.toString()
                ];
          final options = ref
              .watch(
                _inspectorConditionGradeOptionsProvider(
                  _InspectorConditionGradeOptionsRequest(
                    db: widget.db ?? ref.read(localDatabaseProvider),
                    mediaKind: widget.type.kind.apiValue,
                    builtInConditions: builtInConditions,
                    builtInGrades: builtInGrades,
                    conditionListName: conditionDefinition?.key,
                    gradeListName: gradeDefinition?.key,
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
                  builtInValues: builtInConditions,
                  selectedValues: [activeOwnedItem.condition],
                ),
            grades: options?.grades ??
                mergePickListValues(
                  builtInValues: builtInGrades,
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
      if (activeOwnedItem != null && widget.db != null)
        InspectorCustomFieldsSection(
          ownedItemId: activeOwnedItem.id,
          mediaKind: widget.type.kind.apiValue,
          db: widget.db!,
          accent: widget.accent,
          onFilterByValue: widget.onFilterByValue,
        ),
      if (inspectorCapability.showsDefaultPersonalSection)
        InspectorPersonalSection(
          item: selected,
          ownedItem: activeOwnedItem,
          trackingEntry: activeTrackingEntry,
          accent: widget.accent,
          onFilterByValue: widget.onFilterByValue,
        ),
      if (activeOwnedItem != null &&
          widget.db != null &&
          widget.type.capabilities.supportsOwnedItemImages)
        InspectorItemImagesSection(
          ownedItemId: activeOwnedItem.id,
          db: widget.db!,
          accent: widget.accent,
        ),
      ...?(!usesCustomInspectorPanel
          ? buildLibraryInspectorEditorSections(
              type: widget.type,
              item: selected,
              accent: widget.accent,
              ownedItem: activeOwnedItem,
              trackingEntry: activeTrackingEntry,
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
          if (activeOwnedItem != null &&
              (editCapability.conditions.isNotEmpty ||
                  editCapability.grades.isNotEmpty) &&
              resolveOwnedDigitalFlag(
                    activeOwnedItem,
                    selected.source.catalogItem?.editions ?? const [],
                    fallbackLabel: selected.dto is WorkspaceDtoAdapter
                        ? (selected.dto as WorkspaceDtoAdapter).variant
                        : null,
                  ) !=
                  true) ...[
            SizedBox(height: density.inspectorOuterGap),
            conditionGradeSection!,
          ],
          SizedBox(height: density.inspectorOuterGap),
          ...effectivePrimarySections,
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
    await ref.read(collectionCommandCoordinatorProvider).updateOwnedItem(
          UpdateOwnedItemCommand(
            ownedItemId: item.id,
            condition: Patch.set(condition),
            grade: Patch.set(grade),
          ),
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
      builder: (context) => LibraryDialogScaffold(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onClose: () => Navigator.of(context).pop(),
        child: SingleChildScrollView(child: child),
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
    LibraryProjectionRuntime item, {
    OwnedItem? ownedItem,
  }) async {
    final anchor = resolveLibraryMutationAnchor(
      item: item,
      ownedItem: ownedItem,
    );
    await ref.read(collectionCommandCoordinatorProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: CatalogEntityRef(
              kind: widget.type.kind.apiValue,
              entityType: CatalogEntityType.work,
              id: item.node.titleItemId,
            ),
            common: OwnedItemCommonDraft(
              editionId: anchor.editionId,
              variantId: anchor.variantId,
              bundleReleaseId: anchor.bundleReleaseId,
            ),
            details: defaultDetailsDraftForKind(widget.type.kind),
          ),
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
    await ref.read(ownedItemMutationsProvider).removeItem(item);
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

  Future<void> _duplicateOwnedCopy(
    LibraryProjectionRuntime item,
    OwnedItem ownedItem,
  ) async {
    await ref.read(collectionCommandCoordinatorProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: ownedItem.catalogRef,
            common: OwnedItemCommonDraft(
              isDigital: ownedItem.isDigital,
              editionId: ownedItem.editionId,
              variantId: ownedItem.variantId,
              bundleReleaseId: ownedItem.bundleReleaseId,
              condition: ownedItem.condition,
              grade: ownedItem.grade,
              purchaseDate: ownedItem.purchaseDate,
              pricePaidCents: ownedItem.pricePaidCents,
              currency: ownedItem.currency,
              personalNotes: ownedItem.personalNotes,
              quantity: ownedItem.quantity,
              locationId: ownedItem.locationId,
              rating: ownedItem.rating,
              readStatus: ownedItem.readStatus,
              startedAt: ownedItem.startedAt,
              finishedAt: ownedItem.finishedAt,
              tags: ownedItem.tags,
            ),
            details: ownedItem.details.toDraft(),
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedOwnedItemId = null;
      _selectNewestOwnedItem = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated "${item.dto.title}"')),
    );
  }

  Future<void> _refreshSelectedEntryMetadata(
      LibraryProjectionRuntime item) async {
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

  void _shareInspectorEntry(LibraryProjectionRuntime item) {
    showCollectionShareDialog(
      context: context,
      title: item.dto.title,
      items: <LibraryProjectionRuntime>[item],
    );
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

class EmptyInspector extends StatelessWidget {
  const EmptyInspector({
    required this.type,
    required this.accent,
    super.key,
  });

  final LibraryKindRuntime type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('No ${type.identity.singularLabel.toLowerCase()} selected'),
    );
  }
}
