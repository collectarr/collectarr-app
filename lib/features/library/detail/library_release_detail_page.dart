import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/detail/library_title_metadata_section.dart';
import 'package:collectarr_app/features/library/detail/library_metadata_corrections_section.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';
import 'package:collectarr_app/features/library/tracking/session_history_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_node.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildLibraryReleaseDetailPage(
  BuildContext context,
  LibraryDetailPageRequest request,
) {
  return LibraryReleaseDetailPage(request: request);
}

class LibraryReleaseDetailPage extends ConsumerStatefulWidget {
  const LibraryReleaseDetailPage({super.key, required this.request});

  final LibraryDetailPageRequest request;

  @override
  ConsumerState<LibraryReleaseDetailPage> createState() =>
      _LibraryReleaseDetailPageState();
}

class _LibraryReleaseDetailPageState
    extends ConsumerState<LibraryReleaseDetailPage> {
  String? _selectedReleaseNodeId;
  final Map<String, OwnedItemRef?> _selectedOwnedItemRefByRelease =
      <String, OwnedItemRef?>{};

  @override
  void initState() {
    super.initState();
    final nodes = _releaseNodesFor(
      widget.request.item,
      source: widget.request.type.releaseDetailSource,
    );
    _selectedReleaseNodeId = nodes.isEmpty ? null : nodes.first.id;
  }

  @override
  void didUpdateWidget(covariant LibraryReleaseDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.item.source.itemId !=
        widget.request.item.source.itemId) {
      final nodes = _releaseNodesFor(
        widget.request.item,
        source: widget.request.type.releaseDetailSource,
      );
      _selectedReleaseNodeId = nodes.isEmpty ? null : nodes.first.id;
      _selectedOwnedItemRefByRelease.clear();
    }
  }

  Future<void> _addCopyForRelease(_ResolvedLibraryRelease release) async {
    final releaseSource = widget.request.type.releaseDetailSource;
    final catalogItem = widget.request.item.source.catalogSnapshot;
    if (catalogItem == null || releaseSource == null) {
      return;
    }
    await ref.read(collectionCommandCoordinatorProvider).addOwnedItem(
          widget.request.type.add.buildCommand(
            CatalogSearchCandidate.fromSnapshot(catalogItem),
            const LibraryAddCommonDraft(),
            widget.request.type.add.createInitialDraft(),
            targetRef: releaseSource.targetRefForEdition(
              catalogItem.catalogRef,
              release.edition,
            ),
          ),
        );
  }

  Future<void> _removeSelectedCopy(_ResolvedLibraryRelease release) async {
    final selectedCopy = _selectedOwnedCopyFor(release);
    if (selectedCopy == null) {
      return;
    }
    await ref.read(ownedItemMutationsProvider).removeItem(selectedCopy.ref);
  }

  Future<void> _addWishlistForRelease(_ResolvedLibraryRelease release) async {
    final releaseSource = widget.request.type.releaseDetailSource;
    final catalogItem = widget.request.item.source.catalogSnapshot;
    if (catalogItem == null || releaseSource == null) {
      return;
    }
    await ref.read(wishlistMutationsProvider).addToWishlist(
          releaseSource.targetRefForEdition(
            catalogItem.catalogRef,
            release.edition,
          ),
        );
  }

  Future<void> _removeWishlistForRelease(
    _ResolvedLibraryRelease release,
  ) async {
    final wishlistItem = release.wishlistItem;
    if (wishlistItem == null) {
      return;
    }
    await ref.read(wishlistMutationsProvider).removeFromWishlist(
          catalogRef: wishlistItem.catalogRef,
          wishlistItemId: wishlistItem.id,
        );
  }

  OwnedItemSummary? _selectedOwnedCopyFor(_ResolvedLibraryRelease release) {
    if (release.ownedCopies.isEmpty) {
      return null;
    }
    final selectedRef = _selectedOwnedItemRefByRelease[release.node.id];
    if (selectedRef != null) {
      for (final copy in release.ownedCopies) {
        if (copy.ref == selectedRef) {
          return copy;
        }
      }
    }
    return release.ownedCopies.first;
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final releaseSource = request.type.releaseDetailSource;
    final wishlistValue = ref.watch(wishlistProvider);
    final ownedCopies = request.item.source.ownedSummary == null
        ? const <OwnedItemSummary>[]
        : <OwnedItemSummary>[request.item.source.ownedSummary!];
    final wishlistItems = wishlistValue.maybeWhen(
      data: (items) => items
          .where(
            (item) =>
                !item.isDeleted &&
                (item.catalogRef.rootId ?? item.catalogRef.id) ==
                    request.item.source.itemId,
          )
          .toList(growable: false),
      orElse: () => const <WishlistItem>[],
    );
    final releases = _resolvedReleasesFor(
      request.item,
      source: releaseSource,
      ownedCopies: ownedCopies,
      wishlistItems: wishlistItems,
    );
    final itemRef = CatalogEntityRef(
      kind: request.type.kind,
      entityType: const CatalogEntityTypeId('work'),
      id: request.item.source.itemId,
    );
    final watchHistoryTargets = <WatchHistoryTargetOption>[
      WatchHistoryTargetOption(
        ref: itemRef,
        label: request.item.source.title,
        subtitle: request.item.source.catalogSummary?.subtitle ?? '',
      ),
      ...releases.map(
        (release) => WatchHistoryTargetOption(
          ref: releaseSource?.targetRefForEdition(
                itemRef,
                release.edition,
              ) ??
              itemRef,
          label: release.node.edition.title.isEmpty
              ? release.node.releaseId
              : release.node.edition.title,
          subtitle: release.node.edition.physicalFormat,
        ),
      ),
    ];
    _ResolvedLibraryRelease? selectedRelease;
    for (final release in releases) {
      if (release.node.releaseId == _selectedReleaseNodeId) {
        selectedRelease = release;
        break;
      }
    }
    selectedRelease ??= releases.isEmpty ? null : releases.first;
    final selectedOwnedCopy =
        selectedRelease == null ? null : _selectedOwnedCopyFor(selectedRelease);
    final appBarForeground =
        ThemeData.estimateBrightnessForColor(request.accent) == Brightness.dark
            ? Colors.white
            : Colors.black87;
    final kindMediaContribution = request
        .type.inspector.mediaDetailContributionBuilder
        ?.call(context, request);
    return Theme(
      data: buildLibraryTheme(palette: appPalette(context)),
      child: Scaffold(
        backgroundColor: appPalette(context).canvas,
        appBar: AppBar(
          backgroundColor: request.accent,
          foregroundColor: appBarForeground,
          title: Text(request.item.source.title),
          actions: [
            IconButton(
              tooltip: 'Edit metadata and collection fields',
              onPressed: request.onEdit == null
                  ? null
                  : () => request.onEdit!(request.ownedSummary),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LibraryDetailHero(
              type: request.type,
              item: request.item,
              ownedItem: request.ownedSummary,
              accent: request.accent,
              isOwned: request.item.source.isOwned,
            ),
            const SizedBox(height: 16),
            LibraryTitleMetadataSection(
              type: request.type,
              item: request.item,
              ownedReleaseCount: releases
                  .where((release) => release.ownedCopies.isNotEmpty)
                  .length,
              onFilterByValue: request.onFilterByValue,
            ),
            const SizedBox(height: 16),
            if (kindMediaContribution != null)
              kindMediaContribution
            else if (releaseSource == null)
              const SizedBox.shrink()
            else if (selectedRelease != null)
              Builder(
                builder: (context) {
                  final activeRelease = selectedRelease!;
                  return _LibraryReleaseBrowserSection(
                    accent: request.accent,
                    releaseSource: releaseSource,
                    digitalFlagResolver:
                        request.type.ownedEdit.resolveOwnedDigitalFlag,
                    collectionValueReader:
                        request.type.ownedEdit.readOwnedCollectionValue,
                    ownedItemDispatch: request.ownedItemDispatch,
                    releases: releases,
                    selectedReleaseId: activeRelease.node.id,
                    selectedOwnedItemRef: selectedOwnedCopy?.ref,
                    onSelectRelease: (value) =>
                        setState(() => _selectedReleaseNodeId = value),
                    onSelectOwnedItem: (releaseId, ownedItemRef) {
                      setState(() {
                        _selectedOwnedItemRefByRelease[releaseId] =
                            ownedItemRef;
                      });
                    },
                    onAddCopy: _addCopyForRelease,
                    onAddWishlist: () => _addWishlistForRelease(activeRelease),
                    onRemoveWishlist: activeRelease.wishlistItem == null
                        ? null
                        : () => _removeWishlistForRelease(activeRelease),
                    onEditCopy:
                        request.onEdit == null || selectedOwnedCopy == null
                            ? null
                            : () => request.onEdit!(selectedOwnedCopy),
                    onRemoveCopy: selectedOwnedCopy == null
                        ? null
                        : () => _removeSelectedCopy(activeRelease),
                  );
                },
              )
            else
              _LibraryReleaseBrowserSection(
                accent: request.accent,
                releaseSource: releaseSource,
                digitalFlagResolver:
                    request.type.ownedEdit.resolveOwnedDigitalFlag,
                collectionValueReader:
                    request.type.ownedEdit.readOwnedCollectionValue,
                ownedItemDispatch: request.ownedItemDispatch,
                releases: releases,
                selectedReleaseId: _selectedReleaseNodeId ??
                    (releases.isEmpty ? null : releases.first.node.id),
                selectedOwnedItemRef: null,
                onSelectRelease: (value) =>
                    setState(() => _selectedReleaseNodeId = value),
                onSelectOwnedItem: (releaseId, ownedItemRef) {
                  setState(() {
                    _selectedOwnedItemRefByRelease[releaseId] = ownedItemRef;
                  });
                },
                onAddCopy: _addCopyForRelease,
                onAddWishlist: null,
                onRemoveWishlist: null,
                onEditCopy: null,
                onRemoveCopy: null,
              ),
            const SizedBox(height: 16),
            LibraryDetailCreditsSection(
              type: request.type,
              item: request.item,
              accent: request.accent,
              onFilterByValue: request.onFilterByValue,
            ),
            const SizedBox(height: 16),
            LibraryDetailProviderSection(
              type: request.type,
              accent: request.accent,
              onFilterByValue: request.onFilterByValue,
            ),
            const SizedBox(height: 16),
            WatchHistorySection(
              catalogRef: itemRef,
              accent: request.accent,
              defaultTargetRef: itemRef,
              targetOptions: watchHistoryTargets,
            ),
            LibraryMetadataCorrectionsSection(
              targetRef: itemRef,
              accent: request.accent,
            ),
          ],
        ),
      ),
    );
  }
}

