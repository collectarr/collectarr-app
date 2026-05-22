import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC172E35),
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
                    color: Colors.white,
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
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF151515),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kClzPanelRaised,
        border: Border.all(color: kClzDivider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: kClzTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
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
  if (entry.isOwned) {
    return 'Owned';
  }
  if (entry.isWishlisted) {
    return 'Wishlist';
  }
  return 'Local catalog';
}

String genericLibraryDash(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }
  return value;
}
