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
      accent.withValues(alpha: palette.isDark ? 0.06 : 0.03),
      palette.panel,
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: themedPanel),
      child: Column(
        children: [
          _ComicInspectorToolbar(request: request),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
              children: [
                request.hero,
                if (request.primarySections.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ComicSectionDivider(accent: accent),
                ],
                for (final section in request.primarySections) ...[
                  const SizedBox(height: 12),
                  section,
                ],
                if (request.ownedCopiesSection != null) ...[
                  const SizedBox(height: 12),
                  request.ownedCopiesSection!,
                ],
                if (request.bundleSection != null) ...[
                  const SizedBox(height: 12),
                  request.bundleSection!,
                ],
                if (request.conditionGradeSection != null) ...[
                  const SizedBox(height: 12),
                  request.conditionGradeSection!,
                ],
                for (final section in request.trailingSections) ...[
                  const SizedBox(height: 12),
                  section,
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
        color: Color.alphaBlend(accent.withValues(alpha: 0.1), palette.toolbar),
        border: Border(
          bottom: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.5 : 0.28),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            final leading = Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _ComicToolbarGroup(
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
                  ],
                ),
                _ComicToolbarGroup(
                  children: [
                    _ComicToolbarMenuButton(
                      buttonKey: const ValueKey('comic-toolbar-share-menu'),
                      label: 'Share',
                      icon: Icons.share_outlined,
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
                  ],
                ),
                if (hasBarcode)
                  _ComicToolbarGroup(
                    children: [
                      _ComicToolbarBadgeButton(
                        label: 'eBay',
                        icon: Icons.storefront_outlined,
                        accent: accent,
                      ),
                    ],
                  ),
                _ComicToolbarGroup(
                  children: [
                    _ComicToolbarMenuButton(
                      buttonKey: const ValueKey('comic-toolbar-more-menu'),
                      label: 'More',
                      icon: Icons.more_vert,
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
                    if (request.extraActions.isNotEmpty) ...request.extraActions,
                  ],
                ),
              ],
            );

            final trailing = _ComicToolbarGroup(
              children: [
                _ComicToolbarMenuButton(
                  buttonKey: const ValueKey('comic-toolbar-layout-menu'),
                  label: 'Layout',
                  icon: Icons.view_sidebar_outlined,
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
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [leading, const SizedBox(height: 8), trailing],
              );
            }

            return Row(
              children: [
                Expanded(child: leading),
                const SizedBox(width: 12),
                trailing,
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
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
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
      tone: LibraryDenseButtonTone.surface,
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
  });

  final Key? buttonKey;
  final String label;
  final IconData icon;
  final List<_ComicToolbarMenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    return LibraryDenseMenuButton<_ComicToolbarMenuEntry>(
      key: buttonKey,
      label: label,
      icon: icon,
      tone: LibraryDenseButtonTone.surface,
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