List<LibraryNodeRef> _releaseNodesFor(
  LibraryProjectionView item, {
  required LibraryReleaseDetailSource? source,
}) {
  final catalogItem = item.source.catalogSnapshot;
  if (catalogItem == null || source == null) return const [];
  final resolvedEditions = source.resolveCatalogItem(catalogItem);
  final nodes = <LibraryNodeRef>[];
  for (final edition in resolvedEditions) {
    nodes.add(
      LibraryReleaseNodeRef(
        titleItemId: item.node.titleItemId,
        releaseId: edition.id,
        edition: edition,
      ),
    );
  }
  return nodes;
}

List<_ResolvedLibraryRelease> _resolvedReleasesFor(
  LibraryProjectionView item, {
  required LibraryReleaseDetailSource? source,
  required List<OwnedItemSummary> ownedCopies,
  required List<WishlistItem> wishlistItems,
}) {
  final catalogItem = item.source.catalogSnapshot;
  if (catalogItem == null || source == null) return const [];
  final resolvedEditions = source.resolveCatalogItem(
    catalogItem,
    ownedItems: ownedCopies,
    wishlistItems: wishlistItems,
  );
  return [
    for (final edition in resolvedEditions)
      _buildResolvedLibraryRelease(
        item,
        edition,
        source: source,
        editions: resolvedEditions,
        ownedCopies: ownedCopies,
        wishlistItems: wishlistItems,
      ),
  ];
}

