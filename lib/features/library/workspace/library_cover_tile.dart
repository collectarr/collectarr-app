import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryCoverTile extends StatelessWidget {
  const LibraryCoverTile({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapUp,
    this.selectedColor = kAppSelection,
    this.accentColor = kAppAccent,
    this.selectionColor = kAppHighlight,
    this.mutedTextColor = kAppTextMuted,
    super.key,
  });

  final LibraryWorkspaceEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final Color selectedColor;
  final Color accentColor;
  final Color selectionColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
      duration: kAppAnimFast,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: selected ? selectedColor : kAppField,
        borderRadius: kAppRadiusSmall,
        border: Border.all(
          color: selected ? accentColor : kAppCardBorder,
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
          onDoubleTap: onDoubleTap,
          onSecondaryTapUp: onSecondaryTapUp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LibraryInteractiveCover(
                      title: entry.resolvedTitle,
                      itemNumber: entry.itemNumber,
                      imageUrl: entry.displayCoverUrl,
                      ownedItemId: entry.ownedItemId,
                      accentColor: accentColor,
                      enableFullscreen: false,
                      enableSecondaryControl: false,
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
                            entry.keyComic, entry.keyReason),
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
                    ? entry.resolvedTitle
                    : '${entry.resolvedTitle} #${entry.itemNumber}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? Colors.white : mutedTextColor,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
              if (entry.originalTitle?.trim().isNotEmpty == true &&
                  entry.originalTitle!.trim() != entry.resolvedTitle.trim())
                Text(
                  entry.originalTitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected
                            ? Colors.white70
                            : mutedTextColor.withValues(alpha: 0.7),
                        fontSize: 10,
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
    ),
    );
  }
}
