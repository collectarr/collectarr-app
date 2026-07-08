import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class LibraryMetaChip extends StatelessWidget {
  const LibraryMetaChip({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
  });

  final IconData icon;
  final String label;
  final Color accent;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: 0.8),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryItemPill extends StatelessWidget {
  const LibraryItemPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: kAppRadiusSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(
            color: kAppSurfaceDim,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class LibraryStatPill extends StatelessWidget {
  const LibraryStatPill({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String genericLibraryStatusLabel(LibraryWorkspaceEntry entry) {
  final labels = collectarrLibraryTypes
          .byKind(entry.mediaType)
          ?.presentation
          .statusLabels ??
      const LibraryStatusLabels();
  if (entry.isOwned) {
    return labels.owned;
  }
  if (entry.isTracked) {
    return labels.tracked;
  }
  if (entry.isWishlisted) {
    return labels.wishlist;
  }
  return labels.localCatalog;
}

String genericLibraryDash(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }
  return value;
}
