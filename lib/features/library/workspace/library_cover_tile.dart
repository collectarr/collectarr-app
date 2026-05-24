import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class LibraryCoverTile extends StatelessWidget {
  const LibraryCoverTile({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.onSecondaryTapUp,
    this.selectedColor = const Color(0xFF075F75),
    this.accentColor = const Color(0xFF10A8D8),
    this.selectionColor = const Color(0xFFFFD400),
    this.mutedTextColor = const Color(0xFFB8B8B8),
    super.key,
  });

  final LibraryWorkspaceEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final Color selectedColor;
  final Color accentColor;
  final Color selectionColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: selected ? selectedColor : const Color(0xFF111111),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: selected ? accentColor : const Color(0xFF3C3C3C),
          width: selected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onSecondaryTapUp: onSecondaryTapUp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LibraryInteractiveCover(
                      title: entry.title,
                      itemNumber: entry.itemNumber,
                      imageUrl: entry.displayCoverUrl,
                      ownedItemId: entry.ownedItemId,
                      accentColor: accentColor,
                      enableFullscreen: false,
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
                        keyLabel:
                            libraryKeyMarkerLabel(entry.keyComic, entry.keyReason),
                        slabLabel: librarySlabMarkerLabel(
                          entry.rawOrSlabbed,
                          entry.gradingCompany,
                        ),
                        notesLabel: libraryNotesMarkerLabel(entry.notes),
                      ),
                    ),
                    if (selected)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.check_circle,
                            color: selectionColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.itemNumber == null
                    ? entry.title
                    : '${entry.title} #${entry.itemNumber}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? Colors.white : mutedTextColor,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
              if (entry.releaseYear != null)
                Text(
                  entry.releaseYear.toString(),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected
                            ? Colors.white70
                            : mutedTextColor.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
