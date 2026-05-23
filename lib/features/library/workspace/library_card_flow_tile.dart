import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

/// A tall card showing a large cover beside rich metadata, used in "card flow"
/// mode. Intended for a single- or two-column vertical feed layout.
class LibraryCardFlowTile extends StatelessWidget {
  const LibraryCardFlowTile({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.onSecondaryTapUp,
    required this.dateFormatter,
    required this.moneyFormatter,
    this.selectedColor = const Color(0xFF075F75),
    this.accentColor = const Color(0xFF10A8D8),
    this.mutedTextColor = const Color(0xFFB8B8B8),
    super.key,
  });

  final LibraryWorkspaceEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final LibraryDateFormatter dateFormatter;
  final LibraryMoneyFormatter moneyFormatter;
  final Color selectedColor;
  final Color accentColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    final capabilities = collectarrLibraryTypes.capabilitiesForKind(
      entry.mediaType,
    );
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected ? selectedColor : const Color(0xFF181818),
        border: Border.all(
          color: selected ? accentColor : const Color(0xFF363636),
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onSecondaryTapUp: onSecondaryTapUp,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Large cover ──
                SizedBox(
                  width: 120,
                  height: 184,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LibraryInteractiveCover(
                          title: entry.title,
                          itemNumber: entry.itemNumber,
                          imageUrl: entry.displayCoverUrl,
                          ownedItemId: entry.ownedItemId,
                          accentColor: accentColor,
                        ),
                      ),
                      Positioned(
                        left: 4,
                        top: 4,
                        child: LibraryCoverBadges(
                          isOwned: entry.isOwned,
                          isTracked: entry.isTracked,
                          isWishlisted: entry.isWishlisted,
                          hasMissingCover: entry.hasMissingCover,
                          hasMissingMetadata: entry.hasMissingMetadata,
                          keyLabel: libraryKeyMarkerLabel(
                            entry.keyComic,
                            entry.keyReason,
                          ),
                          slabLabel: librarySlabMarkerLabel(
                            entry.rawOrSlabbed,
                            entry.gradingCompany,
                          ),
                          notesLabel: libraryNotesMarkerLabel(entry.notes),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // ── Metadata ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + issue
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF82DDF2),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (entry.itemNumber != null) ...[
                            const SizedBox(width: 6),
                            _IssuePill(label: '#${entry.itemNumber}'),
                          ],
                        ],
                      ),
                      // Series / subtitle
                      if (entry.series?.seriesTitle != null &&
                          entry.series!.seriesTitle != entry.title) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.series!.seriesTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accentColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      // Variant | date | publisher
                      Text(
                        [
                          if (entry.variant != null &&
                              entry.variant!.isNotEmpty)
                            entry.variant,
                          if (entry.releaseDate != null)
                            dateFormatter(entry.releaseDate!)
                          else if (entry.releaseYear != null)
                            entry.releaseYear.toString(),
                          if (entry.publisher != null &&
                              entry.publisher!.isNotEmpty)
                            entry.publisher,
                        ].whereType<String>().join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Meta pills
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (entry.grade != null)
                            _MetaPill(
                              icon: Icons.workspace_premium,
                              label: entry.grade!,
                              accentColor: accentColor,
                            ),
                          if (entry.condition != null)
                            _MetaPill(
                              icon: Icons.fact_check_outlined,
                              label: entry.condition!,
                              accentColor: accentColor,
                            ),
                          if (entry.video?.runtimeMinutes != null)
                            _MetaPill(
                              icon: Icons.schedule,
                              label: '${entry.video!.runtimeMinutes} min',
                              accentColor: accentColor,
                            ),
                          if (entry.keyComic)
                            _MetaPill(
                              icon: Icons.label_important,
                              label: entry.keyReason ?? 'Key item',
                              accentColor: accentColor,
                            ),
                          if (entry.rawOrSlabbed != null ||
                              entry.gradingCompany != null)
                            _MetaPill(
                              icon: Icons.workspace_premium,
                              label: librarySlabMarkerLabel(
                                    entry.rawOrSlabbed,
                                    entry.gradingCompany,
                                  ) ??
                                  'Collector copy',
                              accentColor: accentColor,
                            ),
                          if (entry.storageBox != null)
                            _MetaPill(
                              icon: Icons.inventory_2_outlined,
                              label: entry.storageBox!,
                              accentColor: accentColor,
                            ),
                          if (entry.pricePaidCents != null)
                            _MetaPill(
                              icon: Icons.attach_money,
                              label: moneyFormatter(
                                entry.pricePaidCents,
                                entry.currency,
                              ),
                              accentColor: accentColor,
                            ),
                          if (entry.isWishlisted)
                            _MetaPill(
                              icon: Icons.star,
                              label: 'Wishlist',
                              accentColor: accentColor,
                            ),
                          if (capabilities.showsTrackData &&
                              entry.music?.trackCount != null)
                            _MetaPill(
                              icon: Icons.music_note,
                              label: '${entry.music!.trackCount} tracks',
                              accentColor: accentColor,
                            ),
                          if (entry.music?.releaseStatus != null)
                            _MetaPill(
                              icon: Icons.album,
                              label: entry.music!.releaseStatus!,
                              accentColor: accentColor,
                            ),
                          if (_platformLabel(entry.rawPlatforms) case final platformLabel?)
                            _MetaPill(
                              icon: Icons.sports_esports,
                              label: platformLabel,
                              accentColor: accentColor,
                            ),
                          if (_noteLabel(entry.notes) case final noteLabel?)
                            _MetaPill(
                              icon: Icons.sticky_note_2_outlined,
                              label: noteLabel,
                              accentColor: accentColor,
                            ),
                          if (entry.publishing?.pageCount != null)
                            _MetaPill(
                              icon: Icons.menu_book,
                              label: '${entry.publishing!.pageCount} pg',
                              accentColor: accentColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Synopsis snippet
                      if (capabilities.showsSynopsis &&
                          entry.synopsis != null &&
                          entry.synopsis!.isNotEmpty)
                        Text(
                          entry.synopsis!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: mutedTextColor.withValues(alpha: 0.7),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _platformLabel(List<String>? platforms) {
  if (platforms == null || platforms.isEmpty) {
    return null;
  }
  final values = platforms
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (values.isEmpty) {
    return null;
  }
  if (values.length == 1) {
    return values.single;
  }
  return '${values.first} +${values.length - 1}';
}

String? _noteLabel(String? notes) {
  final trimmed = notes?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length <= 28) {
    return trimmed;
  }
  return '${trimmed.substring(0, 27)}...';
}

// ─── Private helpers ────────────────────────────────────────────────────────

class _IssuePill extends StatelessWidget {
  const _IssuePill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD400),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.accentColor,
  });
  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accentColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