_ResolvedLibraryRelease _buildResolvedLibraryRelease(
  LibraryProjectionView item,
  CatalogEditionDto edition, {
  required LibraryReleaseDetailSource source,
  required List<CatalogEditionDto> editions,
  required List<OwnedItemSummary> ownedCopies,
  required List<WishlistItem> wishlistItems,
}) {
  final matchedOwnedCopies = ownedCopies.where((copy) {
    final targetRef = copy.targetRef;
    return targetRef != null && source.matchesTarget(targetRef, edition);
  }).toList(growable: false)
    ..sort(
      (left, right) => (right.updatedAt ?? DateTime(0)).compareTo(
        left.updatedAt ?? DateTime(0),
      ),
    );
  WishlistItem? matchedWishlist;
  for (final wish in wishlistItems) {
    if (source.matchesTarget(wish.catalogRef, edition)) {
      matchedWishlist = wish;
      break;
    }
  }
  final node = LibraryReleaseNodeRef(
    titleItemId: item.node.titleItemId,
    releaseId: edition.id,
    edition: edition,
  );
  return _ResolvedLibraryRelease(
    node: node,
    edition: edition,
    ownedCopies: matchedOwnedCopies,
    wishlistItem: matchedWishlist,
    sourceLabel: source.sourceLabel(edition),
  );
}

