import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: palette.divider),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.35,
                  ),
            ),
            _InspectorStatusChip(
              icon: entry.isOwned
                  ? Icons.check_circle_outline
                  : Icons.inventory_2_outlined,
              label: entry.isOwned ? 'Owned' : 'Catalog only',
              foreground: palette.textPrimary,
              background: palette.surface,
              borderColor: palette.divider,
            ),
            if (entry.isWishlisted)
              _InspectorStatusChip(
                icon: Icons.star,
                label: 'Wish list',
                foreground: palette.textPrimary,
                background: palette.surface,
                borderColor: palette.divider,
              ),
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
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
        height: 30,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            minimumSize: const Size(30, 30),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            side: BorderSide(color: palette.divider),
            backgroundColor: palette.surface,
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

enum InspectorToolbarMenuAction {
  duplicate,
  removeOrCollect,
  loan,
  refreshMetadata,
  unlinkFromCore,
}

class InspectorUnifiedToolbar extends StatelessWidget {
  const InspectorUnifiedToolbar({
    super.key,
    required this.entry,
    this.onEdit,
    this.onShare,
    this.onDuplicate,
    this.onToggleOwned,
    this.onLoan,
    this.onRefreshMetadata,
    this.onUnlinkFromCore,
    this.onDetailsLayoutChanged,
    this.framed = true,
    this.includeLayoutControl = true,
  });

  final LibraryWorkspaceEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final VoidCallback? onDuplicate;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onLoan;
  final VoidCallback? onRefreshMetadata;
  final VoidCallback? onUnlinkFromCore;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final bool framed;
  final bool includeLayoutControl;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final ebayUri = _inspectorEbayUri(entry);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
          const SizedBox(width: 6),
          if (ebayUri != null)
            InspectorToolIconButton(
              tooltip: 'Find sold listings on eBay',
              icon: Icons.shopping_bag_outlined,
              onPressed: () =>
                  launchUrl(ebayUri, mode: LaunchMode.externalApplication),
            ),
          const Spacer(),
          PopupMenuButton<InspectorToolbarMenuAction>(
            tooltip: 'More actions',
            onSelected: (value) {
              switch (value) {
                case InspectorToolbarMenuAction.duplicate:
                  onDuplicate?.call();
                  return;
                case InspectorToolbarMenuAction.removeOrCollect:
                  onToggleOwned?.call();
                  return;
                case InspectorToolbarMenuAction.loan:
                  onLoan?.call();
                  return;
                case InspectorToolbarMenuAction.refreshMetadata:
                  onRefreshMetadata?.call();
                  return;
                case InspectorToolbarMenuAction.unlinkFromCore:
                  onUnlinkFromCore?.call();
                  return;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<InspectorToolbarMenuAction>(
                value: InspectorToolbarMenuAction.duplicate,
                enabled: onDuplicate != null,
                child: const ListTile(
                  dense: true,
                  leading: Icon(Icons.copy_all_outlined),
                  title: Text('Duplicate'),
                ),
              ),
              PopupMenuItem<InspectorToolbarMenuAction>(
                value: InspectorToolbarMenuAction.removeOrCollect,
                enabled: onToggleOwned != null,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    entry.isOwned
                        ? Icons.delete_outline
                        : Icons.add_circle_outline,
                  ),
                  title: Text(entry.isOwned ? 'Remove' : 'Collect'),
                ),
              ),
              PopupMenuItem<InspectorToolbarMenuAction>(
                value: InspectorToolbarMenuAction.loan,
                enabled: onLoan != null,
                child: const ListTile(
                  dense: true,
                  leading: Icon(Icons.handshake_outlined),
                  title: Text('Loan'),
                ),
              ),
              PopupMenuItem<InspectorToolbarMenuAction>(
                value: InspectorToolbarMenuAction.refreshMetadata,
                enabled: onRefreshMetadata != null,
                child: const ListTile(
                  dense: true,
                  leading: Icon(Icons.cloud_download_outlined),
                  title: Text('Update from Core'),
                ),
              ),
              PopupMenuItem<InspectorToolbarMenuAction>(
                value: InspectorToolbarMenuAction.unlinkFromCore,
                enabled: onUnlinkFromCore != null,
                child: const ListTile(
                  dense: true,
                  leading: Icon(Icons.link_off_outlined),
                  title: Text('Unlink from Core'),
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.more_vert, size: 18),
            ),
          ),
          if (includeLayoutControl && onDetailsLayoutChanged != null) ...[
            const SizedBox(width: 4),
            PopupMenuButton<LibraryDetailsLayout>(
              tooltip: 'Layout',
              onSelected: onDetailsLayoutChanged,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: LibraryDetailsLayout.bottom,
                  child: Text('Horizontal Split'),
                ),
                PopupMenuItem(
                  value: LibraryDetailsLayout.right,
                  child: Text('Vertical Split'),
                ),
                PopupMenuItem(
                  value: LibraryDetailsLayout.hidden,
                  child: Text('No Details'),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.view_sidebar_outlined, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
    if (!framed) {
      return content;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: content,
    );
  }
}

Uri? _inspectorEbayUri(LibraryWorkspaceEntry entry) {
  final barcode = entry.barcode?.trim();
  if (barcode == null || barcode.isEmpty) {
    return null;
  }
  final query = <String>[
    barcode,
    if (entry.series?.seriesTitle?.trim().isNotEmpty == true)
      entry.series!.seriesTitle!.trim(),
    entry.resolvedTitle,
    if (entry.releaseYear != null) entry.releaseYear.toString(),
  ].join(' ');
  return Uri.https(
    'www.ebay.com',
    '/sch/11233/i.html',
    <String, String>{
      '_nkw': query,
      'LH_Sold': '1',
    },
  );
}
