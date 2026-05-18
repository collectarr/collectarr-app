import 'package:flutter/material.dart';

class LibraryAddModeTab extends StatelessWidget {
  const LibraryAddModeTab({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 32,
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF15384B) : const Color(0xFF2D2F31),
          border: Border.all(
            color: selected ? const Color(0xFF18B7EB) : const Color(0xFF55585B),
          ),
          borderRadius: BorderRadius.circular(3),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x5518B7EB),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF18B7EB)),
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
