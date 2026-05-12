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
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF202020) : const Color(0xFF444444),
          border: const Border(
            right: BorderSide(color: Color(0xFF1A1A1A)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF18B7EB)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
