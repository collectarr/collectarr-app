import 'package:collectarr_app/features/library/config/library_type_config.dart';
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
                if (request.ownedCopiesSection != null) ...[
                  const SizedBox(height: 10),
                  request.ownedCopiesSection!,
                ],
                if (request.bundleSection != null) ...[
                  const SizedBox(height: 10),
                  request.bundleSection!,
                ],
                if (request.conditionGradeSection != null) ...[
                  const SizedBox(height: 10),
                  request.conditionGradeSection!,
                ],
                for (final section in request.primarySections) ...[
                  const SizedBox(height: 10),
                  section,
                ],
                if (request.trailingSections.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _ComicInspectorTools(
                    title: 'Collection tools',
                    accent: accent,
                    children: request.trailingSections,
                  ),
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
                    _ComicToolbarMenuButton(
                      label: 'More',
                      icon: Icons.more_vert,
                      entries: [
                        _ComicToolbarMenuEntry(
                          label: 'Open details',
                          icon: Icons.open_in_new,
                          onSelected: request.onOpenDetails,
                        ),
                        _ComicToolbarMenuEntry(
                          label: entry.isOwned ? 'Remove from collection' : 'Add to collection',
                          icon: entry.isOwned
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline,
                          onSelected: request.onToggleOwned,
                        ),
                        _ComicToolbarMenuEntry(
                          label: entry.isWishlisted ? 'Remove from wishlist' : 'Move to wishlist',
                          icon: entry.isWishlisted ? Icons.star : Icons.star_border,
                          onSelected: request.onToggleWishlist,
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
                ),
                if (hasBarcode)
                  _ComicToolbarBadgeButton(
                    label: 'eBay',
                    icon: Icons.storefront_outlined,
                    accent: accent,
                  ),
                if (request.extraActions.isNotEmpty)
                  _ComicToolbarGroup(children: request.extraActions),
              ],
            );
            final trailing = Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _ComicStatusPill(
                  label: entry.isOwned ? 'In Collection' : 'Catalog only',
                  color: entry.isOwned ? accent : palette.surfaceSubtle,
                  foreground: entry.isOwned ? Colors.white : palette.textMuted,
                ),
                if (entry.isWishlisted)
                  _ComicStatusPill(
                    label: 'Wish list',
                    color: palette.surfaceSubtle,
                    foreground: palette.textPrimary,
                  ),
                _ComicToolbarGhostButton(
                  label: 'Layout',
                  icon: Icons.view_sidebar_outlined,
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
    final palette = appPalette(context);
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15, color: palette.textPrimary),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: palette.textPrimary,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _ComicToolbarMenuEntry {
  const _ComicToolbarMenuEntry({
    required this.label,
    required this.icon,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onSelected;
}

class _ComicToolbarMenuButton extends StatelessWidget {
  const _ComicToolbarMenuButton({
    required this.label,
    required this.icon,
    required this.entries,
  });

  final String label;
  final IconData icon;
  final List<_ComicToolbarMenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return PopupMenuButton<_ComicToolbarMenuEntry>(
      tooltip: label,
      onSelected: (entry) => entry.onSelected?.call(),
      itemBuilder: (context) => [
        for (final entry in entries)
          PopupMenuItem<_ComicToolbarMenuEntry>(
            value: entry,
            child: Row(
              children: [
                Icon(entry.icon, size: 16, color: palette.textPrimary),
                const SizedBox(width: 10),
                Text(entry.label),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: palette.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: palette.textMuted),
          ],
        ),
      ),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComicToolbarGhostButton extends StatelessWidget {
  const _ComicToolbarGhostButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: palette.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: palette.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ComicStatusPill extends StatelessWidget {
  const _ComicStatusPill({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _ComicInspectorTools extends StatelessWidget {
  const _ComicInspectorTools({
    required this.title,
    required this.accent,
    required this.children,
  });

  final String title;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            for (final child in children) ...[
              const SizedBox(height: 10),
              child,
            ],
          ],
        ),
      ),
    );
  }
}