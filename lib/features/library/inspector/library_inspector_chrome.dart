import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:flutter/material.dart';

class InspectorBackdrop extends StatelessWidget {
  const InspectorBackdrop({
    super.key,
    required this.entry,
    this.ownedItem,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final ownedItemId = resolveLibraryOwnedItemId(entry, ownedItem);
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.38,
          child: LibraryCoverImage(
            title: entry.resolvedTitle,
            itemNumber: entry.itemNumber,
            imageUrl: entry.displayCoverUrl,
            ownedItemId: ownedItemId,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.surface.withValues(alpha: 0.4),
                palette.panel.withValues(alpha: 0.82),
                palette.panel.withValues(alpha: 0.94),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                palette.panel.withValues(alpha: 0.94),
                palette.surfaceSubtle.withValues(alpha: 0.72),
                palette.panel.withValues(alpha: 0.9),
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
    this.extraActions = const <Widget>[],
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback onOpenDetails;
  final VoidCallback? onCorrectMetadata;
  final List<Widget> extraActions;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final ownedForeground =
        ThemeData.estimateBrightnessForColor(kAppHighlight) == Brightness.dark
            ? Colors.white
            : Colors.black87;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: 0.88),
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: palette.textMuted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                ),
                _InspectorStatusChip(
                  icon: entry.isOwned
                      ? Icons.check_circle_outline
                      : Icons.inventory_2_outlined,
                  label: entry.isOwned ? 'Owned' : 'Catalog only',
                  foreground: entry.isOwned ? ownedForeground : palette.textMuted,
                  background: entry.isOwned
                      ? kAppHighlight
                      : palette.surfaceSubtle.withValues(alpha: 0.8),
                  borderColor:
                      entry.isOwned ? kAppHighlight : palette.divider,
                ),
                if (entry.isWishlisted)
                  _InspectorStatusChip(
                    icon: Icons.star,
                    label: 'Wish list',
                    foreground: palette.textPrimary,
                    background: palette.surfaceSubtle.withValues(alpha: 0.7),
                    borderColor: palette.divider,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InspectorActionPillButton(
                  tooltip: entry.isOwned
                      ? 'Remove from collection'
                      : entry.isWishlisted
                          ? 'Convert wishlist to collection'
                          : 'Add to collection',
                  onPressed: onToggleOwned,
                  icon: entry.isOwned
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  label: entry.isOwned ? 'Remove' : 'Collect',
                ),
                _InspectorActionPillButton(
                  tooltip: entry.isWishlisted
                      ? 'Remove from wishlist'
                      : 'Move to wishlist',
                  onPressed: onToggleWishlist,
                  icon: entry.isWishlisted ? Icons.star : Icons.star_border,
                  label: entry.isWishlisted ? 'Unwish' : 'Wishlist',
                ),
                _InspectorActionPillButton(
                  tooltip: 'Open details',
                  onPressed: onOpenDetails,
                  icon: Icons.open_in_new,
                  label: 'Open',
                ),
                _InspectorActionPillButton(
                  tooltip: 'Edit metadata and collection fields',
                  onPressed: onEdit,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                ),
                for (final action in extraActions) action,
                if (onCorrectMetadata != null)
                  InspectorToolIconButton(
                    tooltip: 'Correct metadata',
                    onPressed: onCorrectMetadata,
                    icon: Icons.fact_check_outlined,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectorActionPillButton extends StatelessWidget {
  const _InspectorActionPillButton({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
}

class _InspectorStatusChip extends StatelessWidget {
  const _InspectorStatusChip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InspectorToolIconButton extends StatelessWidget {
  const InspectorToolIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        height: 32,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            minimumSize: const Size(32, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            side: BorderSide(color: palette.divider),
            backgroundColor: palette.surface.withValues(alpha: 0.45),
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}
