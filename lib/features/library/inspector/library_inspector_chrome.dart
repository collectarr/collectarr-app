import 'package:collectarr_app/ui/app_dark_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class InspectorBackdrop extends StatelessWidget {
  const InspectorBackdrop({
    super.key,
    required this.item,
    this.libraryEntry,
    this.backgroundColor,
  });

  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntry;
  final Color? backgroundColor;

  static const _backdropCacheWidth = 640;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    final card = libraryCardPresentationForEntry(item);
    final libraryEntryRef = resolveLibraryEntryRef(item, libraryEntry);
    return Stack(
      fit: StackFit.expand,
      children: [
        LibraryCoverImage(
          title: dto.primaryLabel,
          itemNumber: card.itemNumber,
          imageUrl: dto.imageUrl,
          libraryEntryRef: libraryEntryRef,
          // A fixed decode width keeps the image cache key stable, so resizing
          // the panel does not reload (and flash) the dimmed backdrop.
          targetCacheWidth: _backdropCacheWidth,
          fit: BoxFit.cover,
          showPlaceholder: false,
        ),
        ColoredBox(
          color:
              libraryWorkspaceBackgroundColor(context).withValues(alpha: 0.9),
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
              icon: Icons.edit,
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

class _InspectorBarButton extends StatelessWidget {
  const _InspectorBarButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.label,
    this.labelContent,
    this.semanticsLabel,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? label;
  final Widget? labelContent;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = palette.textPrimary;
    final disabledColor = palette.textMuted.withValues(alpha: 0.4);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: semanticsLabel ?? label ?? tooltip,
        button: true,
        enabled: onPressed != null,
        onTap: onPressed,
        excludeSemantics: true,
        child: AppClickTarget(
          onClick: onPressed,
          builder: (context, hovered) => DecoratedBox(
            decoration: BoxDecoration(
              color: hovered
                  ? palette.isDark
                      ? const Color(0xFF464950)
                      : Theme.of(context).hoverColor
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 14,
                      color: onPressed != null ? foreground : disabledColor,
                    ),
                    if (label != null || labelContent != null)
                      const SizedBox(width: 6),
                  ],
                  if (labelContent != null)
                    labelContent!
                  else if (label != null)
                    Text(
                      label!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: onPressed != null ? foreground : disabledColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InspectorUnifiedToolbar extends ConsumerWidget {
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
    this.onLinkToCore,
    this.onDetailsLayoutChanged,
    this.framed = false,
    this.includeLayoutControl = true,
    this.contentMaxWidth,
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
  final VoidCallback? onLinkToCore;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final bool framed;
  final bool includeLayoutControl;
  final double? contentMaxWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final preferences = ref.watch(uiPreferencesProvider);
    final ebayUri = preferences.ebayToolbar &&
            preferences.allowsEbayLinks(item.source.isWishlisted)
        ? buildEbaySearchUri(
            query: ebayQuery,
            categoryPath: '/sch/11233/i.html',
            region: preferences.ebayRegion,
            soldOnly: preferences.ebaySearchFilter
                .soldOnlyFor(isWishlisted: item.source.isWishlisted),
          )
        : null;
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
                    icon: AppIcons.inlineEdit,
                    label: compactActions ? null : 'Edit',
                    onPressed: onEdit,
                  ),
                if (onShare != null) ...[
                  _inspectorToolbarSeparator(context),
                  _InspectorBarButton(
                    tooltip: 'Share',
                    semanticsLabel: 'Share',
                    icon: AppIcons.cloudSharing,
                    label: compactActions ? null : 'Share',
                    onPressed: onShare,
                  ),
                ],
                if (ebayUri != null) ...[
                  _inspectorToolbarSeparator(context),
                  _InspectorBarButton(
                    tooltip: 'Find sold listings on eBay',
                    semanticsLabel: 'eBay',
                    // The wordmark fills the middle band of its square: draw the
                    // square 38 px wide, as the reference's wordmark, and
                    // show only that band.
                    labelContent: SizedBox(
                      width: 38,
                      height: 15,
                      child: ClipRect(
                        child: OverflowBox(
                          maxWidth: 38,
                          maxHeight: 38,
                          child: SvgPicture.asset(
                            'assets/logos/ebay.svg',
                            width: 38,
                            height: 38,
                            // Resolved inside the toolbar, which stays dark
                            // in both themes.
                            colorFilter: ColorFilter.mode(
                              appPalette(context).textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () => launchUrl(ebayUri),
                  ),
                ],
                _inspectorToolbarSeparator(context),
                MenuAnchor(
                  alignmentOffset: const Offset(-5, 4),
                  style: MenuStyle(
                    alignment: AlignmentDirectional.bottomStart,
                    backgroundColor: WidgetStatePropertyAll(
                        libraryToolbarMenuSurface(context)),
                    surfaceTintColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    elevation: const WidgetStatePropertyAll(0),
                    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                    shape: WidgetStatePropertyAll(
                        libraryToolbarDropdownMenuShape(context)),
                  ),
                  menuChildren: [
                    if (onDuplicate != null)
                      _inspectorMenuItem(
                          'Duplicate', AppIcons.duplicateAction, onDuplicate),
                    if (onToggleEntry != null)
                      _inspectorMenuItem(
                          item.source.isEntry ? 'Remove' : 'Collect',
                          item.source.isEntry
                              ? AppIcons.removeAction
                              : AppIcons.collect,
                          onToggleEntry),
                    _inspectorMenuItem('Loan', AppIcons.loanAction, onLoan),
                    if (onMoveToCollection != null)
                      _inspectorMenuItem('Move to other collection',
                          AppIcons.moveCollection, onMoveToCollection),
                    if (onRefreshMetadata != null) ...[
                      Divider(
                          height: 1, color: libraryToolbarMenuBorder(context)),
                      _inspectorMenuItem('Update from Core',
                          AppIcons.updateFromCore, onRefreshMetadata),
                    ],
                    if (onUnlinkFromCore != null) ...[
                      Divider(
                          height: 1, color: libraryToolbarMenuBorder(context)),
                      _inspectorMenuItem('Unlink from Core', AppIcons.unlink,
                          onUnlinkFromCore),
                    ],
                    if (onLinkToCore != null) ...[
                      Divider(
                          height: 1, color: libraryToolbarMenuBorder(context)),
                      _inspectorMenuItem(
                          'Link to Core', AppIcons.link, onLinkToCore),
                    ],
                  ],
                  builder: (context, controller, child) => _InspectorBarButton(
                    tooltip: 'More inspector actions',
                    semanticsLabel: 'More inspector actions',
                    icon: AppIcons.more,
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
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

    final styled = Material(
      type: MaterialType.transparency,
      child: Ink(
        height: 38,
        decoration: BoxDecoration(
          color: framed
              ? palette.panel.withValues(alpha: 0.72)
              : libraryWorkspaceToolbarColor(context),
          borderRadius: framed ? BorderRadius.circular(4) : null,
          border: framed
              ? Border.all(color: palette.divider)
              : libraryWorkspaceToolbarBorder(context),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: contentMaxWidth == null
            ? content
            : Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth!),
                    child: content)),
      ),
    );

    if (!framed) return AppDarkChrome(accent: accent, child: styled);
    return accent == null
        ? styled
        : Theme(data: libraryAccentTheme(context, accent!), child: styled);
  }
}

Widget _inspectorMenuItem(
        String label, IconData icon, VoidCallback? callback) =>
    Builder(
      builder: (context) {
        final color = callback == null
            ? libraryToolbarMenuMutedText(context)
            : libraryToolbarMenuText(context);
        return MenuItemButton(
          onPressed: callback,
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(0, 30)),
            maximumSize:
                const WidgetStatePropertyAll(Size(double.infinity, 30)),
            padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 7)),
            shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            mouseCursor: WidgetStatePropertyAll(callback == null
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click),
            backgroundColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.hovered)
                    ? libraryToolbarMenuHover(context)
                    : Colors.transparent),
          ),
          child: LibraryWorkspaceMenuRow(
              label: label,
              leading: Icon(icon, size: 14, color: color),
              padding: EdgeInsets.zero,
              textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 24 / 14,
                  color: color)),
        );
      },
    );

Widget _inspectorToolbarSeparator(BuildContext context) =>
    const LibraryWorkspaceSeparator();

class InspectorEbayLinksSection extends ConsumerWidget {
  const InspectorEbayLinksSection({super.key, required this.item});
  final LibraryProjectionView item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(uiPreferencesProvider);
    if (!preferences.ebayLinksSection ||
        !preferences.allowsEbayLinks(item.source.isWishlisted)) {
      return const SizedBox.shrink();
    }
    final uri = buildEbaySearchUri(
      query: [item.dto.secondaryLabel, item.dto.primaryLabel]
          .whereType<String>()
          .join(' '),
      region: preferences.ebayRegion,
      soldOnly: preferences.ebaySearchFilter
          .soldOnlyFor(isWishlisted: item.source.isWishlisted),
    );
    if (uri == null) return const SizedBox.shrink();
    return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          style:
              TextButton.styleFrom(foregroundColor: appPalette(context).link),
          onPressed: () => launchUrl(uri),
          icon: const Icon(Icons.open_in_new, size: 14),
          label: const Text('Search eBay'),
        ));
  }
}
