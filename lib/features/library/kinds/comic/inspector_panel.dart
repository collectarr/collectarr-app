import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildComicInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return ComicInspectorPanel(request: request);
}

class ComicInspectorPanel extends StatefulWidget {
  const ComicInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  State<ComicInspectorPanel> createState() => _ComicInspectorPanelState();
}

class _ComicInspectorPanelState extends State<ComicInspectorPanel> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final request = widget.request;
    final accent = request.inspector.accent;
    final panelSurface = Color.alphaBlend(
      accent.withValues(alpha: palette.isDark ? 0.012 : 0.004),
      palette.surface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: panelSurface,
        border: Border(
          left: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.11 : 0.06),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _ComicInspectorHeader(request: request),
          _ComicInspectorToolbar(request: request),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                primary: false,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
                child: _ComicInspectorContent(request: request),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComicInspectorHeader extends StatelessWidget {
  const _ComicInspectorHeader({required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = request.inspector.accent;
    final entry = request.inspector.entry;
    final subtitle = [
      if (entry.series?.seriesTitle?.trim().isNotEmpty == true)
        entry.series!.seriesTitle!.trim(),
      if (entry.publisher?.trim().isNotEmpty == true) entry.publisher!.trim(),
    ].join(' • ');
    final badgeParts = <String>[
      if (entry.itemNumber?.trim().isNotEmpty == true)
        '#${entry.itemNumber!.trim()}',
      if (entry.variant?.trim().isNotEmpty == true) entry.variant!.trim(),
      entry.isOwned
          ? 'Owned'
          : entry.isWishlisted
              ? 'Wishlist'
              : 'Catalog',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(
            color: palette.divider.withValues(alpha: palette.isDark ? 0.72 : 0.5),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.resolvedTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _ComicHeaderBadge(label: badgeParts.join('  ')),
          ],
        ),
      ),
    );
  }
}

class _ComicHeaderBadge extends StatelessWidget {
  const _ComicHeaderBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: palette.divider.withValues(alpha: palette.isDark ? 0.84 : 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
        ),
      ),
    );
  }
}

