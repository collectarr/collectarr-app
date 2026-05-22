import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

typedef LibraryDateFormatter = String Function(DateTime value);
typedef LibraryMoneyFormatter = String Function(int? cents, String? currency);

class LibraryWorkspaceCard extends StatelessWidget {
  const LibraryWorkspaceCard({
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected ? selectedColor : const Color(0xFF181818),
        border: Border.all(
          color: selected ? accentColor : const Color(0xFF363636),
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onSecondaryTapUp: onSecondaryTapUp,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LibraryInteractiveCover(
                        title: entry.title,
                        itemNumber: entry.itemNumber,
                        imageUrl: entry.displayCoverUrl,
                        ownedItemId: entry.ownedItemId,
                        accentColor: accentColor,
                      ),
                      Positioned(
                        left: 4,
                        top: 4,
                        child: LibraryCoverBadges(
                          isOwned: entry.isOwned,
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF82DDF2),
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          if (entry.itemNumber != null)
                            _LibraryIssuePill(label: '#${entry.itemNumber}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (entry.variant != null &&
                              entry.variant!.isNotEmpty)
                            entry.variant,
                          if (entry.releaseDate != null)
                            dateFormatter(entry.releaseDate!),
                          if (entry.publisher != null &&
                              entry.publisher!.isNotEmpty)
                            entry.publisher,
                        ].whereType<String>().join('  |  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mutedTextColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (entry.grade != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.workspace_premium,
                              label: entry.grade!,
                              accentColor: accentColor,
                            ),
                          if (entry.condition != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.fact_check_outlined,
                              label: entry.condition!,
                              accentColor: accentColor,
                            ),
                          if (entry.video?.runtimeMinutes != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.schedule,
                              label: '${entry.video!.runtimeMinutes} min',
                              accentColor: accentColor,
                            ),
                          if (entry.music?.trackCount != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.music_note,
                              label: '${entry.music!.trackCount} tracks',
                              accentColor: accentColor,
                            ),
                          if (entry.music?.releaseStatus != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.album,
                              label: entry.music!.releaseStatus!,
                              accentColor: accentColor,
                            ),
                          if (_compactPlatformLabel(entry.rawPlatforms) case final platformLabel?)
                            _LibraryCompactMetaPill(
                              icon: Icons.sports_esports,
                              label: platformLabel,
                              accentColor: accentColor,
                            ),
                          if (_compactNotesLabel(entry.notes) case final noteLabel?)
                            _LibraryCompactMetaPill(
                              icon: Icons.sticky_note_2_outlined,
                              label: noteLabel,
                              accentColor: accentColor,
                            ),
                          if (entry.keyComic)
                            _LibraryCompactMetaPill(
                              icon: Icons.label_important,
                              label: entry.keyReason ?? 'Key item',
                              accentColor: accentColor,
                            ),
                          if (entry.rawOrSlabbed != null ||
                              entry.gradingCompany != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.workspace_premium,
                              label: librarySlabMarkerLabel(
                                    entry.rawOrSlabbed,
                                    entry.gradingCompany,
                                  ) ??
                                  'Collector copy',
                              accentColor: accentColor,
                            ),
                          if (entry.storageBox != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.inventory_2_outlined,
                              label: entry.storageBox!,
                              accentColor: accentColor,
                            ),
                          if (entry.pricePaidCents != null)
                            _LibraryCompactMetaPill(
                              icon: Icons.attach_money,
                              label: moneyFormatter(
                                entry.pricePaidCents,
                                entry.currency,
                              ),
                              accentColor: accentColor,
                            ),
                          if (entry.isWishlisted)
                            _LibraryCompactMetaPill(
                              icon: Icons.star,
                              label: 'Wishlist',
                              accentColor: accentColor,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        entry.barcode == null || entry.barcode!.isEmpty
                            ? 'No barcode'
                            : entry.barcode!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF9A9A9A),
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

String? _compactPlatformLabel(List<String>? platforms) {
  if (platforms == null || platforms.isEmpty) {
    return null;
  }
  final first = platforms.first.trim();
  if (first.isEmpty) {
    return null;
  }
  final extra = platforms.skip(1).where((value) => value.trim().isNotEmpty).length;
  return extra == 0 ? first : '$first +$extra';
}

String? _compactNotesLabel(String? notes) {
  final trimmed = notes?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length <= 28) {
    return trimmed;
  }
  return '${trimmed.substring(0, 27)}...';
}

class _LibraryIssuePill extends StatelessWidget {
  const _LibraryIssuePill({required this.label});

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
            color: Color(0xFF151515),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LibraryCompactMetaPill extends StatelessWidget {
  const _LibraryCompactMetaPill({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF4B4B4B)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: accentColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
