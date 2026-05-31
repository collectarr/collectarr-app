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
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
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
            _ComicToolbarButton(
              label: entry.isWishlisted ? 'Unwish' : 'Wishlist',
              icon: entry.isWishlisted ? Icons.star : Icons.star_border,
              onPressed: request.onToggleWishlist,
            ),
            _ComicToolbarButton(
              label: 'Open',
              icon: Icons.open_in_new,
              onPressed: request.onOpenDetails,
            ),
            for (final action in request.extraActions) action,
            if (request.onCorrectMetadata != null)
              _ComicToolbarIconButton(
                tooltip: 'Correct metadata',
                icon: Icons.fact_check_outlined,
                onPressed: request.onCorrectMetadata,
              ),
            const SizedBox(width: 6),
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
          ],
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
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      ),
    );
  }
}

class _ComicToolbarIconButton extends StatelessWidget {
  const _ComicToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        visualDensity: VisualDensity.compact,
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