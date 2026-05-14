import 'package:flutter/material.dart';

class LibraryCoverBadges extends StatelessWidget {
  const LibraryCoverBadges({
    required this.isOwned,
    required this.isWishlisted,
    this.hasMissingCover = false,
    this.hasMissingMetadata = false,
    super.key,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;

  @override
  Widget build(BuildContext context) {
    if (!isOwned && !isWishlisted && !hasMissingCover && !hasMissingMetadata) {
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
    super.key,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;

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
      ],
    );
  }
}
