import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';

class LibraryAddResultBadge extends StatelessWidget {
  const LibraryAddResultBadge(
    this.label, {
    super.key,
    this.accent,
  });

  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final badgeColor = accent ??
        LibraryAccentScope.maybeOf(context)?.accent ??
        const Color(0xFF0E81A6);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          Colors.black.withValues(alpha: 0.28),
          badgeColor,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
