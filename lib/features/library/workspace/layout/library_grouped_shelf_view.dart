import 'dart:math' as math;

import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_presenter.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_summary.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_shelf_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LibraryGroupItemContextMenuCallback = void Function(
  LibraryProjectionItem item,
  Offset globalPosition,
);

final _tvGroupProgressProvider = FutureProvider.autoDispose.family<
    VideoProgressSummary, CatalogEntityRef>((ref, catalogRef) async {
  final seasons = await ref.watch(seasonsByCatalogRefProvider(catalogRef).future);
  final trackedUnits = ref.watch(trackingUnitsByCatalogRefProvider(catalogRef));
  final watchSessions = ref.watch(watchSessionsByCatalogRefProvider(catalogRef));
  return const VideoProgressPresenter().build(
    seasons: seasons,
    trackedUnits: trackedUnits,
    watchSessions: watchSessions,
  );
});

class LibraryGroupedShelfView extends StatelessWidget {
  const LibraryGroupedShelfView({
    super.key,
    required this.type,
    required this.adapter,
    required this.groups,
    required this.viewState,
    required this.selectedId,
    required this.selectionEnabled,
    required this.selectedIds,
    required this.accent,
    required this.onSelectGroupBucket,
    required this.onOpenGroupDetails,
    required this.onActivateItem,
    required this.onToggleSelectionItem,
    required this.onOpenItem,
    required this.onEditItem,
    required this.emptyBuilder,
    this.onItemContextMenu,
    this.onBoxSelectionChanged,
  });

  final LibraryTypeConfig type;
  final LibraryMediaAdapter adapter;
  final List<GroupShelfEntry> groups;
  final LibraryWorkspaceViewState viewState;
  final String? selectedId;
  final bool selectionEnabled;
  final Set<String> selectedIds;
  final Color accent;
  final ValueChanged<String> onSelectGroupBucket;
  final ValueChanged<GroupShelfEntry> onOpenGroupDetails;
  final ValueChanged<String> onActivateItem;
  final ValueChanged<String> onToggleSelectionItem;
  final ValueChanged<LibraryProjectionItem> onOpenItem;
  final ValueChanged<LibraryProjectionItem> onEditItem;
  final WidgetBuilder emptyBuilder;
  final LibraryGroupItemContextMenuCallback? onItemContextMenu;
  final ValueChanged<Set<String>>? onBoxSelectionChanged;

  bool _isActive(LibraryProjectionItem item) => item.entry.id == selectedId;

  bool _isSelected(LibraryProjectionItem item) =>
      selectedIds.contains(item.entry.id);

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return emptyBuilder(context);
    }
    final presentation = groups.first.presentation;
    return switch (presentation) {
      LibraryGroupPresentation.folderGrid => _buildFolderGrid(context),
      LibraryGroupPresentation.inlineHeaders => _buildInlineHeaders(context),
    };
  }

  Widget _buildFolderGrid(BuildContext context) {
    final defaultCoverSize = viewState.coverSize;
    final tileExtent = math.max(208.0, defaultCoverSize * 1.45);
    final folderEntries = [
      for (final group in groups) FolderShelfEntry.fromGroup(group),
    ];
    return LibraryWorkspaceGrid<FolderShelfEntry>(
      items: folderEntries,
      emptyBuilder: emptyBuilder,
      maxCrossAxisExtent: tileExtent,
      mainAxisExtent: tileExtent * 1.08,
      selectionEnabled: false,
      itemIdOf: (item) => item.id,
      backgroundColor: kAppGridCanvas,
      itemBuilder: (context, folder) => LibraryGroupFolderTile(
        group: folder.group,
        accent: accent,
        onTap: () => onSelectGroupBucket(folder.bucket),
        onOpenDetails: () => onOpenGroupDetails(folder.group),
      ),
    );
  }

  Widget _buildInlineHeaders(BuildContext context) {
    final defaultCoverSize = viewState.coverSize;
    final mainAxisExtent =
        defaultCoverSize * adapter.viewProfile.coverGridHeightFactor;
    return ColoredBox(
      color: appPalette(context).gridCanvas,
      child: CustomScrollView(
        slivers: [
          for (final group in groups) ...[
            SliverToBoxAdapter(
              child: _GroupHeader(
                title: group.label,
                count: group.items.length,
                accent: accent,
                onTap: () => onSelectGroupBucket(group.bucket),
                onOpenDetails: () => onOpenGroupDetails(group),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: LibraryWorkspaceGrid<ItemShelfEntry>(
                  items: [
                    for (final item in group.items)
                      ItemShelfEntry(item: item),
                  ],
                  emptyBuilder: emptyBuilder,
                  maxCrossAxisExtent: viewState.coverSize,
                  mainAxisExtent: mainAxisExtent,
                  selectionEnabled: selectionEnabled,
                  selectedIds: selectedIds,
                  itemIdOf: (item) => item.item.entry.id,
                  onSelectionChanged: onBoxSelectionChanged,
                  shrinkWrap: true,
                  scrollable: false,
                  itemBuilder: (context, shelfItem) {
                    final item = shelfItem.item;
                    final child = LibraryCoverTile(
                      key: ValueKey(item.entry.id),
                      entry: item.entry,
                      customFieldBadges: item.customFieldBadges,
                      active: _isActive(item),
                      selected: _isSelected(item),
                      selectionMode: selectionEnabled,
                      onTap: () => onActivateItem(item.entry.id),
                      onSelectionToggleTap: () =>
                          onToggleSelectionItem(item.entry.id),
                      onDoubleTap: () => onOpenItem(item),
                      onEditTap: () => onEditItem(item),
                      onSecondaryTapUp: onItemContextMenu == null
                          ? null
                          : (d) => onItemContextMenu!(item, d.globalPosition),
                      coverSize: viewState.coverSize,
                      selectedColor: appPalette(context).selection,
                      accentColor: accent,
                      selectionColor: accent,
                      mutedTextColor: appPalette(context).textMuted,
                    );
                    return adapter.workspaceCardBuilder == null
                        ? child
                        : adapter.workspaceCardBuilder!(context, item.entry, child);
                  },
                ),
              ),
            ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 10)),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.count,
    required this.accent,
    required this.onTap,
    required this.onOpenDetails,
  });

  final String title;
  final int count;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Icon(Icons.folder_outlined, color: accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: TextStyle(color: palette.textMuted),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Open details',
            onPressed: onOpenDetails,
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
    );
  }
}

