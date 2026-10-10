import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/ui/library_info_chip.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_menus.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InspectorBackdrop extends StatelessWidget {
  const InspectorBackdrop({
    super.key,
    required this.item,
    this.libraryEntry,
  });

  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntry;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final dto = item.dto;
    final card = libraryCardPresentationForEntry(item);
    final libraryEntryRef = resolveLibraryEntryRef(item, libraryEntry);
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.38,
          child: LibraryCoverImage(
            title: dto.primaryLabel,
            itemNumber: card.itemNumber,
            imageUrl: dto.imageUrl,
            libraryEntryRef: libraryEntryRef,
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
    required this.onToggleEntry,
    required this.onToggleWishlist,
    required this.onEdit,
    required this.onOpenDetails,
    this.semanticActions = const <LibraryTargetSemanticAction>[],
    this.extraActions = const <Widget>[],
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final VoidCallback? onToggleEntry;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback onOpenDetails;
  final List<LibraryTargetSemanticAction> semanticActions;
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
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                  ),
            ),
            LibraryStatusChip(
              icon: item.source.isEntry
                  ? Icons.check_circle_outline
                  : Icons.inventory_2_outlined,
              label: item.source.isEntry ? 'Entry' : 'Catalog only',
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
              tooltip: item.source.isEntry
                  ? 'Remove from collection'
                  : item.source.isWishlisted
                      ? 'Convert wishlist to collection'
                      : 'Add to collection',
              onPressed: onToggleEntry,
              icon: item.source.isEntry
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              label: item.source.isEntry ? 'Remove' : 'Collect',
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
            for (final action in semanticActions)
              _InspectorActionPillButton(
                tooltip: action.label,
                onPressed: action.onInvoke == null
                    ? null
                    : () {
                        action.onInvoke!();
                      },
                icon: action.icon,
                label: action.label,
              ),
            for (final action in extraActions) action,
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
      child: Semantics(
        label: tooltip,
        button: true,
        enabled: onPressed != null,
        onTap: onPressed,
        excludeSemantics: true,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          visualDensity: VisualDensity.compact,
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
  moveToCollection,
  unlinkFromCore,
}

class _InspectorBarButton extends StatelessWidget {
  const _InspectorBarButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.label,
    this.customLabel,
    this.semanticsLabel,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? label;
  final Widget? customLabel;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = palette.textPrimary.withValues(alpha: 0.9);
    final disabledColor = palette.textMuted.withValues(alpha: 0.4);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: semanticsLabel ?? label ?? tooltip,
        button: true,
        enabled: onPressed != null,
        onTap: onPressed,
        excludeSemantics: true,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: onPressed != null ? foreground : disabledColor,
                  ),
                  if (label != null || customLabel != null)
                    const SizedBox(width: 4),
                ],
                if (customLabel != null)
                  customLabel!
                else if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: onPressed != null ? foreground : disabledColor,
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

class InspectorUnifiedToolbar extends StatelessWidget {
  const InspectorUnifiedToolbar({
    super.key,
    required this.item,
    required this.detailsLayout,
    this.onEdit,
    this.onShare,
    this.onMoveToCollection,
    this.accent,
    this.onDuplicate,
    this.onToggleEntry,
    this.onLoan,
    this.onRefreshMetadata,
    this.onUnlinkFromCore,
    this.onDetailsLayoutChanged,
    this.framed = false,
    this.includeLayoutControl = true,
  });

