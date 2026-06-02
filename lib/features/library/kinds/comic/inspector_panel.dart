import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final request = widget.request;
    final accent = request.inspector.accent;
    final themedPanel = Color.alphaBlend(
      accent.withValues(alpha: palette.isDark ? 0.018 : 0.008),
      palette.surface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: themedPanel,
        border: Border(
          left: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.16 : 0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          _ComicInspectorToolbar(request: request),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                primary: false,
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    request.hero,
                    if (request.primarySections.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _ComicSectionDivider(accent: accent),
                      const SizedBox(height: 8),
                    ],
                    for (final section in request.primarySections) ...[
                      section,
                      const SizedBox(height: 10),
                    ],
                    if (request.bundleSection != null) ...[
                      request.bundleSection!,
                      const SizedBox(height: 10),
                    ],
                    if (request.conditionGradeSection != null) ...[
                      request.conditionGradeSection!,
                      const SizedBox(height: 10),
                    ],
                    for (final section in request.trailingSections) ...[
                      section,
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
    final accent = request.inspector.accent;
    final hasBarcode = entry.barcode?.trim().isNotEmpty == true;
    final onDetailsLayoutChanged = request.onDetailsLayoutChanged;
    final hasCopyMenu =
        request.ownedCopies.length > 1 && request.onSelectOwnedItem != null;
    final hasMoreEntries = hasCopyMenu ||
      request.onToggleOwned != null ||
      request.onToggleWishlist != null ||
      hasBarcode ||
      request.onCorrectMetadata != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: palette.isDark ? 0.012 : 0.004),
          palette.surface,
        ),
        border: Border(
          bottom: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.12 : 0.06),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _ComicToolbarGroup(
              children: [
                _ComicToolbarButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onPressed: request.onEdit,
                ),
                _ComicToolbarButton(
                  label: 'Share',
                  icon: Icons.share_outlined,
                  onPressed: () => showCollectionShareDialog(
                    context: context,
                    title: entry.resolvedTitle,
                    items: [entry],
                  ),
                ),
                if (hasMoreEntries) ...[
                  const _ComicToolbarSeparator(),
                  _ComicToolbarMenuButton(
                    buttonKey: const ValueKey('comic-toolbar-more-menu'),
                    label: 'More',
                    icon: Icons.more_horiz,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    entries: [
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
                        const _ComicToolbarMenuEntry(
                          label: 'Find on eBay',
                          icon: Icons.storefront_outlined,
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
                      if (request.onCorrectMetadata != null)
                        _ComicToolbarMenuEntry(
                          label: 'Correct metadata',
                          icon: Icons.fact_check_outlined,
                          onSelected: request.onCorrectMetadata,
                        ),
                    ],
                  ),
                ],
                if (request.extraActions.isNotEmpty) ...[
                  const _ComicToolbarSeparator(),
                  for (final action in request.extraActions)
                    action,
                ],
                const _ComicToolbarSeparator(),
                _ComicToolbarMenuButton(
                  buttonKey: const ValueKey('comic-toolbar-layout-menu'),
                  label: 'Layout',
                  icon: Icons.view_sidebar_outlined,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  trailingIcon: null,
                  entries: [
                    _ComicToolbarMenuEntry(
                      label: 'Open on right',
                      icon: Icons.view_sidebar_outlined,
                      onSelected: onDetailsLayoutChanged == null
                          ? null
                          : () => onDetailsLayoutChanged(
                                LibraryDetailsLayout.right,
                              ),
                      enabled: onDetailsLayoutChanged != null,
                    ),
                    _ComicToolbarMenuEntry(
                      label: 'Open on bottom',
                      icon: Icons.splitscreen_outlined,
                      onSelected: onDetailsLayoutChanged == null
                          ? null
                          : () => onDetailsLayoutChanged(
                                LibraryDetailsLayout.bottom,
                              ),
                      enabled: onDetailsLayoutChanged != null,
                    ),
                    _ComicToolbarMenuEntry(
                      label: 'Close details',
                      icon: Icons.visibility_off_outlined,
                      onSelected: onDetailsLayoutChanged == null
                          ? null
                          : () => onDetailsLayoutChanged(
                                LibraryDetailsLayout.hidden,
                              ),
                      enabled: onDetailsLayoutChanged != null,
                    ),
                  ],
                ),
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
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LibraryDenseButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      tone: LibraryDenseButtonTone.subtle,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    );
  }
}

class _ComicToolbarSeparator extends StatelessWidget {
  const _ComicToolbarSeparator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: VerticalDivider(
        width: 4,
        thickness: 1,
        color: appPalette(context).divider.withValues(alpha: 0.58),
      ),
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
    this.trailingIcon = Icons.keyboard_arrow_down,
  });

  final Key? buttonKey;
  final String label;
  final IconData icon;
  final List<_ComicToolbarMenuEntry> entries;
  final EdgeInsetsGeometry? padding;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return LibraryDenseMenuButton<_ComicToolbarMenuEntry>(
      key: buttonKey,
      label: label,
      icon: icon,
      tone: LibraryDenseButtonTone.subtle,
      padding: padding,
      trailingIcon: trailingIcon,
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

class _ComicSectionDivider extends StatelessWidget {
  const _ComicSectionDivider({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: 1,
      color: Color.alphaBlend(
        accent.withValues(alpha: 0.16),
        palette.divider,
      ),
    );
  }
}
