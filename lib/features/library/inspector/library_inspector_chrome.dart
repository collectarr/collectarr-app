import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class InspectorBackdrop extends StatelessWidget {
  const InspectorBackdrop({super.key, required this.entry});

  final LibraryWorkspaceEntry entry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.38,
          child: LibraryCoverImage(
            title: entry.title,
            itemNumber: entry.itemNumber,
            imageUrl: entry.displayCoverUrl,
            ownedItemId: entry.ownedItemId,
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x66111111),
                Color(0xE0121212),
                Color(0xFA111111),
              ],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xF0101010),
                Color(0xC0101010),
                Color(0xE8101010),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InspectorActionBar extends StatelessWidget {
  const InspectorActionBar({
    super.key,
    required this.type,
    required this.entry,
    required this.onToggleOwned,
    required this.onToggleWishlist,
    required this.onEdit,
    required this.onOpenDetails,
    this.onCorrectMetadata,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback onOpenDetails;
  final VoidCallback? onCorrectMetadata;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD51D1D1D),
        border: Border.all(color: kAppDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Row(
          children: [
            _GenericInspectorActionButton(
              tooltip: entry.isOwned
                  ? 'Remove from collection'
                  : 'Add to collection',
              onPressed: onToggleOwned,
              icon: entry.isOwned
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
            ),
            const SizedBox(width: 4),
            _GenericInspectorActionButton(
              tooltip: entry.isWishlisted
                  ? 'Remove from wishlist'
                  : 'Move to wishlist',
              onPressed: onToggleWishlist,
              icon: entry.isWishlisted ? Icons.star : Icons.star_border,
            ),
            const SizedBox(width: 4),
            _GenericInspectorActionButton(
              tooltip: 'Open details',
              onPressed: onOpenDetails,
              icon: Icons.open_in_new,
            ),
            const SizedBox(width: 4),
            _GenericInspectorActionButton(
              tooltip: 'Edit metadata and collection fields',
              onPressed: onEdit,
              icon: Icons.edit_outlined,
            ),
            if (onCorrectMetadata != null) ...[              const SizedBox(width: 4),
              _GenericInspectorActionButton(
                tooltip: 'Correct metadata',
                onPressed: onCorrectMetadata,
                icon: Icons.fact_check_outlined,
              ),
            ],
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: entry.isOwned ? kAppHighlight : const Color(0xFF2A2A2A),
                border: Border.all(
                  color: entry.isOwned ? kAppHighlight : kAppDivider,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      entry.isOwned
                          ? Icons.check
                          : Icons.check_box_outline_blank,
                      size: 15,
                      color: entry.isOwned
                          ? const Color(0xFF141414)
                          : kAppTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.isOwned ? 'OWNED' : 'LOCAL',
                      style: TextStyle(
                        color: entry.isOwned
                            ? const Color(0xFF141414)
                            : kAppTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenericInspectorActionButton extends StatelessWidget {
  const _GenericInspectorActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 28,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
        ),
      ),
    );
  }
}
