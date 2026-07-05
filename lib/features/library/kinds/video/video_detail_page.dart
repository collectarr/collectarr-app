import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/video/video_metadata_corrections_section.dart';
import 'package:collectarr_app/features/library/kinds/video/video_release_source.dart';
import 'package:collectarr_app/features/library/kinds/video/video_season_tracking_section.dart';
import 'package:collectarr_app/features/library/kinds/video/video_episode_rating_section.dart';
import 'package:collectarr_app/features/library/kinds/video/watch_history_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_node.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildVideoLibraryDetailPage(
  BuildContext context,
  LibraryDetailPageRequest request,
) {
  return VideoLibraryDetailPage(request: request);
}

class VideoLibraryDetailPage extends ConsumerStatefulWidget {
  const VideoLibraryDetailPage({super.key, required this.request});

  final LibraryDetailPageRequest request;

  @override
  ConsumerState<VideoLibraryDetailPage> createState() =>
      _VideoLibraryDetailPageState();
}

class _VideoLibraryDetailPageState extends ConsumerState<VideoLibraryDetailPage> {
  String? _selectedReleaseNodeId;
  final Map<String, String?> _selectedOwnedItemIdByRelease = <String, String?>{};
  Future<TvSeries?>? _tvSeriesFuture;
  TvSeries? _tvSeriesSnapshot;

  @override
  void initState() {
    super.initState();
    final nodes = _releaseNodesFor(widget.request.type, widget.request.entry);
    _selectedReleaseNodeId = nodes.isEmpty ? null : nodes.first.id;
    if (_isTvKind && widget.request.entry.canHydrateFromCore) {
      _tvSeriesFuture = _loadTvSeriesSnapshot();
    }
  }

