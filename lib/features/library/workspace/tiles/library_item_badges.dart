import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryCoverBadges extends StatelessWidget {
  const LibraryCoverBadges({
    required this.isOwned,
    required this.isTracked,
    required this.isWishlisted,
    this.hasMissingCover = false,
    this.hasMissingMetadata = false,
    this.keyLabel,
    this.slabLabel,
    this.notesLabel,
    super.key,
  });

  final bool isOwned;
  final bool isTracked;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final String? keyLabel;
  final String? slabLabel;
  final String? notesLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        LibraryCoverBadge(
          icon: isOwned ? Icons.check_box : Icons.check_box_outline_blank,
          label: isOwned ? 'Owned' : 'Not owned',
          backgroundColor: isOwned
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          foregroundColor: isOwned
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
        if (isTracked)
          LibraryCoverBadge(
            icon: Icons.equalizer,
            label: 'Tracked',
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
          ),
        if (isWishlisted)
          LibraryCoverBadge(
            icon: Icons.star,
            label: 'Wishlist',
            backgroundColor: colorScheme.tertiaryContainer,
            foregroundColor: colorScheme.onTertiaryContainer,
          ),
        if (hasMissingCover)
          LibraryCoverBadge(
            icon: Icons.image_not_supported_outlined,
            label: 'Missing cover',
            backgroundColor: colorScheme.errorContainer,
            foregroundColor: colorScheme.onErrorContainer,
          ),
        if (hasMissingMetadata)
          LibraryCoverBadge(
            icon: Icons.manage_search,
            label: 'Missing metadata',
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
          ),
        if (keyLabel != null)
          LibraryCoverBadge(
            icon: Icons.label_important,
            label: keyLabel!,
            backgroundColor: colorScheme.tertiaryContainer,
            foregroundColor: colorScheme.onTertiaryContainer,
          ),
        if (slabLabel != null)
          LibraryCoverBadge(
            icon: Icons.workspace_premium,
            label: slabLabel!,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
        if (notesLabel != null)
          LibraryCoverBadge(
            icon: Icons.sticky_note_2_outlined,
            label: notesLabel!,
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
          ),
      ],
    );
  }
}

class LibraryCoverBadge extends StatelessWidget {
  const LibraryCoverBadge({
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = appPalette(context);
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: palette.divider.withValues(alpha: 0.28),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 13,
            color: foregroundColor ?? colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class LibraryItemStatusIcons extends StatelessWidget {
  const LibraryItemStatusIcons({
    required this.isOwned,
    required this.isTracked,
    required this.isWishlisted,
    this.hasMissingCover = false,
    this.hasMissingMetadata = false,
    this.hasKeyMarker = false,
    this.hasSlabMarker = false,
    this.hasNotesMarker = false,
    super.key,
  });

  final bool isOwned;
  final bool isTracked;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final bool hasKeyMarker;
  final bool hasSlabMarker;
  final bool hasNotesMarker;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icons = <Widget>[
      Icon(
        isOwned ? Icons.check_box : Icons.check_box_outline_blank,
        size: 17,
        color: isOwned ? colorScheme.primary : colorScheme.outline,
      ),
      if (isTracked)
        Icon(Icons.equalizer, size: 16, color: colorScheme.secondary),
      if (isWishlisted)
        Icon(Icons.star, size: 16, color: colorScheme.tertiary),
      if (hasMissingCover)
        Icon(
          Icons.image_not_supported_outlined,
          size: 16,
          color: colorScheme.error,
        ),
      if (hasMissingMetadata)
        Icon(
          Icons.manage_search,
          size: 16,
          color: colorScheme.secondary,
        ),
      if (hasKeyMarker)
        Icon(
          Icons.label_important,
          size: 16,
          color: colorScheme.tertiary,
        ),
      if (hasSlabMarker)
        Icon(
          Icons.workspace_premium,
          size: 16,
          color: colorScheme.primary,
        ),
      if (hasNotesMarker)
        Icon(
          Icons.sticky_note_2_outlined,
          size: 16,
          color: colorScheme.secondary,
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        var maxVisibleIcons = 2;
        if (constraints.maxWidth.isFinite) {
          if (constraints.maxWidth <= 34) {
            maxVisibleIcons = 0;
          } else if (constraints.maxWidth <= 54) {
            maxVisibleIcons = 1;
          }
        }

        final visibleIcons = icons.take(maxVisibleIcons).toList(growable: false);
        final hiddenCount = icons.length - visibleIcons.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < visibleIcons.length; index++) ...[
              if (index > 0) const SizedBox(width: 4),
              visibleIcons[index],
            ],
            if (hiddenCount > 0) ...[
              if (visibleIcons.isNotEmpty) const SizedBox(width: 2),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  child: Text(
                    '+$hiddenCount',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

String? libraryKeyMarkerLabel(bool keyComic, String? keyReason) {
  if (!keyComic) {
    return null;
  }
  final trimmed = keyReason?.trim();
  return trimmed == null || trimmed.isEmpty ? 'Key item' : 'Key item: $trimmed';
}

String? librarySlabMarkerLabel(String? rawOrSlabbed, String? gradingCompany) {
  final slab = rawOrSlabbed?.trim();
  final company = gradingCompany?.trim();
  if ((slab == null || slab.isEmpty) && (company == null || company.isEmpty)) {
    return null;
  }
  if (slab != null && slab.isNotEmpty && company != null && company.isNotEmpty) {
    return '$slab - $company';
  }
  return slab?.isNotEmpty == true ? slab : company;
}

String? libraryNotesMarkerLabel(String? notes) {
  final trimmed = notes?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return 'Notes: $trimmed';
}
