import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/video/video_release_source.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_node.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class VideoShelfReleaseDrilldownItem {
  const VideoShelfReleaseDrilldownItem({
    required this.entry,
    required this.sourceLabel,
    required this.ownedCount,
    required this.wishlistCount,
    required this.node,
  });

  final LibraryWorkspaceEntry entry;
  final String sourceLabel;
  final int ownedCount;
  final int wishlistCount;
  final LibraryBrowserNode node;
}

// ---------------------------------------------------------------------------
// Pure helpers
// ---------------------------------------------------------------------------

bool canOpenVideoShelfDrilldown(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
) {
  if (entry.browseScope != LibraryBrowserScope.title) {
    return false;
  }
  return type.workspaceBehavior.videoShelfDrilldownEntryTypes.contains(
    entry.mediaType.trim().toLowerCase(),
  );
}

List<VideoShelfReleaseDrilldownItem> buildVideoShelfReleaseItems({
  required LibraryProjectionItem titleItem,
  required List<OwnedItem> ownedCopies,
  required List<WishlistItem> wishlistItems,
  required LibraryWorkspaceEntry Function(LibraryReleaseEntryRequest)
      releaseEntryBuilder,
}) {
  final editions = resolveVideoCatalogEditionsForEntry(
    titleItem.entry,
    ownedItems: ownedCopies,
    wishlistItems: wishlistItems,
  );
  final releaseEditions = [
    for (final edition in editions)
      if (ownedCopies.any(
            (item) => matchesVideoReleaseAnchor(
              edition,
              editionId: item.editionId,
              variantId: item.variantId,
              bundleReleaseId: item.bundleReleaseId,
            ),
          ) ||
          wishlistItems.any(
            (item) => matchesVideoReleaseAnchor(
              edition,
              editionId: item.editionId,
              variantId: item.variantId,
              bundleReleaseId: item.bundleReleaseId,
            ),
          ))
        edition,
  ];
  return [
    for (final edition in releaseEditions)
      _buildDrilldownItem(
        titleItem,
        edition,
        editions: releaseEditions,
        ownedCopies: ownedCopies,
        wishlistItems: wishlistItems,
        releaseEntryBuilder: releaseEntryBuilder,
      ),
  ];
}

VideoShelfReleaseDrilldownItem _buildDrilldownItem(
  LibraryProjectionItem titleItem,
  CatalogEdition edition, {
  required List<CatalogEdition> editions,
  required List<OwnedItem> ownedCopies,
  required List<WishlistItem> wishlistItems,
  required LibraryWorkspaceEntry Function(LibraryReleaseEntryRequest)
      releaseEntryBuilder,
}) {
  final matchedOwnedCopies = ownedCopies
      .where(
        (item) => matchesVideoReleaseAnchor(
          edition,
          editionId: item.editionId,
          variantId: item.variantId,
          bundleReleaseId: item.bundleReleaseId,
        ),
      )
      .toList(growable: false);
  final matchedWishlistItems = wishlistItems
      .where(
        (item) => matchesVideoReleaseAnchor(
          edition,
          editionId: item.editionId,
          variantId: item.variantId,
          bundleReleaseId: item.bundleReleaseId,
        ),
      )
      .toList(growable: false);
  final entry = releaseEntryBuilder(
    LibraryReleaseEntryRequest(
      titleEntry: titleItem.entry,
      edition: edition,
      isOwned: matchedOwnedCopies.isNotEmpty,
      isWishlisted: matchedWishlistItems.isNotEmpty,
      referenceEditionId: edition.id,
      referenceVariantId: preferredVideoEditionVariantId(edition),
      editions: editions,
      updatedAt: titleItem.entry.updatedAt,
    ),
  );
  return VideoShelfReleaseDrilldownItem(
    entry: entry,
    sourceLabel: videoReleaseSourceLabel(edition),
    ownedCount:
        matchedOwnedCopies.fold<int>(0, (sum, item) => sum + item.quantity),
    wishlistCount: matchedWishlistItems.length,
    node: LibraryBrowserNode(
      id: entry.id,
      scope: entry.browseScope,
      entry: entry,
      titleItemId: titleItem.entry.id,
      releaseId: edition.id,
      edition: edition,
      source: titleItem.source,
    ),
  );
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class VideoShelfReleaseDrilldown extends StatelessWidget {
  const VideoShelfReleaseDrilldown({
    super.key,
    required this.titleItem,
    required this.items,
    required this.selectedReleaseId,
    required this.coverSize,
    required this.accent,
    required this.onBack,
    required this.onRefreshFromCore,
    required this.onSelectRelease,
    required this.onOpenTitleDetails,
  });

  final LibraryProjectionItem titleItem;
  final List<VideoShelfReleaseDrilldownItem> items;
  final String? selectedReleaseId;
  final double coverSize;
  final Color accent;
  final VoidCallback onBack;
  final Future<void> Function() onRefreshFromCore;
  final ValueChanged<String> onSelectRelease;
  final VoidCallback onOpenTitleDetails;

  @override
  Widget build(BuildContext context) {
    final selected =
        items.where((item) => item.entry.id == selectedReleaseId).firstOrNull ??
            (items.isEmpty ? null : items.first);
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: kAppPanel,
            border: Border(
                bottom: BorderSide(color: accent.withValues(alpha: 0.28))),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to titles',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shelf releases',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: appPalette(context).textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        titleItem.entry.resolvedTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: appPalette(context).textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenTitleDetails,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open browser'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: onRefreshFromCore,
                  icon: const Icon(Icons.travel_explore_outlined),
                  label: const Text('Search releases in Core'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 42,
                            color: accent.withValues(alpha: 0.9),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No release-specific copies or wishlist entries are anchored in your shelf for this title yet.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: appPalette(context).textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use Search releases in Core to refresh editions, or add a release-specific copy or wishlist entry from the detail browser.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: appPalette(context).textMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (selected != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${selected.entry.variant ?? selected.entry.title} · ${selected.ownedCount} copies · ${selected.wishlistCount} wishlist · ${selected.sourceLabel}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: appPalette(context).textMuted,
                                    ),
                          ),
                        ),
                      ),
                    Expanded(
                      child:
                          LibraryWorkspaceGrid<VideoShelfReleaseDrilldownItem>(
                        items: items,
                        emptyBuilder: (_) => const SizedBox.shrink(),
                        maxCrossAxisExtent: 430,
                        mainAxisExtent:
                            (coverSize * 1.12).clamp(138.0, 174.0).toDouble(),
                        backgroundColor: kAppGridCanvas,
                        itemBuilder: (context, item) => LibraryWorkspaceCard(
                          key: ValueKey(item.entry.id),
                          entry: item.entry,
                          selected: item.entry.id ==
                              (selected?.entry.id ?? selectedReleaseId),
                          onTap: () => onSelectRelease(item.entry.id),
                          dateFormatter: formatDate,
                          moneyFormatter: formatMoney,
                          selectedColor: kAppSelection,
                          accentColor: accent,
                          mutedTextColor: kAppTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