class LibraryGroupFolderTile extends ConsumerWidget {
  const LibraryGroupFolderTile({
    super.key,
    required this.group,
    required this.accent,
    required this.onTap,
    required this.onOpenDetails,
  });

  final GroupShelfEntry group;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final entry = group.representativeItem.entry;
    final isTv = collectarrLibraryTypes
        .capabilitiesForKind(entry.mediaType)
        .showsSeasonGroupProgress;
    final catalogRef = CatalogEntityRef(
      kind: entry.mediaType,
      entityType: CatalogEntityType.work,
      id: entry.canonicalItemId,
    );
    final progress = isTv ? ref.watch(_tvGroupProgressProvider(catalogRef)) : null;
    final ownedSeasonCount = group.items
        .where(
          (item) =>
              item.entry.isOwned &&
              (item.entry.itemNumber?.trim().toLowerCase().startsWith('season ') ??
                  false),
        )
        .length;
    final missingSeasonCount = progress == null
        ? 0
        : math.max(progress.maybeWhen(
            data: (summary) => summary.totalSeasons - ownedSeasonCount,
            orElse: () => 0,
          ), 0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onSecondaryTapUp: (_) => onOpenDetails(),
        child: Container(
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: palette.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.22,
                  child: LibraryCoverImage(
                    title: entry.resolvedTitle,
                    imageUrl: entry.thumbnailImageUrl ?? entry.coverImageUrl,
                    borderRadius: 10,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.36),
                        Colors.black.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: palette.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: palette.divider),
                                ),
                                child: LibraryCoverImage(
                                  title: entry.resolvedTitle,
                                  imageUrl:
                                      entry.coverImageUrl ?? entry.thumbnailImageUrl,
                                  borderRadius: 8,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            group.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.resolvedTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Open details',
                                onPressed: onOpenDetails,
                                icon: const Icon(
                                  Icons.open_in_new,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _GroupStats(
                            isTv: isTv,
                            progress: progress,
                            ownedSeasonCount: ownedSeasonCount,
                            missingSeasonCount: missingSeasonCount,
                            totalCount: group.count,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupStats extends StatelessWidget {
  const _GroupStats({
    required this.isTv,
    required this.progress,
    required this.ownedSeasonCount,
    required this.missingSeasonCount,
    required this.totalCount,
  });

  final bool isTv;
  final AsyncValue<VideoProgressSummary>? progress;
  final int ownedSeasonCount;
  final int missingSeasonCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final lines = <String>[
      '$totalCount items',
      if (isTv)
        'Owned seasons: $ownedSeasonCount'
      else
        '$ownedSeasonCount owned',
      if (isTv && progress != null)
        progress!.maybeWhen(
          data: (summary) =>
              '${summary.watchedSummary} · ${summary.completionSummary}',
          orElse: () => '',
        ),
      if (isTv) 'Missing seasons: $missingSeasonCount',
    ].where((line) => line.trim().isNotEmpty).toList(growable: false);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w700,
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final line in lines) ...[
                Text(line, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