  @override
  void didUpdateWidget(covariant VideoLibraryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.entry.id != widget.request.entry.id) {
      final nodes = _releaseNodesFor(widget.request.type, widget.request.entry);
      _selectedReleaseNodeId = nodes.isEmpty ? null : nodes.first.id;
      _selectedOwnedItemIdByRelease.clear();
      if (oldWidget.request.entry.canonicalItemId !=
          widget.request.entry.canonicalItemId) {
        _tvSeriesSnapshot = null;
        if (_isTvKind && widget.request.entry.canHydrateFromCore) {
          _tvSeriesFuture = _loadTvSeriesSnapshot();
        }
      }
    }
  }

  bool get _isTvKind => widget.request.type.workspace.kind.apiValue == 'tv';

  Future<TvSeries?> _loadTvSeriesSnapshot() async {
    if (!widget.request.entry.canHydrateFromCore) {
      return null;
    }
    final api = ref.read(apiClientProvider);
    final dto = await api.getTvSeriesDto(widget.request.entry.canonicalItemId);
    return TvSeries.fromDto(dto);
  }

  Future<void> _addCopyForRelease(_ResolvedVideoRelease release) async {
    final anchor = videoReleaseAnchorForEdition(release.edition);
    await ref.read(collectionMutationsProvider).addItem(
          widget.request.entry.canonicalItemId,
          editionId: anchor.editionId,
          variantId: anchor.variantId,
          bundleReleaseId: anchor.bundleReleaseId,
        );
  }

  Future<void> _removeSelectedCopy(_ResolvedVideoRelease release) async {
    final selectedCopy = _selectedOwnedCopyFor(release);
    if (selectedCopy == null) {
      return;
    }
    await ref.read(collectionMutationsProvider).removeItem(selectedCopy);
  }

  Future<void> _addWishlistForRelease(_ResolvedVideoRelease release) async {
    final anchor = videoReleaseAnchorForEdition(release.edition);
    await ref.read(collectionMutationsProvider).addToWishlist(
          widget.request.entry.canonicalItemId,
          editionId: anchor.editionId,
          variantId: anchor.variantId,
          bundleReleaseId: anchor.bundleReleaseId,
        );
  }

  Future<void> _removeWishlistForRelease(_ResolvedVideoRelease release) async {
    final wishlistItem = release.wishlistItem;
    if (wishlistItem == null) {
      return;
    }
    await ref.read(collectionMutationsProvider).removeFromWishlist(
          widget.request.entry.id,
          wishlistItemId: wishlistItem.id,
        );
  }

  OwnedItem? _selectedOwnedCopyFor(_ResolvedVideoRelease release) {
    if (release.ownedCopies.isEmpty) {
      return null;
    }
    final selectedId = _selectedOwnedItemIdByRelease[release.node.id];
    if (selectedId != null) {
      for (final copy in release.ownedCopies) {
        if (copy.id == selectedId) {
          return copy;
        }
      }
    }
    return release.ownedCopies.first;
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final ownedCopiesValue = ref.watch(collectionProvider);
    final wishlistValue = ref.watch(wishlistProvider);
    final ownedCopies = ownedCopiesValue.maybeWhen(
      data: (items) => items
          .where(
            (item) =>
                !item.isDeleted && item.itemId == request.entry.canonicalItemId,
          )
          .toList(growable: false),
      orElse: () => const <OwnedItem>[],
    );
    final wishlistItems = wishlistValue.maybeWhen(
      data: (items) => items
          .where(
            (item) =>
                !item.isDeleted && item.itemId == request.entry.canonicalItemId,
          )
          .toList(growable: false),
      orElse: () => const <WishlistItem>[],
    );
    final releases = _resolvedReleasesFor(
      request.type,
      request.entry,
      ownedCopies: ownedCopies,
      wishlistItems: wishlistItems,
    );
    final seriesRef = CatalogEntityRef(
      kind: request.type.workspace.kind.apiValue,
      entityType: CatalogEntityType.work,
      id: request.entry.canonicalItemId,
    );
    final seasonsAsync = ref.watch(seasonsByCatalogRefProvider(seriesRef));
    final watchHistoryTargets = <WatchHistoryTargetOption>[
      WatchHistoryTargetOption(
        ref: seriesRef,
        label: 'Series',
        subtitle: request.entry.resolvedTitle,
      ),
      ...seasonsAsync.maybeWhen(
        data: (seasons) => [
          for (final season in seasons) ...[
            WatchHistoryTargetOption(
              ref: CatalogEntityRef(
                kind: seriesRef.kind,
                entityType: CatalogEntityType.season,
                id: '${seriesRef.id}:season:${season.seasonNumber}',
              ),
              label: season.title,
              subtitle: 'Season ${season.seasonNumber}',
              seasonNumber: season.seasonNumber,
            ),
            for (final episode in season.episodes)
              WatchHistoryTargetOption(
                ref: CatalogEntityRef(
                  kind: seriesRef.kind,
                  entityType: CatalogEntityType.episode,
                  id:
                      '${seriesRef.id}:season:${season.seasonNumber}:episode:${episode.episodeNumber}',
                ),
                label: episode.title,
                subtitle:
                    'Season ${season.seasonNumber} • Episode ${episode.episodeNumber}',
                seasonNumber: season.seasonNumber,
                episodeNumber: episode.episodeNumber,
              ),
          ],
        ],
        orElse: () => const <WatchHistoryTargetOption>[],
      ),
      ...releases.map(
        (release) => WatchHistoryTargetOption(
          ref: CatalogEntityRef(
            kind: seriesRef.kind,
            entityType: CatalogEntityType.release,
            id: release.node.id,
          ),
          label: release.node.entry.displayTitle ?? release.node.entry.title,
          subtitle: release.node.entry.itemNumber ?? release.node.entry.variant,
        ),
      ),
    ];
    _ResolvedVideoRelease? selectedRelease;
    for (final release in releases) {
      if (release.node.id == _selectedReleaseNodeId) {
        selectedRelease = release;
        break;
      }
    }
    selectedRelease ??= releases.isEmpty ? null : releases.first;
    final selectedOwnedCopy = selectedRelease == null
        ? null
        : _selectedOwnedCopyFor(selectedRelease);
    final tvReleaseBrowser = _isTvKind
        ? FutureBuilder<TvSeries?>(
            future: _tvSeriesFuture,
            builder: (context, snapshot) {
              final series = snapshot.data ?? _tvSeriesSnapshot;
              if (series == null) {
                return const SizedBox.shrink();
              }
              _tvSeriesSnapshot = series;
              return _TvReleaseBrowserSection(
                series: series,
                accent: request.accent,
              );
            },
          )
        : null;
    final appBarForeground =
        ThemeData.estimateBrightnessForColor(request.accent) == Brightness.dark
            ? Colors.white
            : Colors.black87;
    return Theme(
      data: buildLibraryTheme(palette: appPalette(context)),
      child: Scaffold(
        backgroundColor: appPalette(context).canvas,
        appBar: AppBar(
          backgroundColor: request.accent,
          foregroundColor: appBarForeground,
          title: Text(request.entry.resolvedTitle),
          actions: [
            IconButton(
              tooltip: 'Edit metadata and collection fields',
              onPressed: request.onEdit == null
                  ? null
                  : () => request.onEdit!(request.ownedItem),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LibraryDetailHero(
              type: request.type,
              entry: request.entry,
              ownedItem: request.ownedItem,
              accent: request.accent,
              isOwned: request.entry.isOwned,
            ),
            const SizedBox(height: 16),
            InspectorVideoTitleMetadataSection(
              type: request.type,
              entry: request.entry,
              accent: request.accent,
              ownedReleaseCount: releases.where((release) => release.ownedCopies.isNotEmpty).length,
              onFilterByValue: request.onFilterByValue,
            ),
            const SizedBox(height: 16),
            VideoSeasonTrackingSection(
              seriesRef: CatalogEntityRef(
                kind: request.type.workspace.kind.apiValue,
                entityType: CatalogEntityType.work,
                id: request.entry.id,
              ),
              kind: request.type.workspace.kind.apiValue,
              accent: request.accent,
            ),
            const SizedBox(height: 16),
            VideoEpisodeRatingDisplaySection(
              itemId: request.entry.id,
              kind: request.type.workspace.kind.apiValue,
              accent: request.accent,
            ),
            const SizedBox(height: 16),
            if (tvReleaseBrowser != null)
              tvReleaseBrowser
            else if (selectedRelease != null)
              Builder(
                builder: (context) {
                  final activeRelease = selectedRelease!;
                  return _VideoReleaseBrowserSection(
                    accent: request.accent,
                    releases: releases,
                    selectedReleaseId: activeRelease.node.id,
                    selectedOwnedItemId: selectedOwnedCopy?.id,
                    onSelectRelease: (value) =>
                        setState(() => _selectedReleaseNodeId = value),
                    onSelectOwnedItem: (releaseId, ownedItemId) {
                      setState(() {
                        _selectedOwnedItemIdByRelease[releaseId] = ownedItemId;
                      });
                    },
                    onAddCopy: _addCopyForRelease,
                    onAddWishlist: () => _addWishlistForRelease(activeRelease),
                    onRemoveWishlist: activeRelease.wishlistItem == null
                        ? null
                        : () => _removeWishlistForRelease(activeRelease),
                    onEditCopy: request.onEdit == null || selectedOwnedCopy == null
                        ? null
                        : () => request.onEdit!(selectedOwnedCopy),
                    onRemoveCopy: selectedOwnedCopy == null
                        ? null
                        : () => _removeSelectedCopy(activeRelease),
                  );
                },
              )
            else
              _VideoReleaseBrowserSection(
                accent: request.accent,
                releases: releases,
                selectedReleaseId:
                    _selectedReleaseNodeId ?? (releases.isEmpty ? null : releases.first.node.id),
                selectedOwnedItemId: null,
                onSelectRelease: (value) =>
                    setState(() => _selectedReleaseNodeId = value),
                onSelectOwnedItem: (releaseId, ownedItemId) {
                  setState(() {
                    _selectedOwnedItemIdByRelease[releaseId] = ownedItemId;
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
              entry: request.entry,
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
              itemId: request.entry.id,
              accent: request.accent,
              defaultTargetRef: seriesRef,
              targetOptions: watchHistoryTargets,
            ),
            VideoMetadataCorrectionsSection(
              itemId: request.entry.id,
              accent: request.accent,
            ),
          ],
        ),
      ),
    );
  }
}

List<LibraryBrowserNode> _releaseNodesFor(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
) {
  final resolvedEditions = resolveVideoCatalogEditionsForEntry(entry);
  final nodes = <LibraryBrowserNode>[];
  for (final edition in resolvedEditions) {
    final releaseEntry = type.presentation.releaseEntryBuilder(
      LibraryReleaseEntryRequest(
        titleEntry: entry,
        edition: edition,
        referenceEditionId: edition.id,
        referenceVariantId: preferredVideoEditionVariantId(edition),
        editions: resolvedEditions,
        updatedAt: entry.updatedAt,
      ),
    );
    nodes.add(
      LibraryBrowserNode(
        id: releaseEntry.id,
        scope: releaseEntry.browseScope,
        entry: releaseEntry,
        titleItemId: entry.id,
        releaseId: edition.id,
        edition: edition,
      ),
    );
  }
  return nodes;
}

List<_ResolvedVideoRelease> _resolvedReleasesFor(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry, {
  required List<OwnedItem> ownedCopies,
  required List<WishlistItem> wishlistItems,
}) {
  final resolvedEditions = resolveVideoCatalogEditionsForEntry(
    entry,
    ownedItems: ownedCopies,
    wishlistItems: wishlistItems,
  );
  return [
    for (final edition in resolvedEditions)
      _buildResolvedVideoRelease(
        type,
        entry,
        edition,
        editions: resolvedEditions,
        ownedCopies: ownedCopies,
        wishlistItems: wishlistItems,
      ),
  ];
}

_ResolvedVideoRelease _buildResolvedVideoRelease(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
  CatalogEdition edition, {
  required List<CatalogEdition> editions,
  required List<OwnedItem> ownedCopies,
  required List<WishlistItem> wishlistItems,
}) {
  final matchedOwnedCopies = ownedCopies
      .where((copy) => _matchesReleaseAnchor(copy, edition))
      .toList(growable: false)
    ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  WishlistItem? matchedWishlist;
  for (final item in wishlistItems) {
    if (_matchesReleaseAnchor(item, edition)) {
      matchedWishlist = item;
      break;
    }
  }
  final releaseEntry = type.presentation.releaseEntryBuilder(
    LibraryReleaseEntryRequest(
      titleEntry: entry,
      edition: edition,
      isOwned: matchedOwnedCopies.isNotEmpty,
      isWishlisted: matchedWishlist != null,
      referenceEditionId: edition.id,
      referenceVariantId: preferredVideoEditionVariantId(edition),
      editions: editions,
      updatedAt: entry.updatedAt,
    ),
  );
  final node = LibraryBrowserNode(
    id: releaseEntry.id,
    scope: releaseEntry.browseScope,
    entry: releaseEntry,
    titleItemId: entry.id,
    releaseId: edition.id,
    edition: edition,
  );
  return _ResolvedVideoRelease(
    node: node,
    entry: releaseEntry,
    edition: edition,
    ownedCopies: matchedOwnedCopies,
    wishlistItem: matchedWishlist,
    sourceLabel: videoReleaseSourceLabel(edition),
  );
}

bool _matchesReleaseAnchor(Object item, CatalogEdition edition) {
  final anchor = videoReleaseAnchorForEdition(edition);
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  if (item is OwnedItem) {
    editionId = item.editionId;
    variantId = item.variantId;
    bundleReleaseId = item.bundleReleaseId;
  } else if (item is WishlistItem) {
    editionId = item.editionId;
    variantId = item.variantId;
    bundleReleaseId = item.bundleReleaseId;
  } else {
    return false;
  }
  if (anchor.editionId != null && anchor.editionId == editionId) {
    return true;
  }
  if (anchor.variantId != null) {
    return anchor.variantId == variantId || edition.id == editionId;
  }
  if (anchor.bundleReleaseId != null) {
    return anchor.bundleReleaseId == bundleReleaseId || edition.id == editionId;
  }
  return (editionId == null || editionId.trim().isEmpty) &&
      (variantId == null || variantId.trim().isEmpty) &&
      (bundleReleaseId == null || bundleReleaseId.trim().isEmpty);
}

class _ResolvedVideoRelease {
  const _ResolvedVideoRelease({
    required this.node,
    required this.entry,
    required this.edition,
    required this.ownedCopies,
    required this.wishlistItem,
    required this.sourceLabel,
  });

  final LibraryBrowserNode node;
  final LibraryWorkspaceEntry entry;
  final CatalogEdition edition;
  final List<OwnedItem> ownedCopies;
  final WishlistItem? wishlistItem;
  final String sourceLabel;

  int get totalQuantity => ownedCopies.fold<int>(0, (sum, item) => sum + item.quantity);

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
    return '${ownedCopies.length} copies in collection · Qty $totalQuantity';
  }
}

class _TvReleaseBrowserSection extends StatefulWidget {
  const _TvReleaseBrowserSection({
    required this.series,
    required this.accent,
  });

  final TvSeries series;
  final Color accent;

  @override
  State<_TvReleaseBrowserSection> createState() =>
      _TvReleaseBrowserSectionState();
}

class _TvReleaseBrowserSectionState extends State<_TvReleaseBrowserSection> {
  String? _selectedReleaseId;
  final Map<String, String?> _selectedMediaIdByRelease = <String, String?>{};

  @override
  void initState() {
    super.initState();
    _selectedReleaseId =
        widget.series.releases.isEmpty ? null : widget.series.releases.first.id;
  }

  @override
  void didUpdateWidget(covariant _TvReleaseBrowserSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series.id != widget.series.id) {
      _selectedReleaseId =
          widget.series.releases.isEmpty ? null : widget.series.releases.first.id;
      _selectedMediaIdByRelease.clear();
    } else if (_selectedReleaseId != null &&
        widget.series.releases.every((release) => release.id != _selectedReleaseId)) {
      _selectedReleaseId =
          widget.series.releases.isEmpty ? null : widget.series.releases.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final releases = widget.series.releases;
    final releaseEntries = buildTvReleaseWorkspaceEntries(
      series: widget.series,
      overlay: TvPersonalOverlay(
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    TvRelease? selectedRelease;
    LibraryWorkspaceEntry? selectedReleaseEntry;
    for (var index = 0; index < releases.length; index += 1) {
      final release = releases[index];
      if (release.id == _selectedReleaseId) {
        selectedRelease = release;
        selectedReleaseEntry = releaseEntries[index];
        break;
      }
    }
    selectedRelease ??= releases.isEmpty ? null : releases.first;
    if (selectedReleaseEntry == null && selectedRelease != null) {
      final selectedIndex = releases.indexWhere((release) => release.id == selectedRelease!.id);
      if (selectedIndex >= 0 && selectedIndex < releaseEntries.length) {
        selectedReleaseEntry = releaseEntries[selectedIndex];
      }
    }
    final palette = appPalette(context);
    return LibraryInspectorSection(
      title: 'Releases / discs',
      accentColor: widget.accent,
      children: [
        if (releases.isEmpty)
          Text(
            'No TV releases were returned for this series yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textMuted,
                ),
          )
        else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 230,
              mainAxisExtent: 172,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: releases.length,
            itemBuilder: (context, index) {
              final release = releases[index];
              final releaseEntry = releaseEntries[index];
              return _TvReleaseTile(
                entry: releaseEntry,
                release: release,
                accent: widget.accent,
                selected: release.id == _selectedReleaseId,
                onTap: () => setState(() => _selectedReleaseId = release.id),
              );
            },
          ),
          if (selectedRelease != null && selectedReleaseEntry != null) ...[
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final release = selectedRelease!;
                final releaseEntry = selectedReleaseEntry!;
                final releaseId = release.id;
                return _TvReleaseDetailsPanel(
                  series: widget.series,
                  release: release,
                  releaseEntry: releaseEntry,
                  accent: widget.accent,
                  selectedMediaId: _selectedMediaIdByRelease[releaseId] ??
                      release.media.firstOrNull?.id,
                  onSelectMedia: (mediaId) {
                    setState(() {
                      _selectedMediaIdByRelease[releaseId] = mediaId;
                    });
                  },
                );
              },
            ),
          ],
        ],
      ],
    );
  }
}