class _ResolvedLibraryRelease {
  const _ResolvedLibraryRelease({
    required this.node,
    required this.edition,
    required this.ownedCopies,
    required this.wishlistItem,
    required this.sourceLabel,
  });

  final LibraryReleaseNodeRef node;
  final CatalogEditionDto edition;
  final List<OwnedItemSummary> ownedCopies;
  final WishlistItem? wishlistItem;
  final String sourceLabel;

  int get totalQuantity =>
      ownedCopies.fold<int>(0, (sum, item) => sum + item.quantity);

  String get ownershipLabel {
    if (ownedCopies.isEmpty) {
      return wishlistItem == null ? 'No copies yet' : 'Wishlisted release';
    }
    if (ownedCopies.length == 1 && totalQuantity <= 1) {
      return '1 copy in collection';
    }
    if (totalQuantity == ownedCopies.length) {
      return '${ownedCopies.length} copies in collection';
    }
    return '${ownedCopies.length} copies in collection Ãƒâ€šÃ‚Â· Qty $totalQuantity';
  }
}

class _LibraryReleaseBrowserSection extends StatelessWidget {
  const _LibraryReleaseBrowserSection({
    required this.accent,
    required this.releaseSource,
    required this.digitalFlagResolver,
    required this.collectionValueReader,
    required this.ownedItemDispatch,
    required this.releases,
    required this.selectedReleaseId,
    required this.selectedOwnedItemRef,
    required this.onSelectRelease,
    required this.onSelectOwnedItem,
    required this.onAddCopy,
    this.onAddWishlist,
    this.onRemoveWishlist,
    this.onEditCopy,
    this.onRemoveCopy,
  });

  final Color accent;
  final LibraryReleaseDetailSource releaseSource;
  final LibraryOwnedDigitalFlagResolver digitalFlagResolver;
  final String? Function(LibraryOwnedItemDispatch?) collectionValueReader;
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final List<_ResolvedLibraryRelease> releases;
  final String? selectedReleaseId;
  final OwnedItemRef? selectedOwnedItemRef;
  final ValueChanged<String> onSelectRelease;
  final void Function(String releaseId, OwnedItemRef? ownedItemRef)
      onSelectOwnedItem;
  final Future<void> Function(_ResolvedLibraryRelease release) onAddCopy;
  final Future<void> Function()? onAddWishlist;
  final Future<void> Function()? onRemoveWishlist;
  final VoidCallback? onEditCopy;
  final VoidCallback? onRemoveCopy;

