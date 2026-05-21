import 'package:flutter/material.dart';

class LibraryAddModeTab extends StatelessWidget {
  const LibraryAddModeTab({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.accent = const Color(0xFF18B7EB),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.48),
      accent,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 34,
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? selectedColor : const Color(0xFF2D2F31),
          border: Border.all(
            color: selected ? accent : const Color(0xFF55585B),
          ),
          borderRadius: BorderRadius.circular(3),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.34),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFEDEDED),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