class _TvReleaseTile extends StatelessWidget {
  const _TvReleaseTile({
    required this.entry,
    required this.release,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final LibraryWorkspaceEntry entry;
  final TvRelease release;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: selected ? accent.withValues(alpha: 0.16) : palette.panel,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent.withValues(alpha: 0.85) : palette.divider,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LibraryCoverImage(
                    title: entry.displayTitle ?? entry.title,
                    imageUrl: entry.coverImageUrl,
                    borderRadius: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                entry.displayTitle ?? entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (entry.itemNumber?.trim().isNotEmpty == true) entry.itemNumber!,
                  '${release.media.length} media',
                  '${release.episodeMappings.length} maps',
                ].join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TvReleaseDetailsPanel extends StatelessWidget {
  const _TvReleaseDetailsPanel({
    required this.series,
    required this.release,
    required this.releaseEntry,
    required this.accent,
    required this.selectedMediaId,
    required this.onSelectMedia,
  });

  final TvSeries series;
  final TvRelease release;
  final LibraryWorkspaceEntry releaseEntry;
  final Color accent;
  final String? selectedMediaId;
  final ValueChanged<String> onSelectMedia;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selectedMedia = release.media.isEmpty
        ? null
        : release.media.firstWhere(
            (media) => media.id == selectedMediaId,
            orElse: () => release.media.first,
          );
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
              releaseEntry.displayTitle ?? releaseEntry.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (release.releaseDate != null)
                  release.releaseDate!.toLocal().toIso8601String().split('T').first,
                if (release.country?.trim().isNotEmpty == true) release.country!,
                if (release.language?.trim().isNotEmpty == true) release.language!,
              ].join(' • '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final media in release.media)
                  ChoiceChip(
                    label: Text(
                      media.title ?? media.formatLabel ?? 'Disc ${media.discNumber ?? 1}',
                    ),
                    selected: selectedMedia?.id == media.id,
                    selectedColor: accent.withValues(alpha: 0.24),
                    onSelected: (_) => onSelectMedia(media.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedMedia != null) ...[
              Text(
                selectedMedia.title ?? selectedMedia.formatLabel ?? 'Disc ${selectedMedia.discNumber ?? 1}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                [
                  if (selectedMedia.formatLabel?.trim().isNotEmpty == true)
                    selectedMedia.formatLabel!,
                  if (selectedMedia.discNumber != null)
                    'Disc ${selectedMedia.discNumber}',
                  '${selectedMedia.episodes.length} episodes',
                ].join(' • '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
              const SizedBox(height: 8),
              if (selectedMedia.episodes.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final episode in selectedMedia.episodes)
                      Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(_episodeLabel(series, episode)),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              if (release.episodeMappings.isNotEmpty)
                _TvEpisodeMapList(
                  series: series,
                  release: release,
                  media: selectedMedia,
                  accent: accent,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TvEpisodeMapList extends StatelessWidget {
  const _TvEpisodeMapList({
    required this.series,
    required this.release,
    required this.media,
    required this.accent,
  });

  final TvSeries series;
  final TvRelease release;
  final TvReleaseMedia media;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final maps = release.episodeMappings
        .where((mapping) => mapping.mediaId == media.id)
        .toList(growable: false);
    if (maps.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Episode map',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final mapping in maps)
              Chip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                label: Text(
                  [
                    if (mapping.discNumber != null) 'Disc ${mapping.discNumber}',
                    if (mapping.sequenceNumber != null) 'Seq ${mapping.sequenceNumber}',
                    _episodeTitleForId(series, mapping.episodeId),
                  ].where((value) => value.trim().isNotEmpty).join(' • '),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String _episodeLabel(TvSeries series, TvEpisode episode) {
  return _episodeTitleForId(series, episode.id).isEmpty
      ? 'S${episode.seasonNumber}E${episode.episodeNumber}'
      : 'S${episode.seasonNumber}E${episode.episodeNumber} • ${_episodeTitleForId(series, episode.id)}';
}

String _episodeTitleForId(TvSeries series, String episodeId) {
  for (final season in series.seasons) {
    for (final episode in season.episodes) {
      if (episode.id == episodeId) {
        return episode.title ?? 'Episode ${episode.episodeNumber}';
      }
    }
  }
  return '';
}

class _VideoReleaseBrowserSection extends StatelessWidget {
  const _VideoReleaseBrowserSection({
    required this.accent,
    required this.releases,
    required this.selectedReleaseId,
    required this.selectedOwnedItemId,
    required this.onSelectRelease,
    required this.onSelectOwnedItem,
    required this.onAddCopy,
    this.onAddWishlist,
    this.onRemoveWishlist,
    this.onEditCopy,
    this.onRemoveCopy,
  });

  final Color accent;
  final List<_ResolvedVideoRelease> releases;
  final String? selectedReleaseId;
  final String? selectedOwnedItemId;
  final ValueChanged<String> onSelectRelease;
  final void Function(String releaseId, String? ownedItemId) onSelectOwnedItem;
  final Future<void> Function(_ResolvedVideoRelease release) onAddCopy;
  final Future<void> Function()? onAddWishlist;
  final Future<void> Function()? onRemoveWishlist;
  final VoidCallback? onEditCopy;
  final VoidCallback? onRemoveCopy;

  @override
  Widget build(BuildContext context) {
    _ResolvedVideoRelease? selectedRelease;
    for (final release in releases) {
      if (release.node.id == selectedReleaseId) {
        selectedRelease = release;
        break;
      }
    }
    selectedRelease ??= releases.isEmpty ? null : releases.first;
    final hasCatalogReleases = releases.any(
      (release) => isCatalogVideoRelease(release.edition),
    );
    return LibraryInspectorSection(
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
                _VideoReleaseSourceNotice(
                  releases: releases,
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
                  return _VideoReleaseTile(
                    release: release,
                    accent: accent,
                    selected: release.node.id == selectedReleaseId,
                    onTap: () => onSelectRelease(release.node.id),
                  );
                },
              ),
              if (selectedRelease != null) ...[
                const SizedBox(height: 12),
                _VideoReleaseActionsPanel(
                  release: selectedRelease,
                  selectedOwnedItemId: selectedOwnedItemId,
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

class _VideoReleaseSourceNotice extends StatelessWidget {
  const _VideoReleaseSourceNotice({
    required this.releases,
    required this.accent,
  });

  final List<_ResolvedVideoRelease> releases;
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
      (release) => isTitleSnapshotVideoRelease(release.edition),
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

class _VideoReleaseTile extends StatelessWidget {
  const _VideoReleaseTile({
    required this.release,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final _ResolvedVideoRelease release;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = appPalette(context);
    final borderColor = selected ? accent.withValues(alpha: 0.85) : palette.divider;
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
                    title: release.entry.resolvedTitle,
                    imageUrl: release.entry.displayCoverUrl,
                    ownedItemId: release.ownedCopies.isEmpty
                        ? null
                        : release.ownedCopies.first.id,
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

class _VideoReleaseActionsPanel extends StatelessWidget {
  const _VideoReleaseActionsPanel({
    required this.release,
    required this.selectedOwnedItemId,
    required this.accent,
    required this.onSelectOwnedItem,
    required this.onAddCopy,
    this.onAddWishlist,
    this.onRemoveWishlist,
    this.onEditCopy,
    this.onRemoveCopy,
  });

  final _ResolvedVideoRelease release;
  final String? selectedOwnedItemId;
  final Color accent;
  final ValueChanged<String?> onSelectOwnedItem;
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
              '${release.edition.title} · ${release.ownershipLabel}',
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
              DropdownButtonFormField<String>(
                initialValue:
                    release.ownedCopies.any(
                      (copy) => copy.id == selectedOwnedItemId,
                    )
                    ? selectedOwnedItemId
                    : release.ownedCopies.first.id,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Selected copy',
                ),
                items: [
                  for (var index = 0; index < release.ownedCopies.length; index += 1)
                    DropdownMenuItem<String>(
                      value: release.ownedCopies[index].id,
                      child: Text(
                        buildOwnedCopyLabel(
                          release.ownedCopies[index],
                          [release.edition],
                          index,
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
