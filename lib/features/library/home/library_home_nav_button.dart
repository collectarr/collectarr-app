import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/library_home_nav_models.dart';
import 'package:flutter/material.dart';

class MediaLibraryNavButton extends StatelessWidget {
  const MediaLibraryNavButton({
    super.key,
    required this.type,
    required this.color,
    required this.icon,
    required this.selected,
    required this.count,
    required this.onPressed,
    this.animationDuration = const Duration(milliseconds: 320),
  });

  final CatalogMediaType type;
  final Color color;
  final IconData icon;
  final bool selected;
  final int count;
  final VoidCallback onPressed;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? Colors.white.withValues(alpha: 0.72) : color;
    return Tooltip(
      message: type.pluralLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(3),
          onTap: selected ? null : onPressed,
          child: AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeOutCubic,
            height: 30,
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.38),
                        color.withValues(alpha: 0.14),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.28),
                        Colors.black.withValues(alpha: 0.28),
                      ],
                    ),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 4, height: double.infinity, color: color),
                const SizedBox(width: 8),
                Icon(icon, size: 17, color: selected ? Colors.white : color),
                const SizedBox(width: 7),
                Text(
                  libraryNavLabel(type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
