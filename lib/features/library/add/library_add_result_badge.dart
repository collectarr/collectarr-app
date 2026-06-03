import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';

class LibraryAddResultBadge extends StatelessWidget {
  const LibraryAddResultBadge(
    this.label, {
    super.key,
    this.accent,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
  });

  final String label;
  final Color? accent;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final badgeColor = accent ??
        LibraryAccentScope.maybeOf(context)?.accent ??
        const Color(0xFF0E81A6);
    final resolvedForeground = foregroundColor ?? Colors.white;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ??
            Color.alphaBlend(
              Colors.black.withValues(alpha: 0.28),
              badgeColor,
            ),
        borderRadius: BorderRadius.circular(3),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: resolvedForeground),
              const SizedBox(width: 3),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: resolvedForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
