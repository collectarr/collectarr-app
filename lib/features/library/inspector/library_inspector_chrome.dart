import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/ui/library_info_chip.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InspectorBackdrop extends StatelessWidget {
  const InspectorBackdrop({
    super.key,
    required this.item,
    this.ownedItem,
  });

  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final dto = item.dto;
    final ownedItemId = resolveLibraryOwnedItemId(item, ownedItem);
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.38,
          child: LibraryCoverImage(
            title: dto.title,
            itemNumber: (dto is WorkspaceDtoAdapter
                ? (dto as WorkspaceDtoAdapter).itemNumber
                : null),
            imageUrl: dto.coverImageUrl,
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
    required this.item,
    required this.onToggleOwned,
    required this.onToggleWishlist,
    required this.onEdit,
    required this.onOpenDetails,
    this.onCorrectMetadata,
    this.extraActions = const <Widget>[],
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
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
            LibraryStatusChip(
              icon: (item.source.isOwned || item.source.ownedItem != null)
                  ? Icons.check_circle_outline
                  : Icons.inventory_2_outlined,
              label: (item.source.isOwned || item.source.ownedItem != null)
                  ? 'Owned'
                  : 'Catalog only',
              foreground: palette.textPrimary,
              background: palette.surface,
              borderColor: palette.divider,
            ),
            if (item.source.isWishlisted ||
                item.source.wishlistItem != null ||
                onToggleWishlist != null)
              LibraryStatusChip(
                icon: Icons.star,
                label: 'Wish list',
                foreground: palette.textPrimary,
                background: palette.surface,
                borderColor: palette.divider,
              ),
            _InspectorActionPillButton(
              tooltip: item.source.isOwned
                  ? 'Remove from collection'
                  : item.source.isWishlisted
                      ? 'Convert wishlist to collection'
                      : 'Add to collection',
              onPressed: onToggleOwned,
              icon: item.source.isOwned
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              label: item.source.isOwned ? 'Remove' : 'Collect',
            ),
            _InspectorActionPillButton(
              tooltip: item.source.isWishlisted
                  ? 'Remove from wishlist'
                  : 'Move to wishlist',
              onPressed: onToggleWishlist,
              icon: item.source.isWishlisted ? Icons.star : Icons.star_border,
              label: item.source.isWishlisted ? 'Unwish' : 'Wishlist',
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
}

class InspectorToolIconButton extends StatelessWidget {
  const InspectorToolIconButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

enum InspectorToolbarMenuAction {
  duplicate,
  removeOrCollect,
  loan,
  refreshMetadata,
}

class InspectorUnifiedToolbar extends StatelessWidget {
  const InspectorUnifiedToolbar({
    super.key,
    required this.item,
    required this.detailsLayout,
    this.onEdit,
    this.onShare,
    this.onDuplicate,
    this.onToggleOwned,
    this.onLoan,
    this.onRefreshMetadata,
    this.onUnlinkFromCore,
    this.onDetailsLayoutChanged,
    this.framed = false,
    this.includeLayoutControl = true,
  });

  final LibraryProjectionRuntime item;
  final LibraryDetailsLayout detailsLayout;
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
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final seriesTitle = adapter?.seriesTitle;
    final barcode = adapter?.barcode;
    final releaseDate = adapter?.releaseDate;
    final ebayQuery = <String>[
      if (barcode?.trim().isNotEmpty == true) barcode!.trim(),
      if (seriesTitle?.trim().isNotEmpty == true) seriesTitle!.trim(),
      dto.title,
      if (releaseDate != null) releaseDate.year.toString(),
    ].join(' ');
    final ebayUri = buildEbaySearchUri(
      query: ebayQuery,
      categoryPath: '/sch/11233/i.html',
      soldOnly: true,
    );
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final compactActions = constraints.maxWidth < 420;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.end,
          children: [
            if (includeLayoutControl)
              LibraryDetailsLayoutDropdown(
                detailsLayout: detailsLayout,
                onChanged: (val) => onDetailsLayoutChanged?.call(val),
                iconOnly: compactActions,
              ),
            if (ebayUri != null)
              compactActions
                  ? InspectorToolIconButton(
                      tooltip: 'Search sold prices on eBay',
                      onPressed: () => launchUrl(ebayUri),
                      icon: Icons.shopping_bag_outlined,
                    )
                  : _InspectorActionPillButton(
                      tooltip: 'Search sold prices on eBay',
                      onPressed: () => launchUrl(ebayUri),
                      icon: Icons.shopping_bag_outlined,
                      label: 'eBay',
                    ),
            if (!compactActions && onDuplicate != null)
              InspectorToolIconButton(
                tooltip: 'Duplicate owned copy',
                onPressed: onDuplicate,
                icon: Icons.copy_all_outlined,
              ),
            if (!compactActions && onToggleOwned != null)
              InspectorToolIconButton(
                tooltip: item.source.isOwned
                    ? 'Remove from collection'
                    : 'Add to collection',
                onPressed: onToggleOwned,
                icon: item.source.isOwned
                    ? Icons.delete_outline
                    : Icons.add_circle_outline,
              ),
            PopupMenuButton<InspectorToolbarMenuAction>(
              tooltip: 'More inspector actions',
              onSelected: (action) {
                switch (action) {
                  case InspectorToolbarMenuAction.duplicate:
                    onDuplicate?.call();
                  case InspectorToolbarMenuAction.removeOrCollect:
                    onToggleOwned?.call();
                  case InspectorToolbarMenuAction.loan:
                    onLoan?.call();
                  case InspectorToolbarMenuAction.refreshMetadata:
                    onRefreshMetadata?.call();
                }
              },
              itemBuilder: (context) => [
                if (compactActions && onDuplicate != null)
                  const PopupMenuItem<InspectorToolbarMenuAction>(
                    value: InspectorToolbarMenuAction.duplicate,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.copy_all_outlined),
                        title: Text('Duplicate'),
                      ),
                    ),
                  ),
                if (compactActions && onToggleOwned != null)
                  PopupMenuItem<InspectorToolbarMenuAction>(
                    value: InspectorToolbarMenuAction.removeOrCollect,
                    enabled: onToggleOwned != null,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          item.source.isOwned
                              ? Icons.delete_outline
                              : Icons.add_circle_outline,
                        ),
                        title: Text(item.source.isOwned ? 'Remove' : 'Collect'),
                      ),
                    ),
                  ),
                PopupMenuItem<InspectorToolbarMenuAction>(
                  value: InspectorToolbarMenuAction.loan,
                  enabled: onLoan != null,
                  child: const Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.handshake_outlined),
                      title: Text('Loan'),
                    ),
                  ),
                ),
                PopupMenuItem<InspectorToolbarMenuAction>(
                  value: InspectorToolbarMenuAction.refreshMetadata,
                  enabled: onRefreshMetadata != null,
                  child: const Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.cloud_download_outlined),
                      title: Text('Update from Core'),
                    ),
                  ),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.more_vert, size: 18),
              ),
            ),
          ],
        );
      },
    );

    if (!framed) {
      return content;
    }

    return Container(
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: content,
    );
  }
}
