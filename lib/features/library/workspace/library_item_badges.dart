import 'package:flutter/material.dart';

class LibraryCoverBadges extends StatelessWidget {
  const LibraryCoverBadges({
    required this.isOwned,
    required this.isWishlisted,
    super.key,
  });

  final bool isOwned;
  final bool isWishlisted;

  @override
  Widget build(BuildContext context) {
    if (!isOwned && !isWishlisted) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 4,
      children: [
        if (isOwned)
          const LibraryCoverBadge(icon: Icons.inventory_2, label: 'Owned'),
        if (isWishlisted)
          const LibraryCoverBadge(icon: Icons.star, label: 'Wishlist'),
      ],
    );
  }
}

class LibraryCoverBadge extends StatelessWidget {
  const LibraryCoverBadge({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primary,
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
          child: Icon(icon, size: 13, color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class LibraryItemStatusIcons extends StatelessWidget {
  const LibraryItemStatusIcons({
    required this.isOwned,
    required this.isWishlisted,
    super.key,
  });

  final bool isOwned;
  final bool isWishlisted;

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
      ],
    );
  }
}