class _ComicInspectorContent extends StatelessWidget {
  const _ComicInspectorContent({required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        request.hero,
        const SizedBox(height: 12),
        for (final section in request.primarySections) ...[
          section,
          const SizedBox(height: 12),
        ],
        if (request.bundleSection != null) ...[
          request.bundleSection!,
          const SizedBox(height: 12),
        ],
        if (request.conditionGradeSection != null) ...[
          request.conditionGradeSection!,
          const SizedBox(height: 12),
        ],
        for (final section in request.trailingSections) ...[
          section,
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ComicInspectorToolbar extends StatelessWidget {
  const _ComicInspectorToolbar({required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final entry = request.inspector.entry;
    final hasBarcode = entry.barcode?.trim().isNotEmpty == true;
    final ebayQuery = [
      if (entry.barcode?.trim().isNotEmpty == true) entry.barcode!.trim(),
      entry.resolvedTitle,
      if (entry.itemNumber?.trim().isNotEmpty == true) '#${entry.itemNumber!.trim()}',
      if (entry.variant?.trim().isNotEmpty == true) entry.variant!.trim(),
      if (request.inspector.ownedItem?.grade?.trim().isNotEmpty == true)
        request.inspector.ownedItem!.grade!.trim(),
    ].join(' ');
    final hasCopyMenu =
        request.ownedCopies.length > 1 && request.onSelectOwnedItem != null;
    final moveScopeLabel = entry.isOwned
      ? 'Move to wishlist'
      : entry.isWishlisted
        ? 'Move to collection'
        : 'Move to wishlist';
    final moveScopeAction = entry.isOwned
      ? request.onToggleWishlist
      : entry.isWishlisted
        ? request.onToggleOwned
        : request.onToggleWishlist;
    final hasMoreEntries = hasCopyMenu ||
      request.onToggleOwned != null ||
      request.onToggleWishlist != null ||
      hasBarcode ||
      request.onCorrectMetadata != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(color: palette.divider.withValues(alpha: 0.45)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _ComicToolbarGroup(
              children: [
                _ComicToolbarButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onPressed: request.onEdit,
                  tone: LibraryDenseButtonTone.subtle,
                ),
                if (hasMoreEntries) ...[
                  _ComicToolbarMenuButton(
                    buttonKey: const ValueKey('comic-toolbar-more-menu'),
                    label: 'More',
                    icon: Icons.more_horiz,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    entries: [
                      _ComicToolbarMenuEntry(
                        label: 'Share comic',
                        icon: Icons.share_outlined,
                        onSelected: () => showCollectionShareDialog(
                          context: context,
                          title: entry.resolvedTitle,
                          items: [entry],
                        ),
                      ),
                      _ComicToolbarMenuEntry(
                        label: 'Copy title',
                        icon: Icons.content_copy_outlined,
                        onSelected: () => _copyToolbarText(
                          context,
                          entry.resolvedTitle,
                          'Copied title',
                        ),
                      ),
                      if (hasBarcode)
                        _ComicToolbarMenuEntry(
                          label: 'Copy barcode',
                          icon: Icons.qr_code_2_outlined,
                          onSelected: () => _copyToolbarText(
                            context,
                            entry.barcode!.trim(),
                            'Copied barcode',
                          ),
                        ),
                      if (request.onToggleOwned != null)
                        _ComicToolbarMenuEntry(
                          label: entry.isOwned
                              ? 'Remove from collection'
                              : 'Collect',
                          icon: entry.isOwned
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline,
                          onSelected: request.onToggleOwned,
                        ),
                      _ComicToolbarMenuEntry(
                        label: 'Duplicate',
                        icon: Icons.copy_outlined,
                        onSelected: request.onDuplicate,
                        enabled: request.onDuplicate != null,
                      ),
                      _ComicToolbarMenuEntry(
                        label: 'Loan',
                        icon: Icons.schedule_outlined,
                        onSelected: request.onLoan,
                        enabled: request.onLoan != null,
                      ),
                      _ComicToolbarMenuEntry(
                        label: moveScopeLabel,
                        icon: entry.isWishlisted
                            ? Icons.inventory_2_outlined
                            : Icons.star_border,
                        onSelected: moveScopeAction,
                        enabled: moveScopeAction != null,
                      ),
                      _ComicToolbarMenuEntry(
                        label: 'Add copy',
                        icon: Icons.copy_outlined,
                        onSelected: request.onAddCopy,
                      ),
                      for (
                        var index = 0;
                        index < request.ownedCopies.length;
                        index += 1
                      )
                        _ComicToolbarMenuEntry(
                          label: request.ownedCopies[index].id ==
                                  request.selectedOwnedItemId
                              ? 'Viewing ${buildOwnedCopyLabel(request.ownedCopies[index], entry.editions, index)}'
                              : buildOwnedCopyLabel(
                                  request.ownedCopies[index],
                                  entry.editions,
                                  index,
                                ),
                          icon: request.ownedCopies[index].id ==
                                  request.selectedOwnedItemId
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          onSelected: () => request.onSelectOwnedItem?.call(
                            request.ownedCopies[index].id,
                          ),
                        ),
                      if (hasBarcode)
                        _ComicToolbarMenuEntry(
                          label: 'Find on eBay',
                          icon: Icons.storefront_outlined,
                          onSelected: () => launchEbaySearch(ebayQuery),
                        ),
                      if (request.onToggleWishlist != null)
                        _ComicToolbarMenuEntry(
                          label: entry.isWishlisted ? 'Unwish' : 'Wishlist',
                          icon: entry.isWishlisted ? Icons.star : Icons.star_border,
                          onSelected: request.onToggleWishlist,
                        ),
                      _ComicToolbarMenuEntry(
                        label: 'Open details',
                        icon: Icons.open_in_new,
                        onSelected: request.onOpenDetails,
                      ),
                      const _ComicToolbarMenuEntry(
                        label: 'Update value',
                        icon: Icons.price_change_outlined,
                        enabled: false,
                      ),
                      const _ComicToolbarMenuEntry(
                        label: 'Update Key Info',
                        icon: Icons.key_outlined,
                        enabled: false,
                      ),
                      _ComicToolbarMenuEntry(
                        label: 'Update from Core',
                        icon: Icons.cloud_download_outlined,
                        onSelected: request.onRefreshMetadata,
                        enabled: request.onRefreshMetadata != null,
                      ),
                      if (request.onCorrectMetadata != null)
                        _ComicToolbarMenuEntry(
                          label: 'Correct metadata',
                          icon: Icons.fact_check_outlined,
                          onSelected: request.onCorrectMetadata,
                        ),
                      const _ComicToolbarMenuEntry(
                        label: 'Relink Core variant',
                        icon: Icons.link_outlined,
                        enabled: false,
                      ),
                      const _ComicToolbarMenuEntry(
                        label: 'Unlink from Core',
                        icon: Icons.link_off_outlined,
                        enabled: false,
                      ),
                      const _ComicToolbarMenuEntry(
                        label: 'Submit to Core',
                        icon: Icons.cloud_upload_outlined,
                        enabled: false,
                      ),
                    ],
                  ),
                ],
                if (request.extraActions.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  for (final action in request.extraActions)
                    action,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ComicToolbarGroup extends StatelessWidget {
  const _ComicToolbarGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(width: 2),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _ComicToolbarButton extends StatelessWidget {
  const _ComicToolbarButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tone = LibraryDenseButtonTone.subtle,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final LibraryDenseButtonTone tone;

  @override
  Widget build(BuildContext context) {
    return LibraryDenseButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      tone: tone,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    );
  }
}

class _ComicToolbarMenuEntry {
  const _ComicToolbarMenuEntry({
    required this.label,
    required this.icon,
    this.onSelected,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onSelected;
  final bool enabled;
}

class _ComicToolbarMenuButton extends StatelessWidget {
  const _ComicToolbarMenuButton({
    this.buttonKey,
    required this.label,
    required this.icon,
    required this.entries,
    this.padding,
  });

  final Key? buttonKey;
  final String label;
  final IconData icon;
  final List<_ComicToolbarMenuEntry> entries;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LibraryDenseMenuButton<_ComicToolbarMenuEntry>(
      key: buttonKey,
      label: label,
      icon: icon,
      tone: LibraryDenseButtonTone.subtle,
      padding: padding,
      trailingIcon: Icons.keyboard_arrow_down,
      entries: [
        for (final entry in entries)
          LibraryDenseMenuEntry<_ComicToolbarMenuEntry>(
            value: entry,
            label: entry.label,
            icon: entry.icon,
            enabled: entry.enabled,
          ),
      ],
      onSelected: (entry) => entry.onSelected?.call(),
    );
  }
}

void _copyToolbarText(BuildContext context, String value, String message) {
  Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