  final LibraryProjectionView item;
  final LibraryDetailsLayout detailsLayout;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final VoidCallback? onMoveToCollection;
  final Color? accent;
  final VoidCallback? onDuplicate;
  final VoidCallback? onToggleEntry;
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
    final card = libraryCardPresentationForEntry(item);
    final seriesTitle = card.seriesTitle;
    final upc = card.identifierCode;
    final releaseDate = card.releaseDate;
    final ebayQuery = <String>[
      if (upc?.trim().isNotEmpty == true) upc!.trim(),
      if (seriesTitle?.trim().isNotEmpty == true) seriesTitle!.trim(),
      dto.primaryLabel,
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  _InspectorBarButton(
                    tooltip: 'Edit',
                    semanticsLabel: 'Edit',
                    icon: Icons.edit_outlined,
                    label: compactActions ? null : 'Edit',
                    onPressed: onEdit,
                  ),
                if (onShare != null) ...[
                  const SizedBox(width: 2),
                  _InspectorBarButton(
                    tooltip: 'Share',
                    semanticsLabel: 'Share',
                    icon: Icons.share_outlined,
                    label: compactActions ? null : 'Share',
                    onPressed: onShare,
                  ),
                ],
                if (ebayUri != null) ...[
                  const SizedBox(width: 2),
                  _InspectorBarButton(
                    tooltip: 'Search sold prices on eBay',
                    semanticsLabel: 'eBay',
                    customLabel: Text(
                      'ebay',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: palette.textPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                    onPressed: () => launchUrl(ebayUri),
                  ),
                ],
                const SizedBox(width: 2),
                PopupMenuButton<InspectorToolbarMenuAction>(
                  tooltip: 'More inspector actions',
                  padding: EdgeInsets.zero,
                  color: libraryToolbarMenuSurface(context),
                  surfaceTintColor: Colors.transparent,
                  menuPadding: const EdgeInsets.symmetric(vertical: 4),
                  shape: libraryToolbarDropdownMenuShape(context),
                  position: PopupMenuPosition.under,
                  onSelected: (action) {
                    switch (action) {
                      case InspectorToolbarMenuAction.duplicate:
                        onDuplicate?.call();
                      case InspectorToolbarMenuAction.removeOrCollect:
                        onToggleEntry?.call();
                      case InspectorToolbarMenuAction.loan:
                        onLoan?.call();
                      case InspectorToolbarMenuAction.refreshMetadata:
                        onRefreshMetadata?.call();
                      case InspectorToolbarMenuAction.moveToCollection:
                        onMoveToCollection?.call();
                      case InspectorToolbarMenuAction.unlinkFromCore:
                        onUnlinkFromCore?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onDuplicate != null)
                      const PopupMenuItem<InspectorToolbarMenuAction>(
                        value: InspectorToolbarMenuAction.duplicate,
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.copy_all_outlined, size: 18),
                            title: Text('Duplicate'),
                          ),
                        ),
                      ),
                    if (onToggleEntry != null)
                      PopupMenuItem<InspectorToolbarMenuAction>(
                        value: InspectorToolbarMenuAction.removeOrCollect,
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              item.source.isEntry
                                  ? Icons.delete_outline
                                  : Icons.add_circle_outline,
                              size: 18,
                            ),
                            title: Text(item.source.isEntry ? 'Remove' : 'Collect'),
                          ),
                        ),
                      ),
                    if (onMoveToCollection != null)
                      const PopupMenuItem<InspectorToolbarMenuAction>(
                        value: InspectorToolbarMenuAction.moveToCollection,
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.drive_file_move_outline, size: 18),
                            title: Text('Move to other collection'),
                          ),
                        ),
                      ),
                    if (onUnlinkFromCore != null)
                      const PopupMenuItem<InspectorToolbarMenuAction>(
                        value: InspectorToolbarMenuAction.unlinkFromCore,
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.link_off, size: 18),
                            title: Text('Unlink from Core'),
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
                          leading: Icon(Icons.handshake_outlined, size: 18),
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
                          leading: Icon(Icons.cloud_download_outlined, size: 18),
                          title: Text('Update from Core'),
                        ),
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: palette.textPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
            if (includeLayoutControl)
              LibraryDetailsLayoutDropdown(
                detailsLayout: detailsLayout,
                onChanged: (val) => onDetailsLayoutChanged?.call(val),
                iconOnly: compactActions,
                inspectorStyle: true,
              ),
          ],
        );
      },
    );

    final styled = Container(
      decoration: BoxDecoration(
        color: framed ? palette.panel.withValues(alpha: 0.72) : null,
        borderRadius: framed ? BorderRadius.circular(12) : null,
        border: framed
            ? Border.all(color: palette.divider)
            : Border(
                bottom: BorderSide(
                  color: palette.divider.withValues(alpha: 0.6),
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: content,
    );

    return accent == null
        ? styled
        : Theme(data: libraryAccentTheme(context, accent!), child: styled);
  }
}
