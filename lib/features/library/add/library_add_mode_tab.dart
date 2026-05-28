import 'package:collectarr_app/ui/theme/app_theme.dart';
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
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = Color.alphaBlend(
      accent.withValues(alpha: 0.18),
      palette.panelRaised,
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
          color: selected ? selectedColor : palette.panel,
          border: Border.all(
            color: selected ? accent : palette.divider,
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
              style: TextStyle(
                color: colorScheme.onSurface,
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