  @override
  Widget build(BuildContext context) {
    _ResolvedLibraryRelease? selectedRelease;
    for (final release in releases) {
      if (release.node.id == selectedReleaseId) {
        selectedRelease = release;
        break;
      }
    }
    selectedRelease ??= releases.isEmpty ? null : releases.first;
    final hasCatalogReleases = releases.any(
      (release) => releaseSource.isCatalogRelease(release.edition),
    );
    return LibraryDetailSection(
      title: 'Releases',
      accentColor: accent,
      children: [
        if (releases.isEmpty)
          Text(
            'Core has not returned any release records for this title yet. Add a copy or a wishlist entry when you need a local anchor, or refresh the title after editions are available upstream.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appPalette(context).textMuted,
                ),
          )
        else
          Column(
            children: [
              if (!hasCatalogReleases) ...[
                _LibraryReleaseSourceNotice(
                  releases: releases,
                  releaseSource: releaseSource,
                  accent: accent,
                ),
                const SizedBox(height: 12),
              ],
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 284,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: releases.length,
                itemBuilder: (context, index) {
                  final release = releases[index];
                  return _LibraryReleaseTile(
                    release: release,
                    accent: accent,
                    selected: release.node.id == selectedReleaseId,
                    onTap: () => onSelectRelease(release.node.id),
                  );
                },
              ),
              if (selectedRelease != null) ...[
                const SizedBox(height: 12),
                _LibraryReleaseActionsPanel(
                  release: selectedRelease,
                  digitalFlagResolver: digitalFlagResolver,
                  collectionValueReader: collectionValueReader,
                  ownedItemDispatch: ownedItemDispatch,
                  selectedOwnedItemRef: selectedOwnedItemRef,
                  accent: accent,
                  onSelectOwnedItem: (value) =>
                      onSelectOwnedItem(selectedRelease!.node.id, value),
                  onAddCopy: () => onAddCopy(selectedRelease!),
                  onAddWishlist: onAddWishlist,
                  onRemoveWishlist: onRemoveWishlist,
                  onEditCopy: onEditCopy,
                  onRemoveCopy: onRemoveCopy,
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _LibraryReleaseSourceNotice extends StatelessWidget {
  const _LibraryReleaseSourceNotice({
    required this.releases,
    required this.releaseSource,
    required this.accent,
  });

  final List<_ResolvedLibraryRelease> releases;
  final LibraryReleaseDetailSource releaseSource;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final noticeColor = Color.alphaBlend(
      accent.withValues(alpha: 0.12),
      palette.surfaceSubtle.withValues(alpha: 0.96),
    );
    final noticeTextColor =
        ThemeData.estimateBrightnessForColor(noticeColor) == Brightness.dark
            ? Colors.white
            : palette.textPrimary;
    final hasSnapshotFallback = releases.any(
      (release) => releaseSource.isTitleSnapshotRelease(release.edition),
    );
    final message = hasSnapshotFallback
        ? 'Core has not returned release records for this title yet. You are browsing a local title snapshot so copies and wishlist entries can still stay anchored to one release.'
        : 'Core has not returned release records for this title yet. These releases were reconstructed from your local owned and wishlist anchors.';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: noticeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: noticeTextColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryReleaseTile extends StatelessWidget {
  const _LibraryReleaseTile({
    required this.release,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final _ResolvedLibraryRelease release;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = appPalette(context);
    final borderColor =
        selected ? accent.withValues(alpha: 0.85) : palette.divider;
    return Material(
      color: selected ? accent.withValues(alpha: 0.16) : palette.panel,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LibraryCoverImage(
                    title: release.edition.title,
                    imageUrl: null,
                    ownedRef: release.ownedCopies.isEmpty
                        ? null
                        : release.ownedCopies.first.ref,
                    borderRadius: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                release.edition.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                release.ownershipLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      release.sourceLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (release.wishlistItem != null)
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryReleaseActionsPanel extends StatelessWidget {
  const _LibraryReleaseActionsPanel({
    required this.release,
    required this.digitalFlagResolver,
    required this.collectionValueReader,
    required this.ownedItemDispatch,
    required this.selectedOwnedItemRef,
    required this.accent,
    required this.onSelectOwnedItem,
    required this.onAddCopy,
    this.onAddWishlist,
    this.onRemoveWishlist,
    this.onEditCopy,
    this.onRemoveCopy,
  });

  final _ResolvedLibraryRelease release;
  final LibraryOwnedDigitalFlagResolver digitalFlagResolver;
  final String? Function(LibraryOwnedItemDispatch?) collectionValueReader;
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final OwnedItemRef? selectedOwnedItemRef;
  final Color accent;
  final ValueChanged<OwnedItemRef?> onSelectOwnedItem;
  final Future<void> Function() onAddCopy;
  final Future<void> Function()? onAddWishlist;
  final Future<void> Function()? onRemoveWishlist;
  final VoidCallback? onEditCopy;
  final VoidCallback? onRemoveCopy;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${release.edition.title} Ãƒâ€šÃ‚Â· ${release.ownershipLabel}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Source: ${release.sourceLabel}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
            if (release.ownedCopies.isNotEmpty) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<OwnedItemRef>(
                initialValue: release.ownedCopies.any(
                  (copy) => copy.ref == selectedOwnedItemRef,
                )
                    ? selectedOwnedItemRef
                    : release.ownedCopies.first.ref,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Selected copy',
                ),
                items: [
                  for (var index = 0;
                      index < release.ownedCopies.length;
                      index += 1)
                    DropdownMenuItem<OwnedItemRef>(
                      value: release.ownedCopies[index].ref,
                      child: Text(
                        buildOwnedCopyLabel(
                          release.ownedCopies[index],
                          [release.edition],
                          index,
                          digitalFlagResolver: digitalFlagResolver,
                          collectionValue:
                              collectionValueReader(ownedItemDispatch),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onSelectOwnedItem,
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onAddCopy,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add copy'),
                ),
                if (release.wishlistItem != null)
                  OutlinedButton.icon(
                    onPressed: onRemoveWishlist,
                    icon: const Icon(Icons.star),
                    label: const Text('Remove wishlist'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: onAddWishlist,
                    icon: const Icon(Icons.star_border),
                    label: const Text('Move to wishlist'),
                  ),
                if (onEditCopy != null)
                  OutlinedButton.icon(
                    onPressed: onEditCopy,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit copy'),
                  ),
                if (onRemoveCopy != null)
                  OutlinedButton.icon(
                    onPressed: onRemoveCopy,
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Remove copy'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
