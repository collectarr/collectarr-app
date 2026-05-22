import 'package:flutter/material.dart';

class LibraryCoverBadges extends StatelessWidget {
  const LibraryCoverBadges({
    required this.isOwned,
    required this.isWishlisted,
    this.hasMissingCover = false,
    this.hasMissingMetadata = false,
    this.keyLabel,
    this.slabLabel,
    super.key,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final String? keyLabel;
  final String? slabLabel;

  @override
  Widget build(BuildContext context) {
    if (!isOwned &&
        !isWishlisted &&
        !hasMissingCover &&
        !hasMissingMetadata &&
        keyLabel == null &&
        slabLabel == null) {
      return const SizedBox.shrink();
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 4,
      children: [
        if (isOwned)
          LibraryCoverBadge(
            icon: Icons.inventory_2,
            label: 'Owned',
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        if (isWishlisted)
          LibraryCoverBadge(
            icon: Icons.star,
            label: 'Wishlist',
            backgroundColor: colorScheme.tertiary,
            foregroundColor: colorScheme.onTertiary,
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
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x33000000),
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
    required this.isWishlisted,
    this.hasMissingCover = false,
    this.hasMissingMetadata = false,
    this.hasKeyMarker = false,
    this.hasSlabMarker = false,
    super.key,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final bool hasKeyMarker;
  final bool hasSlabMarker;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOwned ? Icons.check_box : Icons.check_box_outline_blank,
          size: 17,
          color: isOwned ? colorScheme.primary : colorScheme.outline,
        ),
        if (isWishlisted) ...[
          const SizedBox(width: 4),
          Icon(Icons.star, size: 16, color: colorScheme.tertiary),
        ],
        if (hasMissingCover) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.image_not_supported_outlined,
            size: 16,
            color: colorScheme.error,
          ),
        ],
        if (hasMissingMetadata) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.manage_search,
            size: 16,
            color: colorScheme.secondary,
          ),
        ],
        if (hasKeyMarker) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.label_important,
            size: 16,
            color: colorScheme.tertiary,
          ),
        ],
        if (hasSlabMarker) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.workspace_premium,
            size: 16,
            color: colorScheme.primary,
          ),
        ],
      ],
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
