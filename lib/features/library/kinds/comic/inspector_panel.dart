import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_dense_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildComicInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return ComicInspectorPanel(request: request);
}

class ComicInspectorPanel extends StatelessWidget {
  const ComicInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = request.inspector.accent;
    final themedPanel = Color.alphaBlend(
      accent.withValues(alpha: palette.isDark ? 0.03 : 0.015),
      palette.panel,
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: themedPanel),
      child: Column(
        children: [
          _ComicInspectorToolbar(request: request),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
              children: [
                request.hero,
                if (request.primarySections.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _ComicSectionDivider(accent: accent),
                  const SizedBox(height: 10),
                ],
                for (final section in request.primarySections) ...[
                  section,
                  const SizedBox(height: 10),
                ],
                if (request.ownedCopiesSection != null) ...[
                  request.ownedCopiesSection!,
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: palette.isDark ? 0.04 : 0.022),
          palette.toolbar,
        ),
        border: Border(
          bottom: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.28 : 0.14),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
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
                  label: entry.isOwned ? 'Remove' : 'Collect',
                  icon: entry.isOwned
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  onPressed: request.onToggleOwned,
                ),
                const _ComicToolbarSeparator(),
                _ComicToolbarMenuButton(
                  buttonKey: const ValueKey('comic-toolbar-share-menu'),
                  label: 'Share',
                  icon: Icons.share_outlined,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  entries: const [
                    _ComicToolbarMenuEntry(
                      label: 'Share comic',
                      icon: Icons.ios_share_outlined,
                      enabled: false,
                    ),
                    _ComicToolbarMenuEntry(
                      label: 'Duplicate',
                      icon: Icons.copy_all_outlined,
                      enabled: false,
                    ),
                  ],
                ),
                if (hasBarcode) ...[
                  const _ComicToolbarSeparator(),
                  _ComicToolbarBadgeButton(
                    label: 'eBay',
                    icon: Icons.storefront_outlined,
                    accent: accent,
                  ),
                ],
                const _ComicToolbarSeparator(),
                _ComicToolbarMenuButton(
                  buttonKey: const ValueKey('comic-toolbar-more-menu'),
                  label: 'More',
                  icon: Icons.more_vert,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  entries: [
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
                      label: 'Loan',
                      icon: Icons.handshake_outlined,
                      enabled: false,
                    ),
                    const _ComicToolbarMenuEntry(
                      label: 'Update value',
                      icon: Icons.trending_up_outlined,
                      enabled: false,
                    ),
                    const _ComicToolbarMenuEntry(
                      label: 'Update Key Info',
                      icon: Icons.key_outlined,
                      enabled: false,
                    ),
                    const _ComicToolbarMenuEntry(
                      label: 'Update from Core',
                      icon: Icons.sync_outlined,
                      enabled: false,
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
                      icon: Icons.upload_outlined,
                      enabled: false,
                    ),
                    _ComicToolbarMenuEntry(
                      label: 'Add copy',
                      icon: Icons.copy_outlined,
                      onSelected: request.onAddCopy,
                    ),
                    if (request.onCorrectMetadata != null)
                      _ComicToolbarMenuEntry(
                        label: 'Correct metadata',
                        icon: Icons.fact_check_outlined,
                        onSelected: request.onCorrectMetadata,
                      ),
                  ],
                ),
                if (request.extraActions.isNotEmpty) ...[
                  const _ComicToolbarSeparator(),
                  for (final action in request.extraActions)
                    Transform.scale(scale: 0.84, child: action),
                ],
                Transform.scale(
                  alignment: Alignment.centerLeft,
                  scale: 0.78,
                  child: _ComicToolbarMenuButton(
                    buttonKey: const ValueKey('comic-toolbar-layout-menu'),
                    label: 'Layout',
                    icon: Icons.view_sidebar_outlined,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    trailingIcon: null,
                    entries: const [
                      _ComicToolbarMenuEntry(
                        label: 'Sidebar details',
                        icon: Icons.view_sidebar_outlined,
                        enabled: false,
                      ),
                      _ComicToolbarMenuEntry(
                        label: 'Bottom details',
                        icon: Icons.splitscreen_outlined,
                        enabled: false,
                      ),
                    ],
                  ),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: appPalette(context).divider.withValues(alpha: 0.84),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
        child: SingleChildScrollView(
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
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    );
  }
}

class _ComicToolbarSeparator extends StatelessWidget {
  const _ComicToolbarSeparator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: VerticalDivider(
        width: 5,
        thickness: 1,
        color: appPalette(context).divider.withValues(alpha: 0.84),
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

class _ComicToolbarBadgeButton extends StatelessWidget {
  const _ComicToolbarBadgeButton({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryDenseButton(
      label: label,
      icon: icon,
      tone: LibraryDenseButtonTone.subtle,
      onPressed: null,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